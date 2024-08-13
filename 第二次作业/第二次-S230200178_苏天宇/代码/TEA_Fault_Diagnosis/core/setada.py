import torchvision
import torch.nn as nn
import torch.optim as optim
import core.adazoo.norm as norm

from core.energy import Energy
from core.optim import setup_optimizer
import core.adazoo.pl as pl

# 不进行测试时自适应
def setup_source(model, cfg, logger):
    """Set up the baseline source model without adaptation."""
    model.eval()
    logger.info(f"model for evaluation: %s", model)
    return model

def setup_norm(model, cfg, logger):
    """Set up test-time normalization adaptation.
    Adapt by normalizing features with test batch statistics.
    The statistics are measured independently for each batch;
    no running average or other cross-batch estimation is used.
    """
    norm_model = norm.Norm(model)
    logger.info(f"model for adaptation: %s", model)
    stats, stat_names = norm.collect_stats(model)
    logger.info(f"stats for adaptation: %s", stat_names)
    return norm_model


def configure_model(model, ada_param=None):
    "tent 就是测试熵最小化"
    """Configure model for use with tent."""
    # 如果ada中包含字符串‘all’就直接返回没有修改的模型
    if 'all' in ada_param:
        return model

    # train mode, because tent optimizes the model to minimize entropy
    model.train()
    # 禁用梯度，只有'tent'更新的部分会重新启用梯度
    # disable grad, to (re-)enable only what tent updates
    model.requires_grad_(False)

    if 'bn' in ada_param:
        # 如果ada_param的内容包含'bn',对所有的BatchNrom2d启用梯度，并强制使用批次统计数据
        # configure norm for model updates: enable grad + force batch statisics
        for m in model.modules():  # 遍历模型模块
            if isinstance(m, nn.BatchNorm2d):
                m.requires_grad_(True)  # 启用梯度
                # force use of batch stats in train and eval modes
                # 不跟踪运行时的统计数据
                m.track_running_stats = False
                # 强制使用批次统计数据
                m.running_mean = None
                m.running_var = None

    if 'gn' in ada_param:
        # 对所有的GroupNorm层启用梯度，并强制使用批次统计数据。
        # configure norm for model updates: enable grad + force batch statisics
        for m in model.modules():
            if isinstance(m, nn.GroupNorm):
                m.requires_grad_(True)
                # force use of batch stats in train and eval modes
                m.track_running_stats = False
                m.running_mean = None
                m.running_var = None

    if 'in' in ada_param:
        # 对所有的InstanceNorm2d层启用梯度，并强制使用批次统计数据
        # configure norm for model updates: enable grad + force batch statisics
        for m in model.modules():
            if isinstance(m, nn.InstanceNorm2d):
                m.requires_grad_(True)
                # force use of batch stats in train and eval modes
                m.track_running_stats = False
                m.running_mean = None
                m.running_var = None

    if 'conv' in ada_param:
        # 对所有的Conv2d层启用梯度
        for m in model.modules():
            if isinstance(m, nn.Conv2d):
                m.requires_grad_(True)

    if 'fc' in ada_param:
        # 则对所有的Linear层启用梯度。
        for m in model.modules():
            if isinstance(m, nn.Linear):
                m.requires_grad_(True)
    # 返回配置后的模型
    return model


def collect_params(model, ada_param='fc', logger=None):
    # 收集仿射缩放+位移参数  遍历模型的模块并收集所有批归一化参数。返回参数及其名称
    """Collect the affine scale + shift parameters from batch norms.
    Walk the model's modules and collect all batch normalization parameters.
    Return the parameters and their names.
    Note: other choices of parameterization are possible!
    """
    params = []
    names = []

    if 'all' in ada_param:
        logger.info('adapting all weights')
        return model.parameters(), 'all'

    if 'bn' in ada_param:
        logger.info('adapting weights of batch-normalization layer')
        for nm, m in model.named_modules():
            if isinstance(m, nn.BatchNorm2d):
                for np, p in m.named_parameters():
                    if np in ['weight', 'bias']:  # weight is scale, bias is shift
                        params.append(p)
                        names.append(f"{nm}.{np}")

    if 'gn' in ada_param:
        logger.info('adapting weights of group-normalization layer')
        for nm, m in model.named_modules():
            if isinstance(m, nn.GroupNorm):
                for np, p in m.named_parameters():
                    if np in ['weight', 'bias']:  # weight is scale, bias is shift
                        params.append(p)
                        names.append(f"{nm}.{np}")

    if 'in' in ada_param:
        logger.info('adapting weights of instance-normalization layer')
        for nm, m in model.named_modules():
            if isinstance(m, nn.InstanceNorm2d):
                for np, p in m.named_parameters():
                    print(np)
                    exit(0)
                    if np in ['weight', 'bias']:  # weight is scale, bias is shift
                        params.append(p)
                        names.append(f"{nm}.{np}")

    if 'conv' in ada_param:
        logger.info('adapting weights of conv layer')
        for nm, m in model.named_modules():
            if isinstance(m, nn.Conv2d):
                for np, p in m.named_parameters():
                    if np in ['weight', 'bias']:  # weight is scale, bias is shift
                        params.append(p)
                        names.append(f"{nm}.{np}")
    if 'fc' in ada_param:
        logger.info('adapting weights of fully-connected layer')
        for nm, m in model.named_modules():
            if isinstance(m, nn.Linear):
                for np, p in m.named_parameters():
                    if np in ['weight', 'bias']:  # weight is scale, bias is shift
                        params.append(p)
                        names.append(f"{nm}.{np}")
    return params, names


def setup_energy(model, cfg, logger):
    # def setup_energy(model, cfg, logger):
    """
    Set up TEA adaptation.
    """
    # 冻结相关层
    model = configure_model(model, ada_param=cfg.MODEL.ADA_PARAM)
    # 收集仿射缩放+位移参数  遍历模型的模块并收集所有批归一化参数。返回参数及其名称
    params, param_names = collect_params(model, ada_param=cfg.MODEL.ADA_PARAM, logger=logger)
    # 设置迭代器来减小测试时熵
    optimizer = setup_optimizer(params, cfg, logger)
    # 能量模型
    energy_model = Energy(model, optimizer,
                          steps=cfg.OPTIM.STEPS,
                          episodic=cfg.MODEL.EPISODIC,
                          buffer_size=cfg.EBM.BUFFER_SIZE,
                          sgld_steps=cfg.EBM.STEPS,
                          sgld_lr=cfg.EBM.SGLD_LR,
                          sgld_std=cfg.EBM.SGLD_STD,
                          reinit_freq=cfg.EBM.REINIT_FREQ,
                          if_cond=cfg.EBM.UNCOND,
                          n_classes=cfg.MODEL.CLASSES,
                          im_sz=cfg.DATASET.IMG_SIZE,
                          n_ch=cfg.DATASET.NUM_CHANNEL,
                          path=cfg.SAVE_DIR,
                          logger=logger
                          )
    logger.info(f"model for adaptation: %s", model)
    logger.info(f"params for adaptation: %s", param_names)
    logger.info(f"optimizer for adaptation: %s", optimizer)
    return energy_model


def setup_pl(model, cfg, logger):
    """Set up SHOT adaptation.
    """
    adapt_model = pl.PseudoLabel(model,
                                 steps=cfg.OPTIM.STEPS,
                                 threshold=cfg.PL.THRESHOLD,
                                 alpha=cfg.PL.ALPHA,
                                 lr=cfg.OPTIM.LR,
                                 wd=cfg.OPTIM.WD)
    logger.info(f"model for adaptation: %s", model)
    return adapt_model
