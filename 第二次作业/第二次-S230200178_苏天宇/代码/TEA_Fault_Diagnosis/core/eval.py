from core.data import load_data
import torch
import math
import numpy as np
import pandas as pd

import torch.nn.functional as F

threshold = 0.7


# 计算一个模型在给定数据集上的准确率
def clean_accuracy(model, x, y, batch_size=100, logger=None, device=None, ada=None, if_adapt=True, if_vis=False):
    if device is None:
        device = x.device
    acc = 0.
    # 计算迭代的批次数量，math.ceil函数通过对数据样本数量除以批量大小获得
    n_batches = math.ceil(x.shape[0] / batch_size)
    # 关闭梯度计算，防止在推理过程中进行梯度更新
    with torch.no_grad():
        # 批次迭代
        total = 0
        for counter in range(n_batches):
            # 切片当前批次的输入数据和标签
            x_curr = x[counter * batch_size:(counter + 1) * batch_size].to(device)
            y_curr = y[counter * batch_size:(counter + 1) * batch_size].to(device)
            # 根据 if_adapt 参数决定是否在每次前向传播时更新模型参数  或者说如果是source，那就相当于普通在验证集上进行验证了
            if ada == 'source':
                output = model(x_curr)

            else:
                output = model(x_curr, if_adapt=if_adapt)  # [32,10][batchsize,classes]
            # 返回准确率，通过除以输入数据的总样本数来得到准确率,
            # 尝试添加开集识别
            # _, predicted = torch.max(output, 1)
            # softmax_probs = F.softmax(output, dim=1)
            # max_probs, _ = torch.max(softmax_probs, 1)
            # # 假设低于阈值的预测为未知类别
            # predicted[max_probs < threshold] = 11
            # total += y_curr.size(0)
            # acc += (predicted == y_curr).sum()
            acc += (output.max(1)[1] == y_curr).float().sum()

    return acc.item() / x.shape[0]


def evaluate_ori(model, cfg, logger, device):
    try:
        model.reset()
        logger.info("resetting model")
    except:
        logger.warning("not resetting model")

    if 'CRWU' in cfg.DATASET.NAME:
        #  返回加载后的图像数据张量和标签数据张量

        x_test, y_test = load_data(cfg.DATASET.NAME, n_examples=cfg.DATASET.NUM_IMAGES,
                                   data_dir=cfg.DATASET.ROOT)
        x_test, y_test = x_test.to(device), y_test.to(device)
        out = clean_accuracy(model, x_test, y_test, cfg.OPTIM.BATCH_SIZE, logger=logger, ada=cfg.MODEL.ADAPTATION,
                             if_adapt=True, if_vis=False)
        if cfg.MODEL.ADAPTATION == 'energy':
            # acc, energes = out
            acc = out
        else:
            acc = out
        logger.info("Test set Accuracy: {}".format(acc))



