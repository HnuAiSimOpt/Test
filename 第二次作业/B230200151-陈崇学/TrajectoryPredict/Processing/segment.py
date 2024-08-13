# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : segment.py
# @Author      : Alden_Chen
# @Time        : 2024/5/21 20:49
# @Software    : PyCharm
# @Description : 数据分割,判断依据，按照X\Y\Z中变化趋势判断,只包含手指坐标，不含其他关节。
# ------------------------------------------------------

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os


name = "CCX209"

# 使用绝对路径
path = os.path.abspath("../Processing/1_after_adjust_data/Tra_{}_Point2Zero.csv".format(name))
# path = os.path.abspath("../Data/Tra_{}_Point.csv".format(name))

df = pd.read_csv(path)

# 只保留所需的列
df = df[['Frame-No', 'RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']]

# 创建图形和子图
fig, axs = plt.subplots(3, 1, figsize=(6, 8))  # 调整图形大小

# 绘制 x、y、z 与 Frame-No 的关系
axs[0].plot(df['Frame-No'], df['RightHandIndex3-Joint-Posi-x'], label='RightHandIndex3-Joint-Posi-x')
axs[0].set_xlabel('Frame-No')
axs[0].set_ylabel('RightHandIndex3-Joint-Posi-x')
axs[0].set_title('RightHandIndex3-Joint-Posi-x vs Frame-No')
axs[0].grid(True)
axs[0].legend()

axs[1].plot(df['Frame-No'], df['RightHandIndex3-Joint-Posi-y'], label='RightHandIndex3-Joint-Posi-y')
axs[1].set_xlabel('Frame-No')
axs[1].set_ylabel('RightHandIndex3-Joint-Posi-y')
axs[1].set_title('RightHandIndex3-Joint-Posi-y vs Frame-No')
axs[1].grid(True)
axs[1].legend()

axs[2].plot(df['Frame-No'], df['RightHandIndex3-Joint-Posi-z'], label='RightHandIndex3-Joint-Posi-z')
axs[2].set_xlabel('Frame-No')
axs[2].set_ylabel('RightHandIndex3-Joint-Posi-z')
axs[2].set_title('RightHandIndex3-Joint-Posi-z vs Frame-No')
axs[2].grid(True)
axs[2].legend()

# 保存和显示图像
plt.tight_layout()
# plt.savefig('{}_Index3-Joint-Posi_vs_Frame-No.png'.format(name))
plt.show()

# 用户输入选择分割数据依据的列
column_map = {
    'x': 'RightHandIndex3-Joint-Posi-x',
    'y': 'RightHandIndex3-Joint-Posi-y',
    'z': 'RightHandIndex3-Joint-Posi-z'
}

column_short = input("请选择分割数据依据的列 (x, y, z): ").strip().lower()

if column_short not in column_map:
    print("输入无效，请输入 'x', 'y' 或 'z'")
    exit()

column = column_map[column_short]

# 查找最大值索引位置
max_idx = df[column].idxmax()

# 判断最大值两边各10个数是否分别小于或大于这个数
def validate_split_point(df, column, max_idx):
    if max_idx < 10 or max_idx > len(df) - 11:
        return False
    left_valid = all(df[column].iloc[max_idx - 10:max_idx] < df[column].iloc[max_idx])
    right_valid = all(df[column].iloc[max_idx + 1:max_idx + 11] < df[column].iloc[max_idx])
    return left_valid and right_valid

if validate_split_point(df, column, max_idx):
    split_index = max_idx + 1
else:
    print("无法找到合适的分割点")
    exit()

# 分割数据
increasing_df = df.iloc[:split_index]
decreasing_df = df.iloc[split_index:]

# 输出分割后的数据为新的csv文件
os.makedirs("2_segmentation_data", exist_ok=True)
increasing_df.to_csv("2_segmentation_data/{}_increasing.csv".format(name), index=False)
decreasing_df.to_csv("2_segmentation_data/{}_decreasing.csv".format(name), index=False)

print("数据已分割并保存为 \n 2_segmentation_data/{}_increasing.csv 和 2_segmentation_data/{}_decreasing.csv".format(name, name))
