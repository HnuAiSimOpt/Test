clc
clear
close all
%% II. 训练集/测试集产生
%%
% 1. 导入数据
input=xlsread('evaluation1','Sheet1')
%% III. 导入数据
%%
%%划分训练集为1-72，测试集为73-90
input_train=input(1:4,1:72)
input_test=input(1:4,73:90)
output_train=input(5,1:72)
output_test=input(5,73:90)
N = size(input_test,2);
%% III. 数据归一化
%%用mapminmax按列归一化数据在0-1之间
[inputn,inputps]=mapminmax(input_train,0,1)
[outputn,outputps]=mapminmax(output_train,0,1)
inputn_test=mapminmax('apply',input_test,inputps)
%% II. 声明全局变量
global p     % 训练集输入数据
global t     % 训练集输出数据
global R     % 输入神经元个数
global S2    % 输出神经元个数
global S1    % 隐层神经元个数
global S     % 编码长度
S1 = 8;
% 训练数据
p = inputn;
t = outputn;
%% IV. BP神经网络
%%
% 1. 网络创建
net = newff(minmax(p),[S1,1],{'tansig','purelin'},'trainlm'); 
%%
% 2. 设置训练参数
net.trainParam.show = 10;
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-3;
net.trainParam.lr = 0.01;
%%
% 3. 网络训练
[net,tr] = train(net,p,t);
%%
% 4. 仿真测试
t_sim = sim(net,inputn_test);    % BP神经网络的仿真结果
% 5. 数据反归一化
T_sim = mapminmax('reverse',t_sim,outputps);
%% V. 性能评价
%%
% 1. 相对误差error
error = abs(T_sim - output_test)./output_test;
%%
% 2. 决定系数R^2
R2 = (N * sum(T_sim .* output_test) - sum(T_sim) * sum(output_test))^2 / ((N * sum((T_sim).^2) - (sum(T_sim))^2) * (N * sum((output_test).^2) - (sum(output_test))^2)); 
%%
% 3. 结果对比
result = [output_test' T_sim' error']
%% VI. 绘图
figure
plot(1:N,output_test,'b:*',1:N,T_sim,'r-o')
legend('真实值','预测值')
xlabel('样本数')
ylabel('磨损值')
string = {'测试集磨损值预测结果对比';['R^2=' num2str(R2)]};
title(string)