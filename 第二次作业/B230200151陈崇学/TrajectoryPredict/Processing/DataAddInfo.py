# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : DataAddInfo.py
# @Author      : Alden_Chen
# @Time        : 2024/5/23 14:38
# @Software    : PyCharm 
# @Description : 添加受试者信息
# ------------------------------------------------------

import os
import pandas as pd


# 输入文件夹路径
input_folder = '4_adjust_frame_num_data'  # 修改为你的输入文件夹路径
output_folder = '5_dataset'  # 修改为你的输出文件夹路径

# 受试者信息
subject_info = {
    'arm_length': 28,  # 修改为你的受试者的arm_length
    'forearm_length': 24,  # 修改为你的受试者的forearm_length
    'hand_length': 18,  # 修改为你的受试者的hand_length
    'height': 168  # 修改为你的受试者的height
}


def add_subject_info_to_csv(input_folder, output_folder, subject_info):
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

            # 添加受试者信息到每一行
            for key, value in subject_info.items():
                df[key] = value

            # 保存修改后的DataFrame到新的CSV文件
            df.to_csv(output_file, index=False)

            print(f"添加受试者信息完成，生成文件：{output_file}")


add_subject_info_to_csv(input_folder, output_folder, subject_info)