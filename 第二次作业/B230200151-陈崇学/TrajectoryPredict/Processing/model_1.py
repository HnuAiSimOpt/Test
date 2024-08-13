# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : model_1.py
# @Author      : Alden_Chen
# @Time        : 2024/5/29 10:30
# @Software    : PyCharm 
# @Description : 
# ------------------------------------------------------

import os
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import matplotlib.pyplot as plt


class TrajectoryDataset(Dataset):
    def __init__(self, data):
        self.data = data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        seq = self.data[idx]
        return seq[:-1], seq[1:]


def load_and_preprocess_data(folder_path):
    data = []
    for file_name in os.listdir(folder_path):
        if file_name.endswith('.csv'):
            file_path = os.path.join(folder_path, file_name)
            df = pd.read_csv(file_path)
            coords = df[['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z',
                         'arm_length', 'forearm_length', 'hand_length', 'height']].values
            data.append(coords)
    return data


folder_path = '../Processing/5_dataset'
data = load_and_preprocess_data(folder_path)

# 归一化
scaler = MinMaxScaler()
normalized_data = [scaler.fit_transform(d) for d in data]

# 划分训练和测试集
train_data, test_data = train_test_split(normalized_data, test_size=0.2, random_state=42)

train_dataset = TrajectoryDataset(train_data)
test_dataset = TrajectoryDataset(test_data)

train_loader = DataLoader(train_dataset, batch_size=5, shuffle=True, drop_last=True)
test_loader = DataLoader(test_dataset, batch_size=5, shuffle=False, drop_last=True)


class TrajectoryLSTM(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers, output_size):
        super(TrajectoryLSTM, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
        out, _ = self.lstm(x, (h0, c0))
        out = self.fc(out)
        return out


# 设置参数
input_size = 7  # 3 (x,y,z) + 4 (arm_length, forearm_length, hand_length, height)
hidden_size = 50
num_layers = 2
output_size = 7
num_epochs = 100
learning_rate = 0.001

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = TrajectoryLSTM(input_size, hidden_size, num_layers, output_size).to(device)

# 损失函数和优化器
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

# 训练模型
model.train()
for epoch in range(num_epochs):
    for inputs, targets in train_loader:
        inputs = inputs.float().to(device)
        targets = targets.float().to(device)

        outputs = model(inputs)
        loss = criterion(outputs, targets)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

    print(f'Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item():.4f}')

# 预测和评估
model.eval()
predictions = []
actuals = []

with torch.no_grad():
    for inputs, targets in test_loader:
        inputs = inputs.float().to(device)
        targets = targets.float().to(device)

        outputs = model(inputs)
        predictions.append(outputs.cpu().numpy())
        actuals.append(targets.cpu().numpy())

# 转换为numpy数组
predictions = np.concatenate(predictions, axis=0)
actuals = np.concatenate(actuals, axis=0)

# 反归一化
predictions = scaler.inverse_transform(predictions.reshape(-1, 7)).reshape(predictions.shape)
actuals = scaler.inverse_transform(actuals.reshape(-1, 7)).reshape(actuals.shape)


# 读取实际的轨迹
def load_actual_trajectory(file_path):
    df = pd.read_csv(file_path)
    coords = df[['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z',
                 'arm_length', 'forearm_length', 'hand_length', 'height']].values
    return coords


actual_trajectory_file = '5_dataset/CCX3_sampled_8.csv'
actual_trajectory = load_actual_trajectory(actual_trajectory_file)

# 归一化实际轨迹
actual_trajectory_normalized = scaler.transform(actual_trajectory)

start_point = actual_trajectory_normalized[0]
end_point = actual_trajectory_normalized[-1]


def predict_trajectory(model, start_point, end_point, length):
    model.eval()
    sequence = [start_point]
    with torch.no_grad():
        for _ in range(length - 2):  # length includes start and end points
            input_seq = torch.tensor(sequence, dtype=torch.float32).unsqueeze(0).to(device)
            next_point = model(input_seq).squeeze(0)[-1].cpu().numpy()
            sequence.append(next_point)
        sequence.append(end_point)
    return np.array(sequence)


predicted_trajectory_normalized = predict_trajectory(model, start_point, end_point, len(actual_trajectory))

# 反归一化
predicted_trajectory = scaler.inverse_transform(predicted_trajectory_normalized)

# 反归一化实际轨迹
actual_trajectory = scaler.inverse_transform(actual_trajectory_normalized)


# 画图展示实际轨迹和预测轨迹
def plot_trajectory(predicted_trajectory, actual_trajectory):
    frames = np.arange(len(predicted_trajectory))

    fig, axs = plt.subplots(3, 1, figsize=(10, 15))

    # (frame, x)
    axs[0].plot(frames, actual_trajectory[:, 0], label='Actual', marker='o')
    axs[0].plot(frames, predicted_trajectory[:, 0], label='Predicted', marker='x')
    axs[0].set_title('Frame vs X')
    axs[0].set_xlabel('Frame')
    axs[0].set_ylabel('X')
    axs[0].legend()

    # (frame, y)
    axs[1].plot(frames, actual_trajectory[:, 1], label='Actual', marker='o')
    axs[1].plot(frames, predicted_trajectory[:, 1], label='Predicted', marker='x')
    axs[1].set_title('Frame vs Y')
    axs[1].set_xlabel('Frame')
    axs[1].set_ylabel('Y')
    axs[1].legend()

    # (frame, z)
    axs[2].plot(frames, actual_trajectory[:, 2], label='Actual', marker='o')
    axs[2].plot(frames, predicted_trajectory[:, 2], label='Predicted', marker='x')
    axs[2].set_title('Frame vs Z')
    axs[2].set_xlabel('Frame')
    axs[2].set_ylabel('Z')
    axs[2].legend()

    plt.tight_layout()
    plt.show()


plot_trajectory(predicted_trajectory, actual_trajectory)