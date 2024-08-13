import torch
import torchvision
import torchvision.transforms as transforms
from torch.utils.data import DataLoader
from torchvision.datasets import CIFAR10
from torch import nn, optim
import matplotlib.pyplot as plt

# 定义超参数
num_epochs = 8  # 8,10,15
batch_size = 64
learning_rate = 0.001

# 转换函数
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
])

# 下载数据集
train_dataset = CIFAR10(root='./data', train=True, download=True, transform=transform)
test_dataset = CIFAR10(root='./data', train=False, download=True, transform=transform)

# 创建DataLoader
train_loader = DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
test_loader = DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False)


# 定义神经网络
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        # 定义网络结构
        self.conv1 = nn.Conv2d(3, 6, 5)  # 3个输入通道，6个输出通道，卷积核大小5x5
        self.pool = nn.MaxPool2d(2, 2)  # 最大池化，窗口大小2x2，步长2
        self.conv2 = nn.Conv2d(6, 16, 5)  # 第二层卷积，16个输出通道
        self.fc1 = nn.Linear(16 * 5 * 5, 120)  # 全连接层，120个神经元
        self.fc2 = nn.Linear(120, 84)  # 另一个全连接层，84个神经元
        self.fc3 = nn.Linear(84, 1)  # 最后的全连接层，1个输出神经元

    def forward(self, x):
        # 前向传播
        x = self.pool(torch.relu(self.conv1(x)))  # 第一次卷积和激活
        x = self.pool(torch.relu(self.conv2(x)))  # 第二次卷积和激活
        x = x.view(-1, 16 * 5 * 5)  # 展平特征图
        x = torch.relu(self.fc1(x))  # 第一次全连接和激活
        x = torch.relu(self.fc2(x))  # 第二次全连接和激活
        x = torch.sigmoid(self.fc3(x))  # 最后的全连接层，使用sigmoid激活函数
        return x


# 实例化模型
model = Net()

# 定义损失函数和优化器
criterion = nn.BCELoss()  # 二元交叉熵损失函数
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

# 训练和测试
train_losses, test_losses = [], []
train_accuracies, test_accuracies = [], []

for epoch in range(num_epochs):
    model.train()  # 设置模型为训练模式
    total_train_loss = 0
    correct_train_preds = 0
    total_train_samples = 0

    for images, labels in train_loader:
        # 将车辆设为正样本，其余为负样本
        labels = (labels == 1).float()  # 0 for non-vehicle, 1 for vehicle

        # 清空梯度
        optimizer.zero_grad()

        # 前向传播
        outputs = model(images)
        loss = criterion(outputs.squeeze(1), labels)

        # 反向传播和优化
        loss.backward()
        optimizer.step()

        # 累积损失和计算准确率
        total_train_loss += loss.item()
        # 计算准确率的代码...
        predicted = (outputs > 0.5).float()  # 假设阈值为0.5
        correct_train_preds += (predicted == labels).sum().item()
        total_train_samples += labels.size(0)
    train_losses.append(total_train_loss / len(train_loader))
    # 记录训练准确率的代码...
    train_accuracy = correct_train_preds / total_train_samples
    train_accuracies.append(train_accuracy)
    # 在测试集上评估模型
    model.eval()  # 设置模型为评估模式
    total_test_loss = 0
    correct_test_preds = 0
    total_test_samples = 0

    with torch.no_grad():
        for images, labels in test_loader:
            labels = (labels == 1).float()   # 0 for non-vehicle, 1 for vehicle
            outputs = model(images)
            total_test_loss += criterion(outputs.squeeze(1), labels).item()
            # 计算准确率的代码...
            predicted = (outputs > 0.5).float()
            correct_test_preds += (predicted == labels).sum().item()
            total_test_samples += labels.size(0)
        # 记录测试准确率的代码...
    test_accuracy = correct_test_preds / total_test_samples
    test_accuracies.append(test_accuracy)
    test_losses.append(total_test_loss / len(test_loader))


# 打印每个epoch的信息

    print(f'Epoch {epoch + 1}/{num_epochs}, Train Loss: {train_losses[-1]:.4f}, Train Acc: {train_accuracies[-1]:.4f}, '
          f'Test Loss: {test_losses[-1]:.4f}, Test Acc: {test_accuracies[-1]:.4f}')


# 绘制训练和测试损失曲线
plt.figure(figsize=(12, 4))
plt.subplot(1, 2, 1)
plt.plot(train_losses, label='Training Loss')
plt.plot(test_losses, label='Test Loss')
plt.title('Loss over epochs')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()

# 绘制训练和测试准确率曲线
plt.subplot(1, 2, 2)
plt.plot(train_accuracies, label='Training Accuracy')
plt.plot(test_accuracies, label='Test Accuracy')
plt.title('Accuracy over epochs')
plt.xlabel('Epochs')
plt.ylabel('Accuracy')
plt.legend()
plt.show()