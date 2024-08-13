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
    warnings.filterwarnings(action='ignore', category=FutureWarning)
    path = 'simulia1220.csv'
    data = pd.read_csv(path,header = 0)
    x = data.iloc[:,4:21]
    y = data.iloc[:,0:4]
    # print(x)
    # print(y)
    x_train,x_test,y_train,y_test = train_test_split(x,y,train_size=0.8,random_state = 3)
    # print(x_train)
    # print(y_train)

    criterion = ['mae','mse']
    n_estimators = [int(x) for x in np.linspace(start=15,stop=35,num=1)]
    max_features = ['auto','sqrt']
    max_depth = [int(x) for x in np.linspace(60,80,num=10)]
    max_depth.append(None)
    min_samples_split = [4,6,10]
    min_samples_leaf = [1,2,4]
    bootstrap = [True,False]
    random_grid = {'criterion':criterion,
               'n_estimators': n_estimators,
               'max_features': max_features,
               'max_depth': max_depth,
               'min_samples_split': min_samples_split,
               'min_samples_leaf': min_samples_leaf,
               'bootstrap': bootstrap}
    clf= RandomForestRegressor()
    clf_grid = GridSearchCV(estimator=clf,param_grid= random_grid,cv= 20,n_jobs=-1,verbose= 2)
    clf_grid.fit(x_train,y_train)
    # clf_random.fit(x_train,y_train)
    print(clf_grid.best_params_)







