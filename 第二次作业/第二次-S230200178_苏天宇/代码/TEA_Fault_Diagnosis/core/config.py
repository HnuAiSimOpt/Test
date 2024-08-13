# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""Configuration file (powered by YACS)."""

import argparse
import os
import sys
import math
from datetime import datetime
from iopath.common.file_io import g_pathmgr
from yacs.config import CfgNode as CfgNode

# Global config object (example usage: from core.config import cfg)
_C = CfgNode()
cfg = _C

# ----------------------------- Model options ------------------------------- #
_C.MODEL = CfgNode()

# Check https://github.com/RobustBench/robustbench for available models
_C.MODEL.ARCH = 'Standard'

# Choice of (source, norm, tent)
# - source: baseline without adaptation
# - norm: test-time normalization
# - tent: test-time entropy minimization (ours)
_C.MODEL.ADAPTATION = 'source'

_C.MODEL.ADA_PARAM = ['bn']

# By default tent is online, with updates persisting across batches.
# To make adaptation episodic, and reset the model for each batch, choose True.
_C.MODEL.EPISODIC = False

# ----------------------------- Corruption options -------------------------- #
_C.CORRUPTION = CfgNode()

# Dataset for evaluation
_C.CORRUPTION.DATASET = 'cifar10'

_C.CORRUPTION.NUM_CLASSES = 10

_C.CORRUPTION.IMG_SIZE = 32

_C.CORRUPTION.NUM_CHANNEL = 3

# Check https://github.com/hendrycks/robustness for corruption details
_C.CORRUPTION.TYPE = ['gaussian_noise', 'shot_noise', 'impulse_noise',
                      'defocus_blur', 'glass_blur', 'motion_blur', 'zoom_blur',
                      'snow', 'frost', 'fog', 'brightness', 'contrast',
                      'elastic_transform', 'pixelate', 'jpeg_compression']
_C.CORRUPTION.SEVERITY = [5, 4, 3, 2, 1]

# Number of examples to evaluate (10000 for all samples in CIFAR-10)
_C.CORRUPTION.NUM_EX = 10000

# ------------------------------- Batch norm options ------------------------ #
_C.BN = CfgNode()

# BN epsilon
_C.BN.EPS = 1e-5

# BN momentum (BN momentum in PyTorch = 1 - BN momentum in Caffe2)
_C.BN.MOM = 0.1

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

# ------------------------------- Testing options --------------------------- #
_C.TEST = CfgNode()

# --------------------------------- CUDNN options --------------------------- #
_C.CUDNN = CfgNode()

# Benchmark to select fastest CUDNN algorithms (best for fixed input sizes)
_C.CUDNN.BENCHMARK = True

# ---------------------------------- Misc options --------------------------- #

# Optional description of a config
_C.DESC = ""

# Note that non-determinism is still present due to non-deterministic GPU ops
_C.RNG_SEED = 1

# Output directory 保存路径
_C.SAVE_DIR = "./output"

# Data directory  数据路径
_C.DATA_DIR = "/home/user/datasets"

# Weight directory  权重
_C.CKPT_DIR = "./ckpt"

# Log destination (in SAVE_DIR)
_C.LOG_DEST = "log.txt"

# Log datetime
_C.LOG_TIME = ''

# # Config destination (in SAVE_DIR)
# _C.CFG_DEST = "cfg.yaml"

# ------------------------------- TEA options --------------------------- #

_C.EBM = CfgNode()

_C.EBM.BUFFER_SIZE = 10000

_C.EBM.REINIT_FREQ = 0.05

_C.EBM.SGLD_LR = 1.0

_C.EBM.SGLD_STD = 0.01

_C.EBM.STEPS = 20

_C.EBM.UNCOND = "uncond"

# ------------------------------- EATA options --------------------------- #

_C.EATA = CfgNode()

# choose ETA or EATA
_C.EATA.USE_FISHER = False

# number of samples to compute fisher information matrix
_C.EATA.FISHER_SIZE = 2000

# the trade-off between entropy and regularization loss, in Eqn. (8)
_C.EATA.FISHER_ALPHA = 2000.0

# entropy margin E_0 in Eqn. (3) for filtering reliable samples
_C.EATA.E_MARGIN = math.log(1000) * 0.40

# epsilon in Eqn. (5) for filtering redundant samples
_C.EATA.D_MARGIN = 0.05

# ------------------------------- SAR options --------------------------- #

_C.SAR = CfgNode()

# the threshold for reliable minimization in SAR, Eqn. (2)
_C.SAR.MARGIN_E0 = math.log(1000) * 0.40

# ------------------------------- SHOT options --------------------------- #

_C.SHOT = CfgNode()

_C.SHOT.THRESHOLD = 0.9

_C.SHOT.CLF_COEFF = 0.1

# ------------------------------- PL options --------------------------- #

_C.PL = CfgNode()

_C.PL.THRESHOLD = 0.9

_C.PL.ALPHA = 0.1  # 1.0 10.0

# --------------------------------- Default config -------------------------- #
_CFG_DEFAULT = _C.clone()
_CFG_DEFAULT.freeze()


def assert_and_infer_cfg():
    """Checks config values invariants."""
    err_str = "Unknown adaptation method."
    assert _C.MODEL.ADAPTATION in ["source", "norm", "tent", "energy"]
    err_str = "Log destination '{}' not supported"
    assert _C.LOG_DEST in ["stdout", "file"], err_str.format(_C.LOG_DEST)


def merge_from_file(cfg_file):
    with g_pathmgr.open(cfg_file, "r") as f:
        cfg = _C.load_cfg(f)
    _C.merge_from_other_cfg(cfg)


def dump_cfg():
    """Dumps the config to the output directory."""
    cfg_file = os.path.join(_C.SAVE_DIR, _C.CFG_DEST)
    with g_pathmgr.open(cfg_file, "w") as f:
        _C.dump(stream=f)


def load_cfg(out_dir, cfg_dest="config.yaml"):
    """Loads config from specified output directory."""
    cfg_file = os.path.join(out_dir, cfg_dest)
    merge_from_file(cfg_file)


def reset_cfg():
    """Reset config to initial state."""
    cfg.merge_from_other_cfg(_CFG_DEFAULT)


def load_cfg_fom_args():
    """从命令行参数之中加载配置的函数"""
    """Load config from command line args and set any specified options."""
    '''
    获取当前时间并格式化为 %y%m%d-%H%M%S 的字符串格式。
    创建一个 argparse.ArgumentParser 对象来解析命令行参数，并添加了两个参数：--cfg 和 opts。--cfg 参数指定配置文件的位置，而 opts 参数可以用来指定其他选项。
    如果命令行参数为空，则打印帮助信息并退出程序。
    解析命令行参数并将结果存储在 args 中。
    根据解析得到的配置文件路径，调用 merge_from_file 函数来将配置文件中的配置合并到主配置对象 cfg 中。
    同样地，将命令行参数中指定的选项合并到主配置对象 cfg 中。
    根据配置文件中的设置，构建一个用于日志命名的字符串 log_dest。如果模型的适应性为 "energy"，则包含更多的设置信息。
    最后，设置日志时间和日志目的地，并将配置对象 cfg 冻结，使其不可修改。
    '''
    # 获取当前时间并且格式化
    current_time = datetime.now().strftime("%y%m%d-%H%M%S")
    parser = argparse.ArgumentParser(description='TTA Evalution')
    parser.add_argument("--cfg", dest="cfg_file", type=str, required=True,
                        help="Config file location")
    parser.add_argument("opts", default=None, nargs=argparse.REMAINDER,
                        help="See conf.py for all options")
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    args = parser.parse_args()

    merge_from_file(args.cfg_file)
    cfg.merge_from_list(args.opts)

    opt_list = [str(cfg.OPTIM.METHOD).lower(), str(cfg.OPTIM.STEPS), str(cfg.OPTIM.LR), str(cfg.OPTIM.BATCH_SIZE)]
    if cfg.MODEL.ADAPTATION == "energy":
        ebm_list = [str(cfg.EBM.UNCOND), str(cfg.EBM.STEPS), str(cfg.EBM.SGLD_LR), str(cfg.EBM.SGLD_STD),
                    str(cfg.EBM.BUFFER_SIZE), str(cfg.EBM.REINIT_FREQ)]
        log_dest = os.path.basename(args.cfg_file)
        log_dest = log_dest.replace('.yaml',
                                    '_{}_{}_{}_{}.txt'.format("-".join(cfg.MODEL.ADA_PARAM), "-".join(opt_list),
                                                              "-".join(ebm_list), current_time))
        # folder_name = "_".join(log_dest.split("_")[:-1])
        # cfg.SAVE_DIR = os.path.join(cfg.SAVE_DIR, folder_name)
        g_pathmgr.mkdirs(cfg.SAVE_DIR)
    else:
        log_dest = os.path.basename(args.cfg_file)
        log_dest = log_dest.replace('.yaml', '_{}_{}_{}.txt'.format("-".join(cfg.MODEL.ADA_PARAM), "-".join(opt_list),
                                                                    current_time))
    cfg.LOG_TIME, cfg.LOG_DEST = current_time, log_dest
    cfg.freeze()

