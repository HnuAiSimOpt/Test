import torch
import torch.nn as nn
from collections import OrderedDict
from sd import sd, sdb
import scipy.io as scio
from visdom import Visdom
import time
import numpy as np


class DNN(nn.Module):
    def __init__(self, layer_param):
        super(DNN, self).__init__()
        self.depth = len(layer_param) - 1

        # set up layer order dict
        self.activation = torch.nn.Tanh

        layer_list = list()
        for i in range(self.depth - 1):
            layer_list.append(
                ('layer_%d' % i, torch.nn.Linear(layer_param[i], layer_param[i + 1]))
            )
        layer_list.append(
            ('layer_%d' % (self.depth - 1), torch.nn.Linear(layer_param[-2], layer_param[-1]))
        )
        # print(layer_list)
        layerDict = OrderedDict(layer_list)

        # deploy layers
        self.layers = torch.nn.Sequential(layerDict)

    def forward(self, x):
        for i in range(len(self.layers) - 1):
            x = torch.tanh(self.layers[i](x)) ** 3.
        out = self.layers[-1](x)
        return out


class Pinn(object):
    def __init__(self, layers=None, device=None):
        super(Pinn, self).__init__()
        if layers is None:
            layers = [2, 100, 100, 100, 2]
        if device is None:
            device = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
        self.device = device
        self.load = torch.tensor([0.5], requires_grad=True).to(self.device)
        self.u = DNN(layers).to(self.device)
        self.load = nn.Parameter(self.load)
        self.u.register_parameter('load', self.load)
        self.lambda1 = 12.115384615384615  # E=21 MPa v= 0.3 12.11538462
        self.miu = 8.076923077
        self.area = 1521.460184
        self.criterion = nn.MSELoss()
        self.f = torch.ones([200, 2]).to(self.device)
        self.f[:, 1] = 0
        self.optimizer = torch.optim.LBFGS(self.u.parameters(),
                                           lr=1,
                                           )

    def u_net(self, x):
        v = self.u(x)
        u = torch.zeros_like(v)
        u[:, 0:1] = v[:, 0:1] * (x[:, 0:1] + 20)
        u[:, 1:2] = v[:, 1:2] * (x[:, 0:1] + 20)  # * (4 - x[:, 0:1])
        return u

    def e_net(self, x):
        u = self.u_net(x)
        u1_x = torch.autograd.grad(u[:, 0], x, grad_outputs=torch.ones(u[:, 0].shape, device=torch.device('cuda:0')),
                                   create_graph=True, retain_graph=True, allow_unused=True)[0]  # dux/dx dux/dy
        u2_x = torch.autograd.grad(u[:, 1], x, grad_outputs=torch.ones(u[:, 1].shape, device=torch.device('cuda:0')),
                                   create_graph=True, retain_graph=True, allow_unused=True)[0]  # duy/dx duy/dy
        t1 = (self.lambda1 + 2. * self.miu) * u1_x[:, 0] + self.lambda1 * u2_x[:, 1]
        t2 = (self.lambda1 + 2. * self.miu) * u2_x[:, 1] + self.lambda1 * u1_x[:, 0]
        t12 = self.miu * (u1_x[:, 1] + u2_x[:, 0])
        energy = (t1 * u1_x[:, 0] + t2 * u2_x[:, 1] + t12 * (u1_x[:, 1] + u2_x[:, 0])) * 0.5
        return energy

    def loss_func(self, ):
        inputs = sd()
        inputs = torch.tensor(inputs, requires_grad=True).float().to(self.device)  # 自动微分
        inp_b = sdb()
        inp_b = torch.tensor(inp_b).float().to(self.device)
        energy = torch.sum(self.e_net(inputs)) * self.area / inputs.size(0) - \
                 torch.sum(self.u_net(inp_b) * self.f) * 0.2
        # loss = energy
        return energy

    def closures(self, ):
        self.optimizer.zero_grad()  # 清空梯度
        loss = self.loss_func()  # 计算损失
        loss.backward()  # 反向传播计算梯度
        # q = loss.item()
        return loss


    def train(self, num_epoch):
        viz = Visdom()
        viz.line([[0.0]], [0.], win='loss',
                 opts=dict(title='势能损失', legend=['势能损失', 'cost']))
        viz.line([0.0], [0.], win='learning rate',
                 opts=dict(title='lr', legend=['lr']))
        since0 = time.time()
        best_loss = 1e32
        file_1 = 'PINN_lowest2'  # 模型权重参数的保存名
        self.u.train()
        for epoch in range(num_epoch):
            since = time.time()
            print('epoch {}/{}'.format(epoch, num_epoch - 1))
            # for batch in dataloader:
            # loss = 0
            # with torch.no_grad():
            pd_loss = self.loss_func().item()
            if pd_loss < best_loss:  # 保存最优模型
                best_loss = pd_loss
                state = {
                    'state_dict': self.u.state_dict().copy(),
                }
                torch.save(state, file_1)
            loss = self.optimizer.step(self.closures)
            viz.line([[pd_loss]], [epoch], win='loss', update='append')
            viz.line([self.optimizer.param_groups[0]['lr']], [epoch], win='learning rate', update='append')
            time_elapsed = time.time() - since
            print('Time elapsed{:.0f}m {:.0f}s,'.format(time_elapsed // 60, time_elapsed % 60))
            print('loss:{:.6f}'.format(pd_loss))
            print('Optimizer learning rate : {:.7f}'.format(self.optimizer.param_groups[0]['lr']))
            print()

        time_elapsed = time.time() - since0
        print('Training complete in {:.0f}m {:.0f}s'.format(time_elapsed // 60, time_elapsed % 60))
        print('Best loss: {:4f}'.format(best_loss))

    def shuchu(self, ):
        file = 'PINN_lowest2'
        weight = torch.load(file)['state_dict']
        self.u.load_state_dict(weight)
        xy = torch.tensor(np.load('xy.npy')).float().to(self.device)
        uv = self.u_net(xy)
        uv = uv.detach().cpu().numpy()
        scio.savemat('up.mat', {'u': uv})


def main():
    model = Pinn()
    # model.train(10000)
    model.shuchu()



if __name__ == '__main__':
    main()

