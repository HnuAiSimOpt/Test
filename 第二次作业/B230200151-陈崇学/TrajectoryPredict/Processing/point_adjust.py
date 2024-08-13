# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : point_adjust.py
# @Author      : Alden_Chen
# @Time        : 2024/5/21 19:30
# @Software    : PyCharm 
# @Description : 将肩关节位置调整为原点,当肩关节位置和第一次实验初始位置对不上的时候才需要调整
# ------------------------------------------------------
import csv

def adjust_points(input_file, output_file):
    with open(input_file, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        fieldnames = reader.fieldnames

        # 减去肩关节坐标
        offset_x = -0.029
        offset_y = 1.4932
        offset_z = 0

        with open(output_file, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()

            for row in reader:
                row['RightHandIndex3-Joint-Posi-x'] = str(float(row['RightHandIndex3-Joint-Posi-x']) - offset_x)
                row['RightHandIndex3-Joint-Posi-y'] = str(float(row['RightHandIndex3-Joint-Posi-y']) - offset_y)
                row['RightHandIndex3-Joint-Posi-z'] = str(float(row['RightHandIndex3-Joint-Posi-z']) - offset_z)

                writer.writerow(row)


name = "CCX209"
input_file = '../Data/Tra_{}_Point.csv'.format(name)
output_file = '1_after_adjust_data/Tra_{}_Point2Zero.csv'.format(name)
adjust_points(input_file, output_file)
