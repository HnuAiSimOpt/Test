# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : training_script.py
# @Author      : Alden_Chen
# @Time        : 2024/6/4 19:25
# @Software    : PyCharm
# @Description : 训练模型并保存，普通神经网络线性模型
# ------------------------------------------------------
import os
import pandas as pd
import torch
from torch import nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import numpy as np

# 加载数据函数
def load_data_from_folder(folder_path):
    trajectories = []
    for filename in os.listdir(folder_path):
        if filename.endswith('.csv'):
            file_path = os.path.join(folder_path, filename)
            df = pd.read_csv(file_path)
            traj = df[['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']].values
            trajectories.append(traj)
    return trajectories

# 创建训练对函数
def create_training_pairs(trajectories):
    training_pairs = []
    for traj in trajectories:
        n = len(traj)
        if n < 3:
            continue
        def add_pairs(start_idx, end_idx):
            if end_idx - start_idx < 2:
                return
            start_point = traj[start_idx]
            end_point = traj[end_idx]
            mid_idx = (start_idx + end_idx) // 2
            middle_point = traj[mid_idx]
            training_pairs.append((start_point, end_point, middle_point))
            add_pairs(start_idx, mid_idx)
            add_pairs(mid_idx, end_idx)
        add_pairs(0, n - 1)
    return training_pairs

class CustomDataset(Dataset):
    def __init__(self, data):
        self.data = data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        sample = self.data[idx]
        input_data = np.array([sample[0], sample[1]], dtype=np.float32)
        target_data = np.array(sample[2], dtype=np.float32)
        return torch.tensor(input_data), torch.tensor(target_data)

class SimpleNN(nn.Module):
    def __init__(self):
        super(SimpleNN, self).__init__()
        self.fc1 = nn.Linear(6, 128)
        self.fc2 = nn.Linear(128, 64)
        self.fc3 = nn.Linear(64, 3)

    def forward(self, x):
        x = x.view(-1, 6)
        x = torch.relu(self.fc1(x))
        x = torch.relu(self.fc2(x))
        x = self.fc3(x)
        return x

# 加载数据并创建训练对
folder_path = '../7_dataset_new'
trajectories = load_data_from_folder(folder_path)
training_pairs = create_training_pairs(trajectories)

# 创建数据集和数据加载器
dataset = CustomDataset(training_pairs)
dataloader = DataLoader(dataset, batch_size=2, shuffle=True)

# 定义模型、损失函数和优化器
model = SimpleNN()
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# 训练模型
epochs = 1000
for epoch in range(epochs):
    for inputs, targets in dataloader:
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, targets)
        loss.backward()
        optimizer.step()
    if epoch % 100 == 0:
        print(f'Epoch {epoch}, Loss: {loss.item()}')

# 保存模型
torch.save(model.state_dict(), '../this_is_model.pth')
print('Model saved as this_is_model.pth')
