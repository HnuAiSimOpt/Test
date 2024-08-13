import torch
import torch.nn as nn
from copy import deepcopy
# from tea_relevent.core.param import load_model_and_optimizer, copy_model_and_optimizer
from torchvision.utils import save_image
import os
from torch.nn import functional as F


def copy_model_and_optimizer(model, optimizer):
    """Copy the model and optimizer states for resetting after adaptation."""
    model_state = deepcopy(model.state_dict())
    optimizer_state = deepcopy(optimizer.state_dict())
    return model_state, optimizer_state


def load_model_and_optimizer(model, optimizer, model_state, optimizer_state):
    """Restore the model and optimizer states from copies."""
    model.load_state_dict(model_state, strict=True)
    optimizer.load_state_dict(optimizer_state)


def init_random(bs, im_sz=32, n_ch=3):
    return torch.FloatTensor(bs, n_ch, im_sz, im_sz).uniform_(-1, 1)


class EnergyModel(nn.Module):
    def __init__(self, model):
        super(EnergyModel, self).__init__()
        self.f = model

    # 调用模型实现分类任务 返回的就是logits
    def classify(self, x):
        penult_z = self.f(x)
        return penult_z

    def forward(self, x, y=None):
        logits = self.classify(x)  # [batch,classes]
        if y is None:
            probabilities = F.softmax(logits, dim=-1)
            epsilon = 1e-12
            entropy = torch.sum(-probabilities * torch.log(probabilities + epsilon), dim=-1)  # [batchsize,]
            result_tensor = (entropy < 1.4).to(torch.int)
            k = logits.logsumexp(1)
            # p = k * (10 * result_tensor + 1)
            # return p, logits  # 返回计算得到的能量以及logits
            # return "wrong"
            # print('能量：', k)
            return k, logits  # 返回计算得到的能量以及logits

        else:
            return torch.gather(logits, 1, y[:, None]), logits


def sample_p_0(reinit_freq, replay_buffer, bs, im_sz, n_ch, device, y=None):
    if len(replay_buffer) == 0:
        return init_random(bs, im_sz=im_sz, n_ch=n_ch), []
    buffer_size = len(replay_buffer)
    inds = torch.randint(0, buffer_size, (bs,))
    # if cond, convert inds to class conditional inds
    buffer_samples = replay_buffer[inds]
    random_samples = init_random(bs, im_sz=im_sz, n_ch=n_ch)
    choose_random = (torch.rand(bs) < reinit_freq).float()[:, None, None, None]
    samples = choose_random * random_samples + (1 - choose_random) * buffer_samples
    return samples.to(device), inds


# 从指定的能量模型 ( f ) 中采样
def sample_q(f, replay_buffer, n_steps, sgld_lr, sgld_std, reinit_freq, batch_size, im_sz, n_ch, device, y=None):
    """this func takes in replay_buffer now so we have the option to sample from
    scratch (i.e. replay_buffer==[]).  See test_wrn_ebm.py for example.
    """
    f.eval()
    # get batch size
    bs = batch_size if y is None else y.size(0)
    # generate initial samples and buffer inds of those samples (if buffer is used)
    init_sample, buffer_inds = sample_p_0(reinit_freq=reinit_freq, replay_buffer=replay_buffer, bs=bs, im_sz=im_sz,
                                          n_ch=n_ch, device=device, y=y)
    init_samples = deepcopy(init_sample)
    x_k = torch.autograd.Variable(init_sample, requires_grad=True)
    # sgld
    for k in range(n_steps):
        f_prime = torch.autograd.grad(f(x_k, y=y)[0].sum(), [x_k], retain_graph=True)[0]
        x_k.data += sgld_lr * f_prime + sgld_std * torch.randn_like(x_k)
    f.train()
    final_samples = x_k.detach()
    # update replay buffer
    if len(replay_buffer) > 0:
        replay_buffer[buffer_inds] = final_samples.cpu()
    return final_samples, init_samples.detach()


def sample_odl(f, replay_buffer, n_steps, odl_lr, odl_std, reinit_freq, batch_size, im_sz, n_ch, device, y=None):
    # Set the model to evaluation mode if necessary
    # model.eval()
    f.eval()
    # Determine batch size
    batch_size = len(y) if y is not None else batch_size

    # Sample initial points from replay buffer or initialize them randomly
    if replay_buffer is not None and len(replay_buffer) > 0:
        idxs = torch.randint(len(replay_buffer), (batch_size,))
        x = replay_buffer[idxs].to(device)
        if torch.rand(1) < reinit_freq:
            x = torch.randn(batch_size, n_ch, im_sz, im_sz).to(device)
    else:
        x = torch.randn(batch_size, n_ch, im_sz, im_sz).to(device)

    # ODL updates
    for _ in range(n_steps):
        x.requires_grad_()
        energy = f(x)
        energy_sum = energy[0] + energy[1]
        grad = torch.autograd.grad(energy, x, create_graph=True)[0]
        x.data.add_(-odl_lr * grad + odl_std * torch.randn_like(x))

    # Set the model back to training mode if necessary
    # model.train()

    # Update replay buffer
    if replay_buffer is not None:
        replay_buffer[idxs] = x.cpu().detach()

    return x


class Energy(nn.Module):
    """
    Tent在测试过程中通过最小化熵来自适应模型，一旦经过tent处理，模型会在每次前向传播时自我调整
    Tent adapts a model by entropy minimization during testing.
    Once tented, a model adapts itself by updating on every forward.
    model：传入的原始模型。
    optimizer：优化器。
    steps：执行的步数，默认为1。
    episodic：一个布尔值，表示是否采用一种称为“episodic”的训练方式。
    buffer_size：重播缓冲区的大小。
    sgld_steps、sgld_lr、sgld_std：一些用于随机梯度 Langevin 动力学（SGLD）优化器的参数。
    reinit_freq：重置频率。
    if_cond：一个布尔值，表示是否使用条件模型。
    n_classes、im_sz、n_ch：类别数量、图像大小和通道数等模型参数。
    path：保存可视化图像的路径。
    logger：日志记录器。
    """

    def __init__(self, model, optimizer, steps=1, episodic=False,
                 buffer_size=10000, sgld_steps=30, sgld_lr=1, sgld_std=0.01, reinit_freq=0.05, if_cond=False,
                 n_classes=7, im_sz=224, n_ch=3, path=None, logger=None):
        super().__init__()

        self.energy_model = EnergyModel(model)
        self.replay_buffer = init_random(buffer_size, im_sz=im_sz, n_ch=n_ch)
        self.replay_buffer_old = deepcopy(self.replay_buffer)
        self.optimizer = optimizer
        self.steps = steps
        assert steps > 0, "tent requires >= 1 step(s) to forward and update"
        self.episodic = episodic

        self.sgld_steps = sgld_steps
        self.sgld_lr = sgld_lr
        self.sgld_std = sgld_std
        self.reinit_freq = reinit_freq
        self.if_cond = if_cond

        self.n_classes = n_classes
        self.im_sz = im_sz
        self.n_ch = n_ch

        self.path = path
        self.logger = logger

        # note: if the model is never reset, like for continual adaptation,
        # then skipping the state copy would save memory
        self.model_state, self.optimizer_state = \
            copy_model_and_optimizer(self.energy_model, self.optimizer)

    def forward(self, x, if_adapt=True, counter=None, if_vis=False):
        if self.episodic:
            # 根据episodic来判定是否重置模型参数
            self.reset()
        # 根据if_adapt参数的值，它可能会在每次前向传播时更新模型参数
        # 则调用forward_and_adapt函数执行前向传播和模型参数更新
        # 如果设置了 if_vis 为 True，则在每个步骤中可视化一些图像。
        if if_adapt:
            for i in range(self.steps):
                outputs = forward_and_adapt(x, self.energy_model, self.optimizer,
                                            self.replay_buffer, self.sgld_steps, self.sgld_lr, self.sgld_std,
                                            self.reinit_freq,
                                            if_cond=self.if_cond, n_classes=self.n_classes)
                if i % 1 == 0 and if_vis:
                    visualize_images(path=self.path, replay_buffer_old=self.replay_buffer_old,
                                     replay_buffer=self.replay_buffer, energy_model=self.energy_model,
                                     sgld_steps=self.sgld_steps, sgld_lr=self.sgld_lr, sgld_std=self.sgld_std,
                                     reinit_freq=self.reinit_freq,
                                     batch_size=100, n_classes=self.n_classes, im_sz=self.im_sz, n_ch=self.n_ch,
                                     device=x.device, counter=counter, step=i)
        else:
            self.energy_model.eval()
            with torch.no_grad():
                outputs = self.energy_model.classify(x)

        return outputs

    def reset(self):
        # 用于重置模型状态 将模型和优化器的状态加载回之前保存的状态。
        if self.model_state is None or self.optimizer_state is None:
            raise Exception("cannot reset without saved model/optimizer state")
        load_model_and_optimizer(self.energy_model, self.optimizer,
                                 self.model_state, self.optimizer_state)


# 可视化生成的图像以及它们的变化过程，主要用于调试和理解基于能量模型（如变分自编码器、生成对抗网络或其他生成模型）的工作情况
@torch.enable_grad()  # 装饰器用来确保在函数内部自动跟踪张量的梯度计算，即使在全局设置为无梯度模式的情况下也是如此
def visualize_images(path, replay_buffer_old, replay_buffer, energy_model,
                     sgld_steps, sgld_lr, sgld_std, reinit_freq,
                     batch_size, n_classes, im_sz, n_ch, device=None, counter=None, step=None):
    # 设置展示图像的列数，以及每个类别重复的次数以满足批量大小要求
    num_cols = 10
    repeat_times = batch_size // n_classes
    y = torch.arange(n_classes).repeat(repeat_times).to(device)
    # 调用sample_q函数，使用SGD-Langevin动力学从能量模型中采样生成图像
    x_fake, _ = sample_q(energy_model, replay_buffer, n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std,
                         reinit_freq=reinit_freq, batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=y)
    # 将采样得到的生成图像x_fake从GPU移到CPU上并从中断开梯度追踪（.detach()），以便后续的保存操作
    images = x_fake.detach().cpu()
    # 使用save_image函数将生成的图像保存为PNG文件，存储在指定路径下，每行排列num_cols个图像
    # 这里保存的是模型分布之中采样获取到的虚拟图像
    save_image(images, os.path.join(path, 'sample.png'), padding=2, nrow=num_cols)

    num_cols = 40
    # replay_buffer_old与replay_buffer是缓冲区相关的数据，初始的replay_buffer_old是随机采样的
    # images_diff用于保存replay_buffer_old和replay_buffer之间的差异       
    images_init = replay_buffer_old.cpu()
    images = replay_buffer.cpu()
    images_diff = replay_buffer.cpu() - replay_buffer_old.cpu()
    if step == 0:
        save_image(images_init, os.path.join(path, 'buffer_init.png'), padding=2, nrow=num_cols)
    save_image(images, os.path.join(path, 'buffer-' + str(counter) + "-" + str(step) + '.png'), padding=2,
               nrow=num_cols)  #
    save_image(images_diff, os.path.join(path, 'buffer_diff.png'), padding=2, nrow=num_cols)


@torch.enable_grad()  # ensure grads in possible no grad context for testing
def forward_and_adapt(x, energy_model, optimizer, replay_buffer, sgld_steps, sgld_lr, sgld_std, reinit_freq,
                      if_cond=False, n_classes=10):
    """Forward and adapt model on batch of data.
    Measure entropy of the model prediction, take gradients, and update params.
    """

    batch_size = x.shape[0]
    n_ch = x.shape[1]
    im_sz = x.shape[2]
    # batch_size = len(x)
    # n_ch = x[0].shape[0]
    # im_sz = x[0].shape[1]
    device = x.device

    if if_cond == 'uncond':
        x_fake, _ = sample_q(energy_model, replay_buffer,
        #                      n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std, reinit_freq=reinit_freq,
        #                      batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=None)
        # x_fake, _ = sample_odl(energy_model, replay_buffer,
                               n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std, reinit_freq=reinit_freq,
                               batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=None)
    elif if_cond == 'cond':
        y = torch.randint(0, n_classes, (batch_size,)).to(device)
        x_fake, _ = sample_q(energy_model, replay_buffer,
                             n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std, reinit_freq=reinit_freq,
                             batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=y)

    # forward
    out_real = energy_model(x)  # 真实样本的能量
    energy_real = out_real[0].mean()
    energy_fake = energy_model(x_fake)[0].mean()  # 假数据能量均值

    # adapt
    loss = (- (energy_real - energy_fake))  # 损失函数
    loss.backward()
    optimizer.step()
    optimizer.zero_grad()
    outputs = energy_model.classify(x)  # 调用能量模型实现分类

    return outputs


@torch.enable_grad()  # ensure grads in possible no grad context for testing
def forward_and_adapt_new(x, energy_model, optimizer, replay_buffer, sgld_steps, sgld_lr, sgld_std, reinit_freq,
                          if_cond=False, n_classes=10):
    """Forward and adapt model on batch of data.
    Measure entropy of the model prediction, take gradients, and update params.
    """

    # 获取批次大小
    batch_size = x.shape[0]
    # 获取通道数目
    n_ch = x.shape[1]
    # 获取图像尺寸
    im_sz = x.shape[2]
    # 获取设备新信息
    device = x.device
    # 如果条件是 'uncond'，即无条件生成，生成一个与输入数据形状相同的假样本 x_fake，调用 sample_q 函数从能量模型中采样，生成假样本。
    if if_cond == 'uncond':
        x_fake, _ = sample_q(energy_model, replay_buffer,
                             n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std, reinit_freq=reinit_freq,
                             batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=None)
    #   如果条件是 'cond'，即有条件生成：
    #   生成一个随机的类别标签 y，范围在 0 到 n_classes 之间
    elif if_cond == 'cond':
        y = torch.randint(0, n_classes, (batch_size,)).to(device)
        # 生成一个与输入数据形状相同的假样本 x_fake
        x_fake, _ = sample_q(energy_model, replay_buffer,
                             n_steps=sgld_steps, sgld_lr=sgld_lr, sgld_std=sgld_std, reinit_freq=reinit_freq,
                             batch_size=batch_size, im_sz=im_sz, n_ch=n_ch, device=device, y=y)

    # forward
    # 通过能量模型energy_model计算真实样本和假样本的能量，并求取平均值
    out_real = energy_model(x)
    '''
    这里调用energy_model()对输入图像x进行分类，与目标检测任务不一致，要重写energy部分代码
    '''

    energy_real = out_real[0].mean()
    energy_fake = energy_model(x_fake)[0].mean()

    # adapt
    # 计算损失值，这里的损失值是真实样本的能量减去假样本的能量的负值
    loss = (- (energy_real - energy_fake))
    # 根据损失值计算梯度，并使用优化器 optimizer 来更新模型的参数
    loss.backward()
    optimizer.step()
    # 梯度归零，以便下一次迭代。
    optimizer.zero_grad()
    # 使用能量模型对输入数据 x 进行分类，并返回分类结果 outputs
    outputs = energy_model.classify(x)

    return outputs


class Energy123(nn.Module):
    """
    Tent在测试过程中通过最小化熵来自适应模型，一旦经过tent处理，模型会在每次前向传播时自我调整
    Tent adapts a model by entropy minimization during testing.
    Once tented, a model adapts itself by updating on every forward.
    model：传入的原始模型。
    optimizer：优化器。
    steps：执行的步数，默认为1。
    episodic：一个布尔值，表示是否采用一种称为“episodic”的训练方式。
    buffer_size：重播缓冲区的大小。
    sgld_steps、sgld_lr、sgld_std：一些用于随机梯度 Langevin 动力学（SGLD）优化器的参数。
    reinit_freq：重置频率。
    if_cond：一个布尔值，表示是否使用条件模型。
    n_classes、im_sz、n_ch：类别数量、图像大小和通道数等模型参数。
    path：保存可视化图像的路径。
    logger：日志记录器。
    """

    def __init__(self, model, optimizer, steps=1, episodic=False,
                 buffer_size=10000, sgld_steps=20, sgld_lr=1, sgld_std=0.01, reinit_freq=0.05, if_cond=False,
                 n_classes=10, im_sz=32, n_ch=3, path=None, logger=None):
        super().__init__()

        self.energy_model = EnergyModel(model)
        self.replay_buffer = init_random(buffer_size, im_sz=im_sz, n_ch=n_ch)
        self.replay_buffer_old = deepcopy(self.replay_buffer)
        self.optimizer = optimizer
        self.steps = steps
        assert steps > 0, "tent requires >= 1 step(s) to forward and update"
        self.episodic = episodic

        self.sgld_steps = sgld_steps
        self.sgld_lr = sgld_lr
        self.sgld_std = sgld_std
        self.reinit_freq = reinit_freq
        self.if_cond = if_cond

        self.n_classes = n_classes
        self.im_sz = im_sz
        self.n_ch = n_ch

        self.path = path
        # self.logger = logger

        # note: if the model is never reset, like for continual adaptation,
        # then skipping the state copy would save memory
        self.model_state, self.optimizer_state = \
            copy_model_and_optimizer(self.energy_model, self.optimizer)

    def forward(self, x, if_adapt=True, counter=None, if_vis=False):
        if self.episodic:
            # 根据episodic来判定是否重置模型参数
            self.reset()
        # 根据if_adapt参数的值，它可能会在每次前向传播时更新模型参数
        # 则调用forward_and_adapt函数执行前向传播和模型参数更新
        # 如果设置了 if_vis 为 True，则在每个步骤中可视化一些图像。
        if if_adapt:
            for i in range(self.steps):
                outputs = forward_and_adapt_new(x, self.energy_model, self.optimizer,
                                                self.replay_buffer, self.sgld_steps, self.sgld_lr, self.sgld_std,
                                                self.reinit_freq,
                                                if_cond=self.if_cond, n_classes=self.n_classes)
                # if i % 1 == 0 and if_vis:
                #     visualize_images(path=self.path, replay_buffer_old=self.replay_buffer_old,
                #                      replay_buffer=self.replay_buffer, energy_model=self.energy_model,
                #                      sgld_steps=self.sgld_steps, sgld_lr=self.sgld_lr, sgld_std=self.sgld_std,
                #                      reinit_freq=self.reinit_freq,
                #                      batch_size=100, n_classes=self.n_classes, im_sz=self.im_sz, n_ch=self.n_ch,
                #                      device=x.device, counter=counter, step=i)
        else:
            self.energy_model.eval()
            with torch.no_grad():
                outputs = self.energy_model.classify(x)

        return outputs

    def reset(self):
        # 用于重置模型状态 将模型和优化器的状态加载回之前保存的状态。
        if self.model_state is None or self.optimizer_state is None:
            raise Exception("cannot reset without saved model/optimizer state")
        load_model_and_optimizer(self.energy_model, self.optimizer,
                                 self.model_state, self.optimizer_state)
