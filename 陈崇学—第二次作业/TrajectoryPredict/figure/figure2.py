# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : figure2.py
# @Author      : Alden_Chen
# @Time        : 2024/6/11 14:46
# @Software    : PyCharm
# @Description :  误差阴影+折线图+三个子图
# ------------------------------------------------------
import pandas as pd
import matplotlib.pyplot as plt

# 读取CSV文件
file_path = '../Processing/8_Model/trajectory_trajectory.csv'
df = pd.read_csv(file_path)

# 提取实际轨迹和预测轨迹的X和Y列
actual_x = df['Actual_X'].dropna().values
actual_y = df['Actual_Y'].dropna().values
actual_z = df['Actual_Z'].dropna().values
predicted_x = df['Predicted_X'].dropna().values
predicted_y = df['Predicted_Y'].dropna().values
predicted_z = df['Predicted_Z'].dropna().values


# 误差
x_upper = 0
X_lower = 0
y_upper = actual_y + 0.05
y_lower = actual_y - 0.05
z_upper = 0
z_lower = 0

# 颜色
Color_A = '#126bae'
Color_B = '#5698c3'
Color_shadow = '#c6dbef'

# # 绘制平滑的实际轨迹和预测轨迹的2D图
# plt.figure()
# plt.plot(actual_x, actual_y, label='Actual Trajectory', color=Color_A)
# plt.plot(predicted_x, predicted_y, label='Predicted Trajectory', color=Color_B, linestyle='dashed')
# plt.xlabel('X')
# plt.ylabel('Y')
# plt.legend()
# plt.title('Smoothed 2D Trajectory Comparison')
# plt.show()

# 创建子图
fig, axs = plt.subplots(1, 3, figsize=(12, 4))


# 绘制XY视角的轨迹图
axs[0].plot(actual_x, actual_y, label='Actual Trajectory', color=Color_A)
axs[0].plot(predicted_x, predicted_y, label='Predicted Trajectory', color=Color_B, linestyle='dashed')
axs[0].set_xlabel('X')
axs[0].set_ylabel('Y')
axs[0].set_title('XY View')
# 绘制误差范围（阴影）
axs[0].fill_between(actual_x, y_lower, y_upper, color=Color_shadow, alpha=0.5, label='Experimental')
axs[0].legend()

# 绘制YZ视角的轨迹图
axs[1].plot(actual_y, actual_z, label='Actual Trajectory', color=Color_A)
axs[1].plot(predicted_y, predicted_z, label='Predicted Trajectory', color=Color_B, linestyle='dashed')
axs[1].set_xlabel('Y')
axs[1].set_ylabel('Z')
axs[1].set_title('YZ View')
axs[1].legend()

# 绘制ZX视角的轨迹图
axs[2].plot(actual_z, actual_x, label='Actual Trajectory', color=Color_A)
axs[2].plot(predicted_z, predicted_x, label='Predicted Trajectory', color=Color_B, linestyle='dashed')
axs[2].set_xlabel('Z')
axs[2].set_ylabel('X')
axs[2].set_title('ZX View')
axs[2].legend()

plt.tight_layout()
plt.show()