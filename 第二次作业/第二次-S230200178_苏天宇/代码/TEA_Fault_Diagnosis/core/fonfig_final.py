import argparse
import os
import sys
import math
from datetime import datetime
from iopath.common.file_io import g_pathmgr
from yacs.config import CfgNode as CfgNode

_C = CfgNode()
cfg = _C

# ---------------------------------- Misc options --------------------------- #
# Note that non-determinism is still present due to non-deterministic GPU ops
_C.RNG_SEED = 1

# Output directory 保存路径
_C.SAVE_DIR = "./output"

# Log destination (in SAVE_DIR)
_C.LOG_DEST = "log.txt"
# --------------------------------- CUDNN options --------------------------- #
_C.CUDNN = CfgNode()

# Benchmark to select fastest CUDNN algorithms (best for fixed input sizes)
_C.CUDNN.BENCHMARK = True

# ----------------------------- Model options ------------------------------- #
_C.MODEL = CfgNode()
_C.MODEL.EPISODIC = False
_C.MODEL.ARCH = 'Vgg16'  # 要修改
_C.MODEL.CLASSES = 7
# Choice of (source, norm, tent)
# - source: baseline without adaptation
# - norm: test-time normalization
# - tent: test-time entropy minimization (ours)
_C.MODEL.ADAPTATION = 'energy'
_C.MODEL.ADA_PARAM = ['conv']
_C.MODEL.WEIGHTS = r'G:\TEA_weights\best.pth'
# ------------------------------Dataset----------------------------------------#
_C.DATASET = CfgNode()
_C.DATASET.NAME = 'CRWU'
_C.DATASET.ROOT = r'G:\数据集\机械故障诊断数据集\CRWU_for_Use\1772_12K_load1_final\train\\'
_C.DATASET.IMG_SIZE = 224
_C.DATASET.NUM_CHANNEL=3
_C.DATASET.NUM_IMAGES = 980
# ------------------------------- Optimizer options ------------------------- #
_C.OPTIM = CfgNode()

# Number of updates per batch
_C.OPTIM.STEPS = 1

# Learning rate
_C.OPTIM.LR = 1e-3

# Batch size for evaluation (and updates for norm + tent)
_C.OPTIM.BATCH_SIZE = 32

# Choices: Adam, SGD
_C.OPTIM.METHOD = 'Adam'

# Beta
_C.OPTIM.BETA = 0.9

# Momentum
_C.OPTIM.MOMENTUM = 0.9

# Momentum dampening
_C.OPTIM.DAMPENING = 0.0

# Nesterov momentum
_C.OPTIM.NESTEROV = True

# L2 regularization
_C.OPTIM.WD = 0.0
# ------------------------------- TEA options --------------------------- #

_C.EBM = CfgNode()

_C.EBM.BUFFER_SIZE = 10000

_C.EBM.REINIT_FREQ = 0.05

_C.EBM.SGLD_LR = 1.0

_C.EBM.SGLD_STD = 0.01

_C.EBM.STEPS = 20

_C.EBM.UNCOND = "uncond"

# Data directory  数据路径
# _C.DATA_DIR = "/home/user/datasets"

# ------------------------------- PL options --------------------------- #

_C.PL = CfgNode()

_C.PL.THRESHOLD = 0.9

_C.PL.ALPHA = 0.1  # 1.0 10.0

def merge_from_file(cfg_file):
    with g_pathmgr.open(cfg_file, "r", encoding='utf-8') as f:
        cfg = _C.load_cfg(f)
    _C.merge_from_other_cfg(cfg)
