import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import BaggingRegressor,RandomForestRegressor
from sklearn.model_selection import   GridSearchCV
from sklearn.model_selection import RandomizedSearchCV
from sklearn.metrics import mean_squared_error,explained_variance_score,mean_absolute_error,r2_score
import warnings
warnings.filterwarnings('ignore')

if __name__ == '__main__':
    path = 'simulia1220.csv'
    data = pd.read_csv(path,header = 0)
    x = data.iloc[:,4:20]
    y = data.iloc[:,0:4]
    # print(x)
    # print(y)
    x_train,x_test,y_train,y_test = train_test_split(x,y,train_size=0.8,random_state = 42)
    # print(x_train)
    # print(y_train)

    import matplotlib.pyplot as plt

    from collections import OrderedDict
    from sklearn.datasets import make_classification
    from sklearn.ensemble import RandomForestClassifier


    print(__doc__)

    RANDOM_STATE = 123


    rf = RandomForestRegressor(criterion='mae',bootstrap= True,max_features= 'sqrt',max_depth=109,min_samples_split=2,
                               n_estimators=120,min_samples_leaf=1,oob_score=True)

    #
    path = 'experiment.csv'
    data1 = pd.read_csv(path,header = 0)
    x_pre = data1.iloc[:,0:16]
    print(x_pre)
    #
    y_pre = rf.predict(x_pre)
    #
    data2 = pd.DataFrame(y_pre)
    writer = pd.ExcelWriter('yuce1.xlsx')
    data2.to_excel(writer,'page_1',float_format='%.5f')
    writer.save()
    writer.close()









