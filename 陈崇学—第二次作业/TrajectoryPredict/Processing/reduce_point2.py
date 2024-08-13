# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : reduce_point.py
# @Author      : Alden_Chen
# @Time        : 2024/6/3 19:18
# @Software    : PyCharm 
# @Description : 提取减少误差点的数量并绘制可旋转的三维空间对比图
# ------------------------------------------------------
import os
import glob
import pandas as pd
import plotly.express as px
import plotly.io as pio

# 指定文件夹路径
input_folder_path = '5_dataset'
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

    # 将第一行作为初始参考点
    ref_point = df.iloc[0]
    filtered_data.append(ref_point)

    # 遍历CSV文件的每一行，从第二行开始
    for i in range(1, len(df)):
        # 获取当前行
        current_point = df.iloc[i]

        # 计算当前行与参考点的X, Y, Z坐标差异
        delta_x = abs(current_point['RightHandIndex3-Joint-Posi-x'] - ref_point['RightHandIndex3-Joint-Posi-x'])
        delta_y = abs(current_point['RightHandIndex3-Joint-Posi-y'] - ref_point['RightHandIndex3-Joint-Posi-y'])
        delta_z = abs(current_point['RightHandIndex3-Joint-Posi-z'] - ref_point['RightHandIndex3-Joint-Posi-z'])

        # 检查X, Y, Z的差异是否都超过0.003
        if delta_x >= 0.05 or delta_y >= 0.05 or delta_z >= 0.05:
            # 将满足条件的行添加到列表中，并更新参考点
            filtered_data.append(current_point)
            ref_point = current_point

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
    fig = px.scatter_3d(df, x='RightHandIndex3-Joint-Posi-x', y='RightHandIndex3-Joint-Posi-y', z='RightHandIndex3-Joint-Posi-z',
                        color_discrete_sequence=['blue'], opacity=0.5, title='Original Data')

    if not filtered_df.empty:
        fig.add_scatter3d(x=filtered_df['RightHandIndex3-Joint-Posi-x'], y=filtered_df['RightHandIndex3-Joint-Posi-y'],
                          z=filtered_df['RightHandIndex3-Joint-Posi-z'], mode='markers', marker=dict(color='red'),
                          name='Filtered Data')

    # 构建输出HTML文件路径
    plot_file_name = os.path.splitext(os.path.basename(csv_file))[0] + '_3d_comparison_plot.html'
    plot_file_path = os.path.join(output_folder_path + '/html', plot_file_name)

    # 保存图像为HTML文件
    pio.write_html(fig, file=plot_file_path, auto_open=True)

    # 打印图像保存信息
    print(f'可旋转的三维空间对比图已保存到 {plot_file_path}')
