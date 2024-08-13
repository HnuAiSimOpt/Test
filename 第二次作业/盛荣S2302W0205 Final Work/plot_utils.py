import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import random

def save_pareto_front_data(iteration, path, pop_Elite, frontno_Parent):
    """
    保存帕累托前沿数据到Excel和CSV文件，并标注前沿编号
    """
    try:
        df = pd.DataFrame(pop_Elite)
        df['Pareto Front'] = frontno_Parent
        df_sorted = df.sort_values(by=['Pareto Front'])
        df_sorted.to_excel(f"{path}/pop_all_{iteration+1}.xlsx", index=False)
    except Exception as e:
        print(f"Error saving data: {e}")

def plot_3d_scatter(ax, front, color, marker, iteration):
    """
    绘制3D散点图,用于 plot_3d_pareto_fronts
    """
    ax.scatter3D(front[:, 0], front[:, 1], front[:, 2],
                 color=color, s=50, marker=marker, alpha=0.8,
                 label=f'Iteration {iteration}')
    ax.set_xlabel('Neutron', fontsize=12)
    ax.set_ylabel('Photon', fontsize=12)
    ax.set_zlabel('Weight', fontsize=12)
    ax.legend()

def plot_3d_pareto_fronts(it, path, front):
    """
    绘制每次迭代的帕累托前沿，并保存图像
    """
    color_marker_map = {
        0: ('grey', 'o'),
        1: ('darkgrey', 'o'),
        50: ('blue', '+'),
        100: ('green', '^'),
        150: ('red', 's'),
        200: ('black', '*')
    }
    color_marker_pairs = list(color_marker_map.values())
    color, marker = random.choice(color_marker_pairs)
    fig = plt.figure(num=it, figsize=(8, 5))
    ax = plt.axes(projection='3d')
    plot_3d_scatter(ax, front, color, marker, it)
    plt.savefig(f"{path}/iteration{it+1}.png", format='png')
    plt.close(fig)  # 关闭图形窗口

def plot_scatter(it, front, path):
    """
    绘制2D散点图，并保存图像
    """
    # 图表参数
    params = [
        (0, 1, "Neutron", "Photon"),
        (0, 2, "Neutron", "Weight"),
        (1, 2, "Photon", "Weight")
    ]

    plt.figure(figsize=(15, 5))  # 创建一个图窗口，大小设置为15x5

    # 循环绘制每个散点图
    for i, (x_idx, y_idx, xlabel, ylabel) in enumerate(params):
        plt.subplot(1, 3, i + 1)  # 创建1行3列的子图，第i+1个位置
        plt.scatter(front[:, x_idx], front[:, y_idx], color='r')
        plt.xlabel(xlabel)
        plt.ylabel(ylabel)

    plt.tight_layout()  # 自动调整子图布局
    plt.savefig(f"{path}/scatter_plot_iteration{it+1}.png", format='png')

def plot_confidence_interval(Samples_Parent, front, path):
    """
    绘制采样值的置信区间，并保存图像
    """
    plt.figure(num=45)
    
    # 第一个子图: Pareto前沿
    plt.subplot(1,2,1)
    plt.scatter(front[:,11], front[:,12], color='r')
    plt.xlabel("Neutron")
    plt.ylabel("Photon")

    # 第二个子图: 样本的最大值
    plt.subplot(1,2,2)
    max_values = np.max(Samples_Parent, axis=0)
    plt.scatter(max_values[:,0], max_values[:,1], color='b')
    plt.xlabel("Neutron")
    plt.ylabel("Photon")

    plt.savefig(f"{path}/pareto_front_max_values.png", format='png')

    # 根据均值对样本进行排序
    Samples_Parent_mean = np.mean(Samples_Parent, axis=0, dtype=None, keepdims=False)  # 预测均值
    Samples_Parent_std = np.std(Samples_Parent, axis=0, dtype=None, keepdims=False)
    asc_index = np.argsort(Samples_Parent_mean, 0)  # 升序索引
    y_samp_sort_0 = Samples_Parent_mean[asc_index[:,0]]  # 第一个维度的升序排列
    y_samp_sort_1 = Samples_Parent_mean[asc_index[:,1]]  # 第二个维度的升序排列
    y_samp_sort_2 = Samples_Parent_mean[asc_index[:,2]]  # 第三个维度的升序排列

    # 绘制95%置信区间填充图
    titles = ['Confidence Interval of Neutron', 'Confidence Interval of Photon', 'Confidence Interval of Weight']
    y_labels = ['Objective Neutron Value', 'Objective Photon Value', 'Objective Weight Value']
    y_samp_sort = [y_samp_sort_0, y_samp_sort_1, y_samp_sort_2]

    for i in range(3):
        plt.figure(num=46 + i)
        x = np.arange(len(y_samp_sort[i]))
        plt.fill_between(x, y_samp_sort[i][:,i] - Samples_Parent_std[:,i], y_samp_sort[i][:,i] + Samples_Parent_std[:,i],
                         color='b', alpha=0.2, label='Confidence interval')
        plt.xlabel('Sample Index')
        plt.ylabel(y_labels[i])
        plt.title(titles[i])
        plt.legend()
        plt.savefig(f"{path}/confidence_interval_{i}.png", format='png')

    plt.show()  # 确保在运行完代码后图形窗口不关闭
