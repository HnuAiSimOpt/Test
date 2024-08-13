import os
import random
import logging
import numpy as np
from torchvision import transforms, models
import torch
import torch.nn as nn
import torch.nn.functional as F
from copy import deepcopy

from core.model.wideresnet import WideResNet


#
# from torchmetrics.functional.image.lpips import Vgg16


# 设置随机种子，保证实验可复现
def set_seed(cfg):
    os.environ['PYTHONHASHSEED'] = str(cfg.RNG_SEED)
    random.seed(cfg.RNG_SEED)
    np.random.seed(cfg.RNG_SEED)
    torch.manual_seed(cfg.RNG_SEED)
    torch.cuda.manual_seed(cfg.RNG_SEED)
    torch.cuda.manual_seed_all(cfg.RNG_SEED)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = cfg.CUDNN.BENCHMARK


def set_logger(cfg):
    os.makedirs(cfg.SAVE_DIR, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="[%(asctime)s] [%(filename)s: %(lineno)4d]: %(message)s",
        datefmt="%y/%m/%d %H:%M:%S",
        handlers=[
            logging.FileHandler(os.path.join(cfg.SAVE_DIR, cfg.LOG_DEST)),
            logging.StreamHandler()
        ])

    logger = logging.getLogger(__name__)
    version = [torch.__version__, torch.version.cuda,
               torch.backends.cudnn.version()]
    logger.info(
        "PyTorch Version: torch={}, cuda={}, cudnn={}".format(*version))
    logger.info(cfg)


def load_model(model, num_classes):
    if model == "Vgg16":
        model = models.vgg16()
        model.classifier[6] = nn.Linear(model.classifier[6].in_features, num_classes)  # 修改输出层的维度
    elif model == "resnet":
        model = models.resnet50()
        num_features = model.fc.in_features
        model.fc = nn.Linear(num_features, num_classes)
    elif model == "wideresnet":
        model = WideResNet(28, num_classes, 10)

    return model
