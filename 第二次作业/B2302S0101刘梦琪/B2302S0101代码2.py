import pandas as pd
import matplotlib.pyplot as plt
import warnings
from math import sqrt
from sklearn.model_selection import train_test_split, cross_val_score, KFold
from sklearn.preprocessing import MinMaxScaler
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from bayes_opt import BayesianOptimization
import numpy as np

warnings.filterwarnings("ignore")
plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
pd.set_option('display.max_rows', 100, 'display.max_columns', 1000, "display.max_colwidth", 1000, 'display.width', 1000)

# 读取数据
data = pd.read_excel('Data.xlsx', sheet_name='Sheet1')

# 提取输入（特征）和输出（目标）列
X = data.iloc[:, 1:5].values  # 假设特征在第2到第5列
y = data.iloc[:, 5].values    # 假设目标在第6列

# 初始化MinMaxScaler
scaler = MinMaxScaler()

# 分割数据
x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=39)

# 对训练和测试数据进行缩放
x_train = scaler.fit_transform(x_train)
x_test = scaler.transform(x_test)

# 对目标数据进行缩放
y_train = scaler.fit_transform(y_train.reshape(-1, 1)).ravel()
y_test = scaler.transform(y_test.reshape(-1, 1)).ravel()

# 评价指标函数定义，其中R2的指标可以由模型自身得出，后面的score即为R2
def evaluation(model, X, y):
    kfold = KFold(n_splits=10, random_state=39, shuffle=True)
    scores = cross_val_score(model, X, y, cv=kfold, scoring='r2')
    return scores.mean()

# 定义优化目标
def bayesopt_objective(C, epsilon, gamma):
    model_SVR = SVR(C=int(C), epsilon=epsilon, gamma=gamma)
    r2 = evaluation(model_SVR, x_train, y_train)
    return r2

param_grid_simple = {
    'C': (1e-3, 3e3),
    'epsilon': (1e-3, 1),
    'gamma': (1e-3, 1e3)
}

# 定义优化目标函数的具体流程
def param_bayes_opt(init_points, n_iter):
    # 定义优化器，先实例化优化器
    opt = BayesianOptimization(
        bayesopt_objective,  # 需要优化的目标函数
        param_grid_simple,   # 备选参数空间
        random_state=412     # 随机数种子，虽然无法控制住
    )

    # 使用优化器，记住bayes_opt只支持最大化
    opt.maximize(init_points=init_points, n_iter=n_iter)

    # 优化完成，取出最佳参数与最佳分数
    params_best = opt.max["params"]
    score_best = opt.max["target"]

    # 打印最佳参数与最佳分数
    print("\n", "\n", "best params: ", params_best, "\n", "\n", "best cvscore: ", score_best)

    # 返回最佳参数与最佳分数
    return params_best, score_best

def bayes_opt_validation(**params_best):
    model_SVR = SVR(C=int(params_best['C']), epsilon=params_best['epsilon'], gamma=params_best['gamma'])
    model_SVR.fit(x_train, y_train)
    r2 = evaluation(model_SVR, x_test, y_test)
    return r2

# 运行优化
import time
start = time.time()
params_best, score_best = param_bayes_opt(100, 200)  # 初始看100个观测值，后面迭代200次
print('It takes %s minutes' % ((time.time() - start)/60))

# 验证最佳参数
validation_score = bayes_opt_validation(**params_best)
print("\n", "\n", "validation_score: ", validation_score)
