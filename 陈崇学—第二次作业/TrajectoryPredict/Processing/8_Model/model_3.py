# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : predict_lstm_model.py
# @Author      : Alden_Chen
# @Time        : 2024/6/3 21:14
# @Software    : PyCharm
# @Description : LSTM模型+递归分治法 训练脚本
# ------------------------------------------------------

import os
import pandas as pd
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
            traj = df[['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']].values
            if len(traj) > 0:
                trajectories.append(traj)
    return trajectories

# Load data from folder
folder_path = '../7_dataset_new'
trajectories = load_data_from_folder(folder_path)

def create_training_pairs(trajectories):
    training_pairs = []

    def add_pairs(traj, start_idx, end_idx):
        if end_idx - start_idx < 2:
            return

        start_point = traj[start_idx]
        end_point = traj[end_idx]
        mid_idx = (start_idx + end_idx) // 2
        middle_point = traj[mid_idx]

        training_pairs.append((start_point, end_point, middle_point))

        add_pairs(traj, start_idx, mid_idx)
        add_pairs(traj, mid_idx, end_idx)

    for traj in trajectories:
        add_pairs(traj, 0, len(traj) - 1)

    return training_pairs

# Create training pairs
training_pairs = create_training_pairs(trajectories)

class LSTMModel(nn.Module):
    def __init__(self, input_size, hidden_size, intermediate_size, output_size):
        super(LSTMModel, self).__init__()
        self.hidden_size = hidden_size
        self.lstm = nn.LSTM(input_size, hidden_size, batch_first=True)
        self.fc_intermediate = nn.Linear(hidden_size, intermediate_size)
        self.fc_output = nn.Linear(intermediate_size, output_size)

    def forward(self, x):
        h_0 = torch.zeros(1, x.size(0), self.hidden_size).to(x.device)
        c_0 = torch.zeros(1, x.size(0), self.hidden_size).to(x.device)
        out, _ = self.lstm(x, (h_0, c_0))
        out = self.fc_intermediate(out[:, -1, :])
        out = self.fc_output(out)
        return out

def train_model(model, criterion, optimizer, training_pairs, num_epochs=100, batch_size=32):
    model.train()
    epoch_losses = []

    for epoch in range(num_epochs):
        np.random.shuffle(training_pairs)
        epoch_loss = 0
        for i in range(0, len(training_pairs), batch_size):
            batch_pairs = training_pairs[i:i + batch_size]
            if len(batch_pairs) == 0:
                continue

            inputs = []
            targets = []

            for start_point, end_point, target in batch_pairs:
                # 将起点和终点拼接成6维输入
                input_data = np.concatenate((start_point, end_point), axis=0)
                inputs.append(input_data)
                targets.append(target)

            inputs = torch.tensor(inputs, dtype=torch.float32).unsqueeze(1)
            targets = torch.tensor(targets, dtype=torch.float32)

            inputs = inputs.to(device)
            targets = targets.to(device)

            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()

            epoch_loss += loss.item()

        epoch_loss_avg = epoch_loss / len(training_pairs)
        epoch_losses.append(epoch_loss_avg)
        print(f'Epoch [{epoch + 1}/{num_epochs}], Loss: {epoch_loss_avg:.4f}')

    return epoch_losses

# Set device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Hyperparameters
input_size = 6  # 因为输入是拼接的起点和终点
hidden_size = 10
intermediate_size = 6  # 中间全连接层的输出大小
output_size = 3
learning_rate = 0.01
num_epochs = 100

# Initialize model, loss, and optimizer
model = LSTMModel(input_size, hidden_size, intermediate_size, output_size).to(device)
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

# Train the model
epoch_losses = train_model(model, criterion, optimizer, training_pairs, num_epochs)

# Plot training loss
plt.plot(epoch_losses)
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Training Loss over Epochs')
plt.show()

# Save the trained model
torch.save(model.state_dict(), 'trained_lstm_model.pth')
print('Model saved to trained_lstm_model.pth')
