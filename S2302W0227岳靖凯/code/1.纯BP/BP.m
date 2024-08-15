clc;clear;close all;
load('shuju_data.mat')
[m,n]=size(data);
train_num=10; %前80%为训练集
%下面是训练集
x_train_data=data(1:train_num,1:n-1);       
y_train_data=data(1:train_num,n);            
%下面是测试集
x_test_data=data(train_num+1:end,1:n-1);     
y_test_data=data(train_num+1:end,n);

x_train_data=x_train_data';
y_train_data=y_train_data';
x_test_data=x_test_data';
[x_train_regular,x_train_maxmin] = mapminmax(x_train_data);     %归一化
[y_train_regular,y_train_maxmin] = mapminmax(y_train_data);
%创建网络
%%调用形式
EMS_all=[];            %运行误差记录
TIME=[];                %运行时间记录
num_iter_all=10;   %随机运行次数
for NN=1:num_iter_all
t1=clock;
net=newff(x_train_regular,y_train_regular,6,{'tansig','purelin'}); %6：神经元个数、激活函数：tansig
[net,~]=train(net,x_train_regular,y_train_regular);  %进行训练
%将输入数据归一化
x_test_regular = mapminmax('apply',x_test_data,x_train_maxmin); %将x_test_data数据结构按照x_train_maxmin的参数方法，进行归一化，x_train_maxmin这个方法在上面归一化x_train_data数据时保留下来了
%放入到网络输出数据
y_test_regular=sim(net,x_test_regular);  %网络输出的预测值，注意，此与y_test_data归一化不同，y_test_regular他是通过神经网络训练出来的数据
%将得到的数据反归一化得到预测数据
BP_predict=mapminmax('reverse',y_test_regular,y_train_maxmin);
% RBF_predict(find(RBF_predict<0))=-0.244;
%%
BP_predict=BP_predict';
errors_nn=sum(abs(BP_predict-y_test_data)./(y_test_data))/length(y_test_data);
t2=clock;         
Time_all=etime(t2,t1); %计算
EMS_all=[EMS_all,errors_nn];
TIME=[TIME,Time_all];
end
figure(2)
% EMS_all=[0.151277426366310,0.145790071635758,0.152229836751767,0.147953564542518,0.143818740388519,0.143837148577291,0.150634730752498,0.147839770226974,0.148028820366280,0.145394520676572];
plot(EMS_all,'LineWidth',2)
xlabel('实验次数')
ylabel('误差')
hold on
figure(3)
color=[111,168,86;128,199,252;112,138,248;184,84,246]/255;
plot(y_test_data,'Color',color(2,:),'LineWidth',1)
hold on
plot(BP_predict,'*','Color',color(1,:))
hold on
titlestr=['MATLAB自带BP神经网络','   误差为：',num2str(errors_nn)];
title(titlestr)
