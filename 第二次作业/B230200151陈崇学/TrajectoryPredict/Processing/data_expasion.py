# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : data_expasion.py
# @Author      : Alden_Chen
# @Time        : 2024/5/21 20:49
# @Software    : PyCharm 
# @Description : 数据扩容
# ------------------------------------------------------

import pandas as pd
import numpy as np


name = 'CCX209'

# 读取CSV文件
df = pd.read_csv('2_segmentation_data/{}_increasing.csv'.format(name))

# 只保留所需的列
df = df[['Frame-No', 'RightHandIndex3-Joint-Posi-x', 'RightHandIndex3-Joint-Posi-y', 'RightHandIndex3-Joint-Posi-z']]

# 判断frame数是否大于400
if len(df) > 150:
    # 输出前400 frame 的数据为新的csv表格
    df_first_150 = df.iloc[:150]
    df_first_150.to_csv("3_data_expansion/{}_first_150.csv".format(name), index=False)
    print("前400序列完成，生成文件：{}_first_150.csv".format(name))

    # 从0至最后一个frame随机取400个frame，frame间隔不得大于10
    for i in range(10):
        sampled_frames = set()
        while len(sampled_frames) < 150:
            if len(sampled_frames) == 0:
                # 初始帧从0到10之间随机选择
                start_frame = np.random.randint(0, 10)
                sampled_frames.add(start_frame)
            else:
                # 之后的帧需要在上一个帧基础上增加0到5的随机数
                last_frame = max(sampled_frames)
                next_frame = last_frame + np.random.randint(1, 5)
                if next_frame < len(df):
                    sampled_frames.add(next_frame)
                else:
                    break

        # 如果集合中的帧数不足400个，则从0到最后帧中随机取帧，直到满400个
        while len(sampled_frames) < 150:
            next_frame = np.random.randint(0, len(df))
            sampled_frames.add(next_frame)

        # 确保只有400个帧并排序
        sampled_frames = sorted(sampled_frames)
        sampled_df = df.iloc[sampled_frames]
        sampled_df.to_csv("3_data_expansion/{}_sampled_{}.csv".format(name, i+1), index=False)
        print("随机序列完成，生成文件：{}_sampled_{}.csv".format(name, i+1))

else:
    print("帧数小于150，进行随机插值操作...")
    # 计算需要插值的次数
    num_interpolations = 150 - len(df)

    # 在相邻帧之间进行随机插值，直到满足400个帧
    for _ in range(num_interpolations):
        # 随机选择相邻的两个帧
        idx = np.random.randint(0, len(df) - 1)
        frame1 = df.iloc[idx]
        frame2 = df.iloc[idx + 1]

        # 计算两个帧之间的插值帧
        interpolated_frame = pd.Series({
            'Frame-No': (frame1['Frame-No'] + frame2['Frame-No']) / 2,
            'RightHandIndex3-Joint-Posi-x': (frame1['RightHandIndex3-Joint-Posi-x'] + frame2[
                'RightHandIndex3-Joint-Posi-x']) / 2,
            'RightHandIndex3-Joint-Posi-y': (frame1['RightHandIndex3-Joint-Posi-y'] + frame2[
                'RightHandIndex3-Joint-Posi-y']) / 2,
            'RightHandIndex3-Joint-Posi-z': (frame1['RightHandIndex3-Joint-Posi-z'] + frame2[
                'RightHandIndex3-Joint-Posi-z']) / 2,
        })

        # 将插值帧添加到DataFrame中，并重新分配帧编号
        interpolated_frame['Frame-No'] = frame1['Frame-No'] + 1
        df = pd.concat([df.iloc[:idx + 1], interpolated_frame.to_frame().T, df.iloc[idx + 1:]], ignore_index=True)
        df['Frame-No'] = df.index  # 重新分配帧编号

    # 将插值后的DataFrame写入CSV文件
    df.to_csv("3_data_expansion/{}_interpolated.csv".format(name), index=False)
    print("随机插值完成，生成文件：{}_interpolated.csv".format(name))



