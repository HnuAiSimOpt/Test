import numpy as np
import matplotlib.pyplot as plt
import torch
from torchvision import datasets, transforms

# %matplotlib inline
# %config InlineBackend.figure_format = 'svg'

# 训练参数
BATCH_SIZE=10 # 每个批次的大小
EPOCHS=5 # 总共训练的epoch数
lr = 1e-5
# 定义常量
x_dim = 28 * 28  # 输入维度
y_dim = 10       # 输出维度
W_dim = ((10, 28 * 28))  # 权重矩阵参数的维度
b_dim = y_dim           # 偏置向量参数的维度

"""下载训练集与测试集数据"""
train_loader = torch.utils.data.DataLoader(
        datasets.MNIST('data', # 数据集下载到本地后的根目录，包括 training.pt 和 test.pt 文件
                       train=True, # 设置为True，从training.pt创建数据集，否则会从test.pt创建
                       download=True, # 设置为True, 从互联网下载数据并放到root文件夹下
                       transform=transforms.Compose([
                           transforms.ToTensor(),
                           transforms.Normalize((0.1307,), (0.3081,)) # 一种函数或变换，输入PIL图片，返回变换之后的数据
                       ])),
        batch_size=BATCH_SIZE, shuffle=True)# 设置每个批次的大小，并设置进行随机打乱顺序的操作
test_loader = torch.utils.data.DataLoader(
        datasets.MNIST('data', # 数据集下载到本地后的根目录，包括 training.pt 和 test.pt 文件
                       train=False, # 设置为False，从test.pt创建数据集
                       transform=transforms.Compose([
                           transforms.ToTensor(),
                           transforms.Normalize((0.1307,), (0.3081,)) # 一种函数或变换，输入PIL图片，返回变换之后的数据
                       ])),
        batch_size=BATCH_SIZE, shuffle=True)# 设置每个批次的大小，并设置进行随机打乱顺序的操作


def loss_single(W, b, x, y):
    """
    计算单个样本损失函数的梯度
    W,b分别为当前的权重和偏置，x,y分别为样本数据和对应标签
    """
    # 初始化
    W_G = np.zeros(W.shape)
    b_G = np.zeros(b.shape)
    S = softmax(np.dot(W, x) + b)
    W_row = W.shape[0]
    W_column = W.shape[1]
    b_column = b.shape[0]

    # 对Wij求梯度
    for i in range(W_row):
        for j in range(W_column):
            W_G[i][j] = (S[i] - 1) * x[j] if y == i else S[i] * x[j]  # S: softmax函数 为什么没用到loss？求解过程中已经加入了
    # 对bi求梯度
    for i in range(b_column):
        b_G[i] = S[i] - 1 if y == i else S[i]
    return W_G, b_G


def test(W, b, data_loader):
    """
    测试逻辑回归模型分类的精度
    W和b为模型参数，data_loader为下载的测试集，包括输入数据和标签
    """
    results = []  # 保存每个批次的测试结果
    for data, target in data_loader:
        count_precision = 0  # 保存预测结果正确的个数
        for i in range(len(data)):
            pred = np.dot(W, data[i].reshape(x_dim)) + b
            pred = softmax(pred)  # 预测结果
            if target[i] == pred.argmax():
                count_precision += 1
        # print(count_precision)
        # print( len(data))
        # print(count_precision / len(data))
        results.append(count_precision / len(data))
    return np.mean(results)  # 返回分类精度


def softmax(x):
    """
    Softmax函数
    """
    return np.exp(x) / np.exp(x).sum()


def train(lr, epoches, train_dataset, test_dataset):
    """
    采用随机梯度法的逻辑回归模型的训练函数，包括训练以及计算在测试集精度
    lr为步长，epoches为epoch的数量
    """
    accurate_rates = []     # 记录每次迭代的正确率 accurate_rate
    iters_W = []    # 记录每次迭代的 W
    iters_b = []    # 记录每次迭代的 b

    W = np.zeros(W_dim)
    b = np.zeros(b_dim)
    for epoch in range(epoches):
        print("epoch:{}".format(epoch))
        batch_index=0
        for x_batch,y_batch in train_dataset:
            batch_index += 1
            print(f"Training Batch: {batch_index}/{len(train_dataset)}")

            batch_size = len(x_batch)
            j = np.random.randint(batch_size)  # 随机选择batch中某一个输入数据对应的梯度作为当前批次的梯度，从而对参数进行更新
            W_gradients, b_gradients = loss_single(W, b, x_batch[j].reshape(x_dim), y_batch[j])   # 计算该样本的梯度值

            # 采用随机梯度法更新参数：
            W -= lr * W_gradients
            b -= lr * b_gradients
            # 记录每个iteration之后W和b的值
            iters_W.append(W.copy())
            iters_b.append(b.copy())

        precision = test(W, b, test_dataset)
        # print(f"Precision of epoch {epoch} is {precision}.")
        accurate_rates.append(precision)
    return W, b, accurate_rates, iters_W, iters_b


W, b, precisions, W_s, b_s = train(lr, EPOCHS, train_loader, test_loader)
# 作图
plt.title('Stochastic Gradient Method')
plt.xlabel('Iterations')
plt.ylabel('Precision')
plt.plot(precisions)
plt.grid()
plt.show()

