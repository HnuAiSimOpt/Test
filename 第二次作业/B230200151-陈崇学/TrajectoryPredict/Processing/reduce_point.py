# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : reduce_point.py
# @Author      : Alden_Chen
# @Time        : 2024/6/3 19:18
# @Software    : PyCharm 
# @Description : 提取减少误差点的数量并绘制三维空间对比图
# ------------------------------------------------------
import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# 指定文件夹路径
input_folder_path = '6_DataTest'
output_folder_path = '7_dataset_new'

# 创建输出文件夹（如果不存在）
if not os.path.exists(output_folder_path):
    os.makedirs(output_folder_path)

# 获取文件夹中所有的CSV文件
csv_files = glob.glob(os.path.join(input_folder_path, '*.csv'))

# 遍历所有CSV文件
for csv_file in csv_files:
    # 读取CSV文件
    df = pd.read_csv(csv_file)

    # 初始化列表用于存储满足条件的行
    filtered_data = []

    # 遍历CSV文件的每一行，从第二行开始
    for i in range(1, len(df)):
        # 计算当前行与前一行的X, Y, Z坐标差异
        delta_x = abs(df.loc[i, 'RightHandIndex3-Joint-Posi-x'] - df.loc[i - 1, 'RightHandIndex3-Joint-Posi-x'])
        delta_y = abs(df.loc[i, 'RightHandIndex3-Joint-Posi-y'] - df.loc[i - 1, 'RightHandIndex3-Joint-Posi-y'])
        delta_z = abs(df.loc[i, 'RightHandIndex3-Joint-Posi-z'] - df.loc[i - 1, 'RightHandIndex3-Joint-Posi-z'])

        # 检查X, Y, Z的差异是否都超过0.003
        if delta_x >= 0.003 or delta_y >= 0.003 or delta_z >= 0.003:
            # 将满足条件的行添加到列表中
            filtered_data.append(df.loc[i])

    # 将满足条件的行转换为DataFrame
    filtered_df = pd.DataFrame(filtered_data)

    # 构建新的文件名和路径
    new_file_name = os.path.splitext(os.path.basename(csv_file))[0] + '_filtered.csv'
    new_file_path = os.path.join(output_folder_path, new_file_name)

    # 保存结果到新的CSV文件
    filtered_df.to_csv(new_file_path, index=False)

    # 打印完成信息
    print(f'采样完成，结果已保存到{new_file_path}')

    # 绘制过滤前后的三维空间散点图
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')

    # 绘制原始数据的三维散点图
    ax.scatter(df['RightHandIndex3-Joint-Posi-x'], df['RightHandIndex3-Joint-Posi-y'], df['RightHandIndex3-Joint-Posi-z'], label='Original', color='blue', alpha=0.5)

    # 绘制过滤后的数据的三维散点图
    if not filtered_df.empty:
        ax.scatter(filtered_df['RightHandIndex3-Joint-Posi-x'], filtered_df['RightHandIndex3-Joint-Posi-y'], filtered_df['RightHandIndex3-Joint-Posi-z'], label='Filtered', color='red')

    # 添加图例和标题
    ax.legend()
    ax.set_title(f'Comparison of Original and Filtered Data for {os.path.basename(csv_file)}')
    ax.set_xlabel('X Position')
    ax.set_ylabel('Y Position')
    ax.set_zlabel('Z Position')

    # 保存图像
    plot_file_name = os.path.splitext(os.path.basename(csv_file))[0] + '_3d_comparison_plot.png'
    plot_file_path = os.path.join(output_folder_path, plot_file_name)
    plt.savefig(plot_file_path)
    plt.close()

    # 打印图像保存信息
    print(f'三维空间对比图已保存到 {plot_file_path}')
