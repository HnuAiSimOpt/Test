# -*- coding: utf-8 -*-
# ------------------------------------------------------
# @File        : figure1.py
# @Author      : Alden_Chen
# @Time        : 2024/6/11 14:46
# @Software    : PyCharm 
# @Description :  误差阴影+折线图
# ------------------------------------------------------
import matplotlib.pyplot as plt
import numpy as np

# 生成数据
x = np.linspace(0, 10, 100)
y = np.sin(x)

# 创建一个新的图形
fig, ax = plt.subplots()

# 绘制主曲线
ax.plot(x, y, label='Main Curve', color='blue')
import matplotlib.pyplot as plt
import numpy as np

# 生成数据
x = np.linspace(0, 10, 100)
y = np.sin(x)

# 生成误差范围
y_upper = y + 0.2  # 上限
y_lower = y - 0.2  # 下限

# 定义不同饱和度的蓝色
main_color = '#1f77b4'  # 主曲线颜色（深蓝色）
shadow_color_1 = '#6baed6'  # 第一层阴影颜色（中蓝色）
shadow_color_2 = '#c6dbef'  # 第二层阴影颜色（浅蓝色）

# 创建一个新的图形
fig, ax = plt.subplots()

# 绘制主曲线
ax.plot(x, y, label='Main Curve', color=main_color)

# 绘制误差范围（阴影）
ax.fill_between(x, y_lower, y_upper, color=shadow_color_1, alpha=0.5, label='Confidence Interval 1')
ax.fill_between(x, y - 0.1, y + 0.1, color=shadow_color_2, alpha=0.3, label='Confidence Interval 2')

# 添加图例
ax.legend()

# 设置图表背景颜色为白色
fig.patch.set_facecolor('white')
ax.set_facecolor('white')

# 显示图形
plt.show()
