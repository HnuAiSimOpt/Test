# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : model.py
# @Author      : Alden_Chen
# @Time        : 2024/6/3 21:14
# @Software    : PyCharm
# @Description : 测试模型文件
# ------------------------------------------------------
import os
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import torch
import torch.nn as nn
import torch.optim as optim
import matplotlib.pyplot as plt
import numpy as np

def load_data_from_folder(folder_path):
    trajectories = []
    for filename in os.listdir(folder_path):
        if filename.endswith('.csv'):
            file_path = os.path.join(folder_path, filename)
            df = pd.read_csv(file_path)
            # 只提取有用的三个坐标
            traj = df[
                ['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']].values
            trajectories.append(traj)
    return trajectories

def prepare_data(trajectories):
    scaler = MinMaxScaler()
    scaled_trajectories = []

    for traj in trajectories:
        traj = scaler.fit_transform(traj)
        scaled_trajectories.append(traj)

    return scaled_trajectories, scaler

# 指定存放CSV文件的文件夹路径
folder_path = '../7_dataset_new'
trajectories = load_data_from_folder(folder_path)
scaled_trajectories, scaler = prepare_data(trajectories)


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

            # 递归生成左半部分和右半部分的训练对
            add_pairs(start_idx, mid_idx)
            add_pairs(mid_idx, end_idx)

        add_pairs(0, n - 1)

    return training_pairs


training_pairs = create_training_pairs(scaled_trajectories)

class LSTMModel(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(LSTMModel, self).__init__()
        self.hidden_size = hidden_size
        self.lstm = nn.LSTM(input_size, hidden_size, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        h_0 = torch.zeros(1, x.size(0), self.hidden_size).to(x.device)
        c_0 = torch.zeros(1, x.size(0), self.hidden_size).to(x.device)
        out, _ = self.lstm(x, (h_0, c_0))
        out = self.fc(out[:, -1, :])
        return out

def train_model(model, criterion, optimizer, training_pairs, num_epochs=100):
    model.train()
    for epoch in range(num_epochs):
        epoch_loss = 0
        for start_point, end_point, target in training_pairs:
            start_point = torch.tensor(start_point, dtype=torch.float32).unsqueeze(0).unsqueeze(0)
            end_point = torch.tensor(end_point, dtype=torch.float32).unsqueeze(0).unsqueeze(0)
            input_data = torch.cat((start_point, end_point), dim=1)
            target = torch.tensor(target, dtype=torch.float32).unsqueeze(0)

            optimizer.zero_grad()
            output = model(input_data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()

            epoch_loss += loss.item()

        print(f'Epoch [{epoch+1}/{num_epochs}], Loss: {epoch_loss/len(training_pairs):.4f}')


# Hyperparameters
input_size = 3  # 输入维度
hidden_size = 50  # 隐藏层维度
output_size = 3  # 输出维度
learning_rate = 0.01
num_epochs = 200

# Initialize model, loss, and optimizer
model = LSTMModel(input_size, hidden_size, output_size)
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

# Train the model
train_model(model, criterion, optimizer, training_pairs, num_epochs)


def predict_trajectory(start_point, end_point, model, scaler, num_points):
    model.eval()
    predicted_trajectory = [start_point] + [[None, None, None]] * (num_points - 2) + [end_point]

    def recursive_predict(start_idx, end_idx):
        if end_idx - start_idx < 2:
            return

        start_point_tensor = torch.tensor(predicted_trajectory[start_idx], dtype=torch.float32).unsqueeze(0).unsqueeze(
            0)
        end_point_tensor = torch.tensor(predicted_trajectory[end_idx], dtype=torch.float32).unsqueeze(0).unsqueeze(0)
        input_data = torch.cat((start_point_tensor, end_point_tensor), dim=1)

        with torch.no_grad():
            middle_point = model(input_data)

        middle_point = middle_point.squeeze().numpy()
        mid_idx = (start_idx + end_idx) // 2
        predicted_trajectory[mid_idx] = middle_point.tolist()

        # 递归预测左半部分和右半部分的中间点
        recursive_predict(start_idx, mid_idx)
        recursive_predict(mid_idx, end_idx)

    recursive_predict(0, num_points - 1)

    predicted_trajectory = scaler.inverse_transform(predicted_trajectory)
    return predicted_trajectory


# Example usage for prediction
start_point = trajectories[0][0]
end_point = trajectories[0][-1]
start_point_scaled = scaler.transform([start_point])[0]
end_point_scaled = scaler.transform([end_point])[0]
# num_points = len(trajectories[0])
predicted_trajectory = predict_trajectory(start_point_scaled, end_point_scaled, model, scaler, num_points=10)

# 将实际轨迹和预测轨迹可视化
predicted_trajectory = np.array(predicted_trajectory)
actual_trajectory = np.array(trajectories[0])

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(actual_trajectory[:, 0], actual_trajectory[:, 1], actual_trajectory[:, 2], c='r', label='Actual Trajectory')
ax.scatter(predicted_trajectory[:, 0], predicted_trajectory[:, 1], predicted_trajectory[:, 2], c='b', label='Predicted Trajectory')
ax.legend()
plt.show()
