# -*- coding: utf-8 -*-
"""
Created on Sun Apr 11 13:48:53 2021

@author: lucifer
"""

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error
from keras.models import load_model
import tensorflow as tf
import matplotlib.pyplot as plt
import time
import keras


class TimeHistory(keras.callbacks.Callback):
    def on_train_begin(self,logs={}):
        self.times = []
        self.totaltime = time.time()
    def on_train_end(self,logs={}):
        self.totaltime = time.time()-self.totaltime
    def on_epoch_begin(self,batch,logs={}):
        self.epoch_time_start = time.time()
    def on_epoch_end(self,batch,logs={}):
        self.times.append(time.time()-self.epoch_time_start)

print('Tensorflow Version: {}'.format(tf.__version__))

if __name__ == '__main__':
    path = 'data100v.csv'
    # path = 'data-50v.csv'
    # path = 'data100v.csv'
    data = pd.read_csv(path,header = 0)
    x = data.iloc[:,0:3]
    y = data.iloc[:,3:53]
    
    path = 'experiment.csv'
    data1 = pd.read_csv(path,header = 0)
    x_pre = data1.iloc[:,0:3]
    # print(x_pre)
    
    x_train,x_test,y_train,y_test = train_test_split(x,y,train_size=0.8,random_state= 42)
#    data = pd.DataFrame(y_test)
#    writer = pd.ExcelWriter('test0.xlsx')		
#    data.to_excel(writer, 'page_1', float_format='%.5f')		
#    writer.save()
#    writer.close()
    model = tf.keras.Sequential()
    model.add(tf.keras.layers.Dense(22,input_shape =
                                    (x_train.shape[1],)))
    model.add(tf.keras.layers.LeakyReLU(alpha=0.02))
    # model.add(tf.keras.layers.Dense(34))
    # model.add(tf.keras.layers.LeakyReLU(alpha=0.02))
#    model.add(tf.keras.layers.Dense(3,activation='relu'))
    model.add(tf.keras.layers.Dense(50,activation='linear'))
    print(model.summary())
    np.set_printoptions(threshold = 1e6)
    
    ada = tf.keras.optimizers.Adam(learning_rate=0.001)
    model.compile(optimizer=ada,loss='mse',metrics=['mse'])
    time_callback = TimeHistory()
    history = model.fit(x_train,y_train,epochs=1500,
                           validation_data = (x_test,y_test),callbacks=[time_callback])
    # pd.DataFrame.from_dict(history.history).to_csv("outputs_2.csv", float_format="%.5f",
    #                       index=False)

    #
    # plt.plot(history.history['loss'])
    # plt.plot(history.history['val_loss'])
    # plt.title('Model loss')
    # plt.ylabel('Loss').
    # plt.xlabel('Epoch')
    # plt.legend(['Train', 'Test'], loc='upper right')
    # plt.show()

    y_hat = model.predict(x_test)
    y_hat_train = model.predict(x_train)
    r2 = r2_score(y_test,y_hat)
    print(r2)
    mse= mean_squared_error(y_test,y_hat)
    print(mse)
    # data1 = pd.DataFrame(y_hat)
    # writer = pd.ExcelWriter('ceshijiwss5.xlsx')
    # data1.to_excel(writer, 'page_1', float_format='%.5f')
    # writer.save()
    # writer.close()
    # data1 = pd.DataFrame(y_hat_train)
    # writer = pd.ExcelWriter('training_v1.xlsx')
    # data1.to_excel(writer, 'page_1', float_format='%.5f')
    # writer.save()
    # writer.close()
    y_pre = model.predict(x_pre)
    # print(y_pre)
    # data2 = pd.DataFrame(y_pre)
    # writer = pd.ExcelWriter('yucewss_ex3.xlsx')
    # writer = pd.ExcelWriter('yucev_10_07.xlsx')
    # data2.to_excel(writer, 'page_1', float_format='%.10f')
    # writer.save()
    # writer.close()
    print(time_callback.totaltime)
    # data3 = pd.DataFrame(y_test)
    # writer = pd.ExcelWriter('test_wss2.xlsx')
    # data3.to_excel(writer,'page_1',float_format='%.5f')
    # writer.save()
    # writer.close()
    # data3 = pd.DataFrame(y_train)
    # writer = pd.ExcelWriter('train_v.xlsx')
    # data3.to_excel(writer, 'page_1', float_format='%.5f')
    # writer.save()
    # writer.close()
    
    
    
    
    
    
    
    
    
    
    
    
