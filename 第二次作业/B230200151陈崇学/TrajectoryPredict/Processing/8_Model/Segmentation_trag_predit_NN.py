# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : prediction_script.py
# @Author      : Alden_Chen
# @Time        : 2024/6/4 19:25
# @Software    : PyCharm
# @Description : 加载简单的NN模型并进行预测,
# ------------------------------------------------------
import torch
from torch import nn
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


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


# 加载训练好的模型
model = SimpleNN()
model.load_state_dict(torch.load('../this_is_model.pth'))
model.eval()


# 分治法预测函数
def predict_trajectory(model, start_point, end_point, num_predictions):
    def recursive_predict(start_point, end_point, depth):
        if depth == 0:
            return []
        input_data = np.array([start_point, end_point], dtype=np.float32).flatten()
        input_tensor = torch.tensor(input_data).view(1, -1)
        with torch.no_grad():
            middle_point = model(input_tensor).numpy().flatten()
        left_points = recursive_predict(start_point, middle_point, depth - 1)
        right_points = recursive_predict(middle_point, end_point, depth - 1)
        return left_points + [middle_point] + right_points

    # 计算预测深度
    depth = int(np.ceil(np.log2(num_predictions + 1)))
    predicted_points = recursive_predict(start_point, end_point, depth)
    return [start_point] + predicted_points + [end_point]


# 读取新的轨迹数据
def load_new_trajectory(file_path):
    df = pd.read_csv(file_path)
    trajectory = df[
        ['RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']].values
    return trajectory


# 绘制3D对比图
def plot_trajectories(actual, predicted):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')

    actual = np.array(actual)
    ax.plot(actual[:, 0], actual[:, 1], actual[:, 2], label='Actual Trajectory', color='b')

    predicted = np.array(predicted)
    ax.plot(predicted[:, 0], predicted[:, 1], predicted[:, 2], label='Predicted Trajectory', color='r')

    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    ax.set_zlabel('Z')
    ax.legend()
    plt.show()


# 示例使用
new_trajectory_path = '../7_dataset_new/CCX201_sampled_3_filtered.csv'
new_trajectory = load_new_trajectory(new_trajectory_path)

start_point = new_trajectory[0]
end_point = new_trajectory[-1]
num_predictions = 7  # 指定预测的点数

predicted_points = predict_trajectory(model, start_point, end_point, num_predictions)
print("Predicted points:", predicted_points)

plot_trajectories(new_trajectory, predicted_points)
