import pandas as pd
import matplotlib.pyplot as plt

import warnings
warnings.filterwarnings("ignore")
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
pd.set_option('display.max_rows', 100,'display.max_columns', 1000,"display.max_colwidth",1000,'display.width',1000)
from sklearn.metrics import *
from sklearn.preprocessing import *
from math import sqrt
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn.svm import SVR
import numpy as np
# 评价指标函数定义，其中R2的指标可以由模型自身得出，后面的score即为R2
def evaluation(model):
    ypred = model.predict(x_test)
    mae = mean_absolute_error(y_test, ypred)
    mse = mean_squared_error(y_test, ypred)
    rmse = sqrt(mse)
    r2 = r2_score(y_test, ypred)  # 均方误差/方差
    print("MAE: %.4f" % mae)
    print("MSE: %.4f" % mse)
    print("RMSE: %.4f" % rmse)
    print("R^2: %.4f" % r2)
    return ypred
def plot_scatter_with_lines(Exp_Life_D, Pre_Life_D):
    plt.figure(figsize=(8, 6))
    # 绘制散点图
    plt.loglog(Exp_Life_D, Pre_Life_D, marker='o', linestyle='', markersize=5, color='red')
    # 添加图例，设置图例字体
    # 绘制虚线
    plt.plot([3 * 10 ** 3, 10 ** 6], [10 ** 3, 3.5 * 10 ** 5], linestyle='--', linewidth=1.5, color='k')
    plt.plot([10 ** 3, 3.5 * 10 ** 5], [3 * 10 ** 3, 10 ** 6], linestyle='--', linewidth=1.5, color='k')
    plt.plot([2 * 10 ** 3, 10 ** 6], [10 ** 3, 5 * 10 ** 5], linestyle='--', color='r')
    plt.plot([10 ** 3, 5 * 10 ** 5], [2 * 10 ** 3, 10 ** 6], linestyle='--', color='r')

    plt.xlabel('Experimental life (Cycles)', fontsize=12, fontname='Times New Roman')
    plt.ylabel('Predicted life (Cycles)', fontsize=12, fontname='Times New Roman')
    plt.ylim([1e3, 1e6])
    plt.xlim([1e3, 1e6])
    plt.show()

data = pd.read_excel('Data.xlsx', sheet_name='Sheet1')
X = data.iloc[:, 1:5].values  # Assuming features are in columns 3 to 7
y = data.iloc[:, 5].values     # Assuming target is in the second column

# Split the data
x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=31)
# Initialize StandardScaler
#scaler = StandardScaler()
scaler = MinMaxScaler()
x_train = scaler.fit_transform(x_train)
x_test = scaler.transform(x_test)
# Fit the scaler on the training target data and transform both the training and testing target data
y_train = scaler.fit_transform(y_train.reshape(-1, 1)).ravel()
y_test = scaler.transform(y_test.reshape(-1, 1)).ravel()

# SVR模型
# 创建SVR模型并设置超参数
svr_model = SVR(
    C=2117.14,              # 正则化参数
    epsilon=0.0059,        # 损失函数中对误差的容忍度
    gamma=19.2573,      # 'scale'表示使用样本特征的标准差的倒数作为gamma值
    kernel='rbf'      # rbf 0.6360 linear 0.0185 poly -2129 sigmoid -33359845 precomputed
)


svr_model.fit(x_train, y_train)
print("SVR")
print("params: ", svr_model.get_params())
print("train score: ", svr_model.score(x_train, y_train))
print("test score: ", svr_model.score(x_test, y_test))


y_train_pred = svr_model.predict(x_train)
y_train_pred_D = np.abs(scaler.inverse_transform(np.array(y_train_pred).reshape(1, -1)).astype(int))
y_train_D = np.abs(scaler.inverse_transform(np.array(y_train).reshape(1, -1)).astype(int))

Pre_Life_D = np.abs(scaler.inverse_transform(evaluation(svr_model).reshape(1, -1)).astype(int))
Exp_Life_D = np.abs(scaler.inverse_transform(np.array(y_test).reshape(1, -1)).astype(int))

Exp_Life = np.concatenate((y_train_D, Exp_Life_D), axis=1)
Pre_Life = np.concatenate((y_train_pred_D, Pre_Life_D), axis=1)

plot_scatter_with_lines(Exp_Life, Pre_Life)