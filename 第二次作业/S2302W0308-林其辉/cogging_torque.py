import numpy as np
import pandas as pd
import os
import matplotlib.pyplot as plt
# import seaborn as sns
from scipy import stats
from scipy.stats import norm, skew
from scipy.special import boxcox1p
from scipy.stats import boxcox_normmax
from sklearn.model_selection import KFold, cross_val_score
from sklearn.preprocessing import LabelEncoder
from sklearn.linear_model import ElasticNet, Lasso, BayesianRidge, LassoLarsIC
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.kernel_ridge import KernelRidge
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import RobustScaler
from sklearn.base import BaseEstimator, TransformerMixin, RegressorMixin, clone
# from mlxtend.regressor import StackingCVRegressor, StackingRegressor
# from sklearn.model_selection import KFold, cross_val_score, train_test_split
# from sklearn.metrics import mean_squared_error
# import xgboost as xgb
# import lightgbm as lgb
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.svm import SVR
from sklearn.linear_model import Ridge, Lasso, LogisticRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, LeaveOneOut, cross_val_score
from sklearn.metrics import mean_squared_error, r2_score
from sklearn import linear_model
from sklearn.ensemble import GradientBoostingRegressor, AdaBoostRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.gaussian_process.kernels import RBF, ConstantKernel as C, ConstantKernel
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error
from sklearn.ensemble import BaggingRegressor
from sklearn.tree import ExtraTreeRegressor
# from bayes_opt import BayesianOptimization
from sklearn import model_selection
# from ImprovedModel import NewHybridModel
from scipy.stats import pearsonr
from scipy.stats import spearmanr
import matplotlib.pyplot as plt
# import seaborn as sns
import pandas as pd
import numpy as np
from sklearn.linear_model import SGDRegressor



DATA = pd.read_excel('C:/Users/lqh/Desktop/齿槽转矩1.xlsx')
# 截取上面数据集中的前21列，包括所有20列特征和一列输出

# 截取上面数据集中的前21列，包括所有20列特征和一列输出
data = DATA.iloc[0:242, 0:6]#0:13

# 将读取的数据转换为二维数组矩阵类型，57*21。data_array是全部数据
data_array = data.values

# 截取20个特征并转换成二维数组矩阵形式
data_input = data.iloc[0:242, 0:5]  #0:32, :11
data_input_array = data_input.values

# 截取一列输出并转换成二维数组矩阵形式
data_output = data.iloc[0:242, 5:6]  #0:32, 12:13
data_output_array = data_output.values

# 2、划分数据集，20%作为测试集，80%作为训练集
x_train, x_test, y_train, y_test = train_test_split(data_input_array, data_output_array, test_size=0.2, random_state=0)

# 3.训练数据和测试数据进行标准化处理
# 输出的预测的数据是归一化的，如果要对比，需要反归一化才能和真实数据进行对比
ss_x1 = StandardScaler()
x_train = ss_x1.fit_transform(x_train)
x_test = ss_x1.transform(x_test)

ss_y1 = StandardScaler()
y_train = ss_y1.fit_transform(y_train).ravel()

RF = RandomForestRegressor(max_features=3, n_estimators=60, min_samples_split=0.5, oob_score=True,min_samples_leaf=1,max_depth=10,random_state=0)

# 6.2、BO_SVR
BO_SVR = SVR(kernel='rbf', C=3367.64786460069, epsilon=0.001, gamma=0.01)
# BO_SVR = SVR(kernel='rbf', C=500, epsilon=0.01, gamma=0.02)

# 6.3、Ridge回归
Ridge = Ridge(random_state=1, alpha=0.001, solver='saga', max_iter=2000)

# 6.4、Lasso回归
Lasso = Lasso(random_state=0, alpha=0.000001)

# 6.5、
KNN = KNeighborsRegressor(n_neighbors=2,p=1,leaf_size=40)

# 6.6、
GBR = GradientBoostingRegressor(n_estimators=500, learning_rate=0.15, max_depth=3, random_state=0)

# 6.7、
AdaBoost = AdaBoostRegressor(n_estimators=190, random_state=0,learning_rate=0.7267441222192477)


# 6.8、
LR = linear_model.LinearRegression()

# 6.9、
ker = RBF(length_scale=100, length_scale_bounds='fixed')
GPR = GaussianProcessRegressor(kernel=ker, n_restarts_optimizer=4, normalize_y=False)

# 6.10、
BPNN = MLPRegressor(
    hidden_layer_sizes=(20, 30), activation='relu', solver='lbfgs', alpha=0.0500, max_iter=300,
    random_state=0)

# 6.11、
SVR_RBF = SVR(kernel='rbf', C=100, gamma=0.01, epsilon=0.0001)
SGD = SGDRegressor(alpha=0.001,max_iter=1000,random_state=0)
BR=BaggingRegressor(random_state=0,n_estimators=200,max_samples=87,max_features=3)
ETR=ExtraTreeRegressor(random_state=0,max_depth=10,min_samples_leaf=1,max_features=11,min_samples_split=3)


models = [BO_SVR]
list_R2 = []
list_MAE = []
list_RMSE = []
list_Prediction = []
list_e=[]
output = []
list_Predspear=[]
# 遍历各模型
for model_cog in models:
    # 在训练集上训练
    model_cog.fit(x_train, y_train)
    # 模型预测结果
    pred = model_cog.predict(x_test)
    pred=pred.reshape(-1,1)

    # 将各模型预测结果保存到相应的数组中
    MAE = mean_absolute_error(y_test, ss_y1.inverse_transform(pred))
    r2=r2_score(y_test, ss_y1.inverse_transform(pred))
    e=y_test-ss_y1.inverse_transform(pred)
    prde_spear=stats.spearmanr(ss_y1.inverse_transform(pred),y_test)
    RMSE=np.sqrt(mean_squared_error(y_test, ss_y1.inverse_transform(pred)))
    list_MAE.append(MAE)
    list_Prediction.append(ss_y1.inverse_transform(pred))
    list_e.append(e)
    list_Predspear.append(prde_spear)
    list_R2.append(r2)
    list_RMSE.append(RMSE)

MAE_array=np.array(list_MAE).reshape(1,len(models))                      #MAE矩阵(1,12)
e_array=np.array(list_e).reshape(len(models),y_test.shape[0]).T          #预测误差矩阵(12,11)
Pred=np.array(list_Prediction).reshape(len(models),y_test.shape[0]).T    #预测值矩阵(12,11)

#计算预测误差相关性皮尔森矩阵
pccs = np.corrcoef(e_array,rowvar=False)
pccs = np.array(pccs)
#计算预测误差相关性斯皮尔曼矩阵
# spearmanr=np.array(stats.spearmanr(e_array,axis=0))
# spearmanr=spearmanr[0,:,:]                       #预测误差相关性斯皮尔曼矩阵

# print(list_MAE)
# # print(data_input_array.shape)
# print(list_R2)
# print(list_RMSE)
#
