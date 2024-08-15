# coding=utf-8
import numpy as np
my_seed = 30
np.random.seed(my_seed)
import random
random.seed(my_seed)
import tensorflow as tf
tf.random.set_seed(my_seed)

import pandas as pd
from sklearn.model_selection import train_test_split
import scipy.io as sio
from pylab import *
mpl.rcParams['font.sans-serif'] = ['SimHei']
def PlotSpectrum(spec):
  plt.rcParams['axes.unicode_minus']=False
  plt.figure(figsize=(5.2, 3.1), dpi=100)
  x = np.arange(650, 650+0.5 * spec.shape[1], 0.5)
  for i in range(spec.shape[0]):              #给i赋值
      plt.plot(x, spec[i, :], linewidth=0.5)
  fonts = 11
  plt.xlim(650, 1100)
  plt.xlabel('波长（nm）',fontsize=fonts)
  plt.ylabel('吸光度A（%）',fontsize=fonts)
  plt.yticks(fontsize=fonts)
  plt.xticks(fontsize=fonts)
  plt.tight_layout(pad=1)
  return plt
#导入数据
mat = sio.loadmat('D:\\新建文件夹\\mn.mat')
print(mat.keys())
X= mat['msnv']
y = mat['n']
data_array = np.array(X)
data1_array = np.array(y)
X, y = data_array[:, 0:], data1_array[:, 0]
w=pd.DataFrame(X)
#print(w.iloc[:,0:6].describe())#用于生成描述性统计信息。 描述性统计数据：数值类型的包括均值，标准差，最大值，最小值，分位数等

pp = PlotSpectrum(X)
pp.show()
#划分数据集8/2
x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
a=max(y_train)
b=min(y_train)
c=sum(y_train)/len(y_train)
d=np.std(y_train,ddof=1)
print(a)
print(b)
print(c)
print(d)
#构建模型
from sklearn.svm import SVR
model=SVR(kernel='linear')    #SVR回归
model.fit(x_train, y_train)
y_pred = model.predict(x_test)

from sklearn.metrics import r2_score
from sklearn.metrics import mean_squared_error
RMSE = sqrt(mean_squared_error(y_test,y_pred))
pred_acc = r2_score(y_test,y_pred)
print('R2=',pred_acc)
print('RMSE=',RMSE)

#散点图
with plt.style.context(('ggplot')):
    fig, ax = plt.subplots()
    ax.scatter(y_pred, y_test, c='red', edgecolors='k')
    plt.xlabel('真实值')
    plt.ylabel('预测值')
    plt.axis('equal')
    plt.axis('square')
    plt.xlim([8,18])
    plt.ylim([8,18])
    plt.plot([0, 80], [0, 80])
    plt.show()

