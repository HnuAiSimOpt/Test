import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, classification_report
from imblearn.over_sampling import SMOTE
from collections import Counter
from imblearn.over_sampling import ADASYN

def train_and_plot_svm_imbalanced(data, test_size=0.3, random_state=42):
    """
    训练支持向量机模型并绘制散点图和决策边界，处理类别不平衡问题。

    参数:
    data: pandas.DataFrame
        CSV文件的数据。
    test_size: float
        测试集的比例，默认为0.3。
    random_state: int
        随机状态，用于可重复的随机分割数据。

    返回:
    accuracy: float
        模型的准确率。
    """
    # 准备数据
    X = data.iloc[:, :2].values  # 特征
    y = data.iloc[:, -1].values   # 标签

    # 划分训练集和测试集
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

    # 检查类别分布
    class_counts = Counter(y_train)
    print(f"Class counts before over-sampling: {class_counts}")

    # 使用ADASYN进行过采样
    adasyn = ADASYN(random_state=random_state, n_neighbors=150)
    X_train_res, y_train_res = adasyn.fit_resample(X_train, y_train)

    # 检查过采样后的类别分布
    class_counts_res = Counter(y_train_res)
    print(f"Class counts after over-sampling: {class_counts_res}")

    # 创建SVM模型，调整C参数以处理不平衡数据
    model = SVC(kernel='rbf', gamma='auto', class_weight={0: 200.0, 1: 1.0})

    # 训练模型
    model.fit(X_train_res, y_train_res)

    # 预测测试集
    y_pred = model.predict(X_test)

    # 计算准确率
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Accuracy: {accuracy}")

    # 打印分类报告
    print(classification_report(y_test, y_pred))

    # 绘制散点图
    plt.figure(figsize=(10, 6))
    plt.scatter(X[y == 0, 0], X[y == 0, 1], label='Label 0', alpha=0.5)
    plt.scatter(X[y == 1, 0], X[y == 1, 1], label='Label 1', alpha=0.5)

    # 绘制决策边界
    x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
    y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, 0.1),
                         np.arange(y_min, y_max, 0.1))

    Z = model.predict(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)
    plt.contourf(xx, yy, Z, alpha=0.4)
    plt.title('Scatter Plot with Labels and Decision Boundary')
    plt.xlabel('Ego_Speed')
    plt.ylabel('Distance to Intersection')
    plt.legend()
    plt.show()

    return accuracy


def plot_scatter_from_csv(file_path):
    """
    根据CSV文件中的两列属性和标签生成散点图。
    参数:
    file_path: str
        CSV文件的路径。
    """
    # 显式设置matplotlib的后端
    matplotlib.use('TkAgg')

    # 读取CSV文件
    data = pd.read_csv(file_path)

    # 检查数据
    print(data.head())

    # 假设第一列是属性1，第二列是属性2，第三列是标签
    attribute1 = data.iloc[:, 0]  # 第一列
    attribute2 = data.iloc[:, 1]  # 第二列
    labels = data.iloc[:, -1].apply(lambda x: 'red' if x == 1 else 'blue')  # 根据标签设置颜色

    # 生成散点图
    plt.figure(figsize=(8, 6))
    plt.scatter(attribute1, attribute2, c=labels, edgecolors='k', s=50)

    # 添加标签
    plt.xlabel('Speed')
    plt.ylabel('Time Delay')
    plt.title('Scatter Plot with Labels')

    # 显示图形
    plt.show()

def plot_3d_scatter_from_csv(file_path):
    """
    根据CSV文件中的三列属性和标签生成3D散点图。

    参数:
    file_path: str
        CSV文件的路径。
    """
    # 显式设置matplotlib的后端
    plt.switch_backend('TkAgg')

    # 读取CSV文件
    data = pd.read_csv(file_path)

    # 检查数据
    print(data.head())

    # 假设前三列是属性，第四列是标签
    attribute1 = data.iloc[:, 0].values  # 第一列
    attribute2 = data.iloc[:, 1].values  # 第二列
    attribute3 = data.iloc[:, 2].values  # 第三列
    labels = data.iloc[:, -1].values  # 第四列

    # 根据标签值设置颜色
    colors = np.array(['blue' if x == 0 else 'red' for x in labels])

    # 创建3D图形和轴
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')

    # 生成3D散点图
    scatter = ax.scatter(attribute1, attribute2, attribute3, c=colors, edgecolors='k', s=50)

    # 添加标签
    ax.set_xlabel('Speed')
    ax.set_ylabel('Time Delay')
    ax.set_zlabel('Distance to intersection')
    plt.title('3D Scatter Plot with Labels')

    # 显示图形
    plt.show()

def color_intervals_by_label(data, interval_size_x=5, interval_size_y=5):
    """
    对第1列和第2列属性值域按固定区间分割，并按区间内是否有标签为0的点对区间涂色。

    参数:
    data: pandas.DataFrame
        CSV文件的数据。
    interval_size: float
        区间大小，默认为0.5。

    返回:
    matplotlib.pyplot.imshow()显示的图像。
    """
    # 假设第1列和第2列是属性，第3列是标签
    attribute1 = data.iloc[:, 0].values
    attribute2 = data.iloc[:, 1].values
    labels = data.iloc[:, -1].values

    # 计算区间数量
    num_intervals_x = int((max(attribute1) - min(attribute1)) / interval_size_x)
    num_intervals_y = int((max(attribute2) - min(attribute2)) / interval_size_y)

    # 初始化矩阵
    matrix = np.zeros((num_intervals_y + 1, num_intervals_x + 1))
    hazard_matrix=np.zeros((num_intervals_y + 1, num_intervals_x + 1))
    # 填充矩阵
    for i in range(len(data)):
        x_index = int((attribute1[i] - min(attribute1)) / interval_size_x)
        y_index = int((attribute2[i] - min(attribute2)) / interval_size_y)
        matrix[y_index, x_index]+=1
        hazard_matrix[y_index, x_index]+=labels[i]
    matrix= hazard_matrix/matrix
    print(matrix)
    # 计算颜色矩阵
    color_matrix = np.zeros((num_intervals_y + 1, num_intervals_x + 1, 3))
    color_matrix[matrix<0.95] = [1, 0, 0]  # 标签为0的点为红色
    color_matrix[matrix>=0.95] = [0, 1, 0]  # 标签为1的点为绿色
    color_matrix=np.rot90(color_matrix, k=2)
    # 绘制图像
    plt.imshow(color_matrix, extent=[min(attribute1), max(attribute1), min(attribute2), max(attribute2)])
    plt.colorbar(label='Labels')
    plt.xlabel('Speed')
    plt.ylabel('Distance to Intersection')
    plt.title('Colored Intervals by Label')
    plt.show()

    return color_matrix


def calculate_interval_ratio(data, interval_size_x=2, interval_size_y=2):
    """
    对第1列和第2列属性值域按固定区间分割，并计算每个区间内标签为0的点数与总点数的比例。

    参数:
    data: pandas.DataFrame
        CSV文件的数据。
    interval_size_x: int
        属性1的区间大小，默认为10。
    interval_size_y: int
        属性2的区间大小，默认为3。

    返回:
    pandas.DataFrame
        包含每个区间内标签为0的点数与总点数的比例的表格。
    """
    # 假设第1列和第2列是属性，第3列是标签
    attribute1 = data.iloc[:, 0].values
    attribute2 = data.iloc[:, 1].values
    labels = data.iloc[:, -1].values

    # 计算区间数量
    min_attr1 = min(attribute1)
    max_attr1 = max(attribute1)
    min_attr2 = min(attribute2)
    max_attr2 = max(attribute2)

    num_intervals_x = int((max_attr1 - min_attr1) // interval_size_x + 1)
    num_intervals_y = int((max_attr2 - min_attr2) // interval_size_y + 1)

    # 初始化矩阵
    count_matrix = np.zeros((num_intervals_y, num_intervals_x))
    zero_count_matrix = np.zeros((num_intervals_y, num_intervals_x))

    # 填充矩阵
    for i in range(len(data)):
        x_index = int((attribute1[i] - min_attr1) // interval_size_x)
        y_index = int((attribute2[i] - min_attr2) // interval_size_y)

        # 确保索引在矩阵的范围内
        if 0 <= x_index < num_intervals_x and 0 <= y_index < num_intervals_y:
            count_matrix[y_index, x_index] += 1
            if labels[i] == 0:
                zero_count_matrix[y_index, x_index] += 1

    # 计算比例
    ratio_matrix = zero_count_matrix / count_matrix

    # 创建区间标签
    interval_labels_x = [f"{min_attr1 + i * interval_size_x}" for i in range(num_intervals_x)]
    interval_labels_y = [f"{min_attr2 + i * interval_size_y}" for i in range(num_intervals_y)]

    # 将矩阵转换为DataFrame
    ratio_df = pd.DataFrame(ratio_matrix, index=interval_labels_y, columns=interval_labels_x)

    # 使用map计算每个区间内标签为0的点数与总点数的比例，并处理除以零的情况
    ratio_df = ratio_df.map(lambda x: x if np.isnan(x) else round(x, 2))

    # 保存为CSV文件
    ratio_df.to_csv('interval_ratio.csv', index_label=['Attribute 2'])

    return ratio_df

# 使用示例
file_path = '3d_table.csv'  # 替换为你的文件路径
#plot_scatter_from_csv(file_path)
#plot_3d_scatter_from_csv(file_path)
data = pd.read_csv(file_path)
#color_intervals_by_label(data)
#interval_ratio_df = calculate_interval_ratio(data)
accuracy = train_and_plot_svm_imbalanced(data)
