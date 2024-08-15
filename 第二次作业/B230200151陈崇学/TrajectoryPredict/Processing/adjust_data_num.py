# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : adjust_data_num.py
# @Author      : Alden_Chen
# @Time        : 2024/5/23 14:23
# @Software    : PyCharm 
# @Description : 统一每一个文件的frame编号为0-149
# ------------------------------------------------------

import os
import pandas as pd


def reindex_csv_files(input_folder, output_folder):
    # 检查输出文件夹是否存在，不存在则创建
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # 遍历输入文件夹中的所有CSV文件
    for filename in os.listdir(input_folder):
        if filename.endswith(".csv"):
            input_file = os.path.join(input_folder, filename)
            output_file = os.path.join(output_folder, filename)

            # 读取CSV文件
            df = pd.read_csv(input_file)

            # 重新编号Frame-No列，使其从0开始连续
            df['Frame-No'] = range(len(df))

            # 保存修改后的DataFrame到新的CSV文件
            df.to_csv(output_file, index=False)

            print(f"重新编号完成，生成文件：{output_file}")


# 输入文件夹路径
input_folder = '3_data_expansion'  # 修改为你的输入文件夹路径
output_folder = '4_adjust_frame_num_data'  # 修改为你的输出文件夹路径

reindex_csv_files(input_folder, output_folder)