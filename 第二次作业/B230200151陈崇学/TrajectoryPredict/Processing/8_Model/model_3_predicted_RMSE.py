# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : predict_lstm_model.py
# @Author      : Alden_Chen
# @Time        : 2024/6/3 21:14
# @Software    : PyCharm
# @Description : 使用训练好的LSTM模型进行轨迹预测
# ------------------------------------------------------
import os
import pandas as pd
import torch
import torch.nn as nn
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D
from sklearn.metrics import mean_squared_error

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

def load_model(model_path, input_size, hidden_size, intermediate_size, output_size, device):
    model = LSTMModel(input_size, hidden_size, intermediate_size, output_size)
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.to(device)
    model.eval()
    return model

def predict_middle_points(model, start_point, end_point, num_points, device):
    if num_points == 0:
        return []

    mid_idx = num_points // 2
    input_data = np.concatenate((start_point, end_point), axis=0)
    input_data = torch.tensor(input_data, dtype=torch.float32).unsqueeze(0).unsqueeze(0).to(device)
    middle_point = model(input_data).squeeze(0).cpu().detach().numpy()

    left_points = predict_middle_points(model, start_point, middle_point, mid_idx, device)
    right_points = predict_middle_points(model, middle_point, end_point, num_points - mid_idx - 1, device)

    return left_points + [middle_point] + right_points

def plot_3d_trajectory(actual_points, predicted_points):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    actual_points = np.array(actual_points)
    predicted_points = np.array(predicted_points)

    ax.plot(actual_points[:, 0], actual_points[:, 1], actual_points[:, 2], label='Actual', color='blue')
    ax.plot(predicted_points[:, 0], predicted_points[:, 1], predicted_points[:, 2], label='Predicted', color='red', linestyle='dashed')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    plt.legend()

    # 计算并输出RMSE误差
    rmse = np.sqrt(mean_squared_error(actual_points, predicted_points))
    print(f"RMSE (Root Mean Squared Error): {rmse:.4f}")

    plt.show()

def main():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Hyperparameters
    input_size = 6
    hidden_size = 10
    intermediate_size = 6
    output_size = 3
    model_path = 'trained_lstm_model.pth'

    # Load the trained model
    model = load_model(model_path, input_size, hidden_size, intermediate_size, output_size, device)

    # Load new data
    new_file_path = '../7_dataset_new/CCX4_sampled_5_filtered.csv'
    df = pd.read_csv(new_file_path)
    traj = df[['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']].values

    # Specify the number of middle points to predict
    num_points = 4

    # Extract start and end points
    start_point = traj[0]
    end_point = traj[-1]

    # Predict middle points using divide-and-conquer method
    predicted_points = [start_point] + predict_middle_points(model, start_point, end_point, num_points, device) + [end_point]

    # Plot the actual and predicted trajectory
    plot_3d_trajectory(traj, predicted_points)

if __name__ == '__main__':
    main()
