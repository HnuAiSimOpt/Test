import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from bayes_opt import BayesianOptimization
from sklearn.ensemble import BaggingRegressor,RandomForestRegressor
from sklearn.metrics import mean_squared_error,explained_variance_score,mean_absolute_error,r2_score
import warnings


if __name__ == '__main__':
    warnings.filterwarnings(action='ignore', category=FutureWarning)
    path = 'simulia1220.csv'
    data = pd.read_csv(path,header = 0)
    x = data.iloc[:,4:20]
    y = data.iloc[:,0:4]

    x_train,x_test,y_train,y_test = train_test_split(x,y,train_size=0.8,random_state = 42)
    rf = RandomForestRegressor()
    # print(np.mean(cross_val_score(rf,x_train,y_train,cv=100,verbose = 2)))
    # rf.fit(x_train,y_train)
    # y_pre = rf.predict(x_test)
    # mse = mean_squared_error(y_test,y_pre)
    # print(mse)
    def rf_cv(n_estimators,min_samples_split,max_features,max_depth):
        val = cross_val_score(
            RandomForestRegressor(n_estimators=int(n_estimators),
                min_samples_split=int(min_samples_split),
                max_features=min(max_features,1),
                max_depth=int(max_depth),
                random_state = 2
            ),
            x_train,y_train,cv=20
        ).mean()
        return val

    rf_bo = BayesianOptimization(
        rf_cv,
            {'n_estimators':(10,300),
             'min_samples_split':(2,25),
             'max_features':(0.0,1),
             'max_depth':(5,100)}
    )
    rf_bo.maximize(init_points=3,n_iter=25)
    print(rf_bo.max)
