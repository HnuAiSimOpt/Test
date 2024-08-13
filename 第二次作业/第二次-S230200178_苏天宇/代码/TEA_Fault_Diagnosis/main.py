import os
import logging
from core.eval import evaluate_ori
from core.utils import load_model
from torchmetrics.functional.image.lpips import Vgg16
from core.fonfig_final import merge_from_file, cfg
import torch
from core.utils import set_seed, set_logger
from core.setada import *

logger = logging.getLogger(__name__)


def main():
    merge_from_file(r'G:\TEA_Fault_Diagnosis\cfg\CRWU_TINY\energy_conv.yaml')
    # 设置随机数种子
    set_seed(cfg)
    set_logger(cfg)
    # 设备
    device = torch.device('cuda:0')
    # 加载模型
    # print(cfg.MODEL.ARCH)
    if 'Vgg' in cfg.MODEL.ARCH:
        if cfg.DATASET.NAME == 'CRWU' and cfg.MODEL.ARCH == 'Vgg16':
            model = 'Vgg16'
            base_model = load_model(model, cfg.MODEL.CLASSES)
            # 加载权重
            if cfg.MODEL.WEIGHTS is not None:
                base_model.load_state_dict(torch.load(cfg.MODEL.WEIGHTS))
    elif "resnet" in cfg.MODEL.ARCH:
        if cfg.DATASET.NAME == 'CRWU' and cfg.MODEL.ARCH == 'resnet':
            model = 'resnet'
            base_model = load_model(model, cfg.MODEL.CLASSES)
            # 加载权重
            if cfg.MODEL.WEIGHTS is not None:
                base_model.load_state_dict(torch.load(cfg.MODEL.WEIGHTS))
    elif "wideresnet" in cfg.MODE.ARCH:
        if cfg.DATASET.NAME == 'CRWU' and cfg.MODEL.ARCH == 'wideresnet':
            model = 'wideresnet'
            base_model = load_model(model, cfg.MODEL.CLASSES)
    else:
        raise NotImplementedError
    # 基于能量的TTA方法
    if cfg.MODEL.ADAPTATION == 'source':
        logger.info("test-time adaptation:None")
        model = setup_source(base_model, cfg, logger).to(device)
    elif cfg.MODEL.ADAPTATION == "energy":
        logger.info("test-time adaptation: ENERGY")
        model = setup_energy(base_model, cfg, logger).to(device)
    # 基于归一化的TTA方法
    elif cfg.MODEL.ADAPTATION == "norm":
        logger.info("test-time adaptation: NORM")
        model = setup_norm(base_model, cfg, logger).to(device)
    # 基于伪标签的TTA方法
    elif cfg.MODEL.ADAPTATION == "pl":
        logger.info("test-time adaptation: PL")
        model = setup_pl(base_model, cfg, logger).to(device)
    else:
        raise NotImplementedError
    # 在原始数据上进行评估
    evaluate_ori(model, cfg, logger, device)


if __name__ == "__main__":
    main()
