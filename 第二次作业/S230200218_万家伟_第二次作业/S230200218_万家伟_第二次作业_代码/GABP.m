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
S1 = 7;
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
%% V. GA-BP神经网络
R = size(p,1);
S2 = size(t,1);
S = R*S1 + S1*S2 + S1 + S2;
aa = ones(S,1)*[-1,1];
%% VI. 遗传算法优化
%%
% 1. 初始化种群
popu = 60;  % 种群规模
initPpp = initializega(popu,aa,'gabpEval',[],[1e-6 1]);  % 初始化种群
%%
% 2. 迭代优化
gen = 100;  % 遗传代数
% 调用GAOT工具箱，其中目标函数定义为gabpEval
[x,endPop,bPop,trace] = ga(aa,'gabpEval',[],initPpp,[1e-6 1 1],'maxGenTerm',gen,...
                           'normGeomSelect',[0.08],['arithXover'],[2],'nonUnifMutation',[2 gen 3]);
%%
% 3. 绘均方误差变化曲线
figure(1)
plot(trace(:,1),1./trace(:,3),'r-');
hold on
plot(trace(:,1),1./trace(:,2),'b-');
xlabel('Generation');
ylabel('Sum-Squared Error');
%%
% 4. 绘制适应度函数变化
figure(2)
plot(trace(:,1),trace(:,3),'r-');
hold on
plot(trace(:,1),trace(:,2),'b-');
xlabel('Generation');
ylabel('Fittness');
%% VII. 解码最优解并赋值
%%
% 1. 解码最优解
[W1,B1,W2,B2] = gadecod(x);
%%
% 2. 赋值给神经网络
net.IW{1,1} = W1;
net.LW{2,1} = W2;
net.b{1} = B1;
net.b{2} = B2;
%% VIII. 利用新的权值和阈值进行训练
net = train(net,p,t);
%% IX. 仿真测试
t_ga = sim(net,inputn_test)    %遗传优化后的仿真结果
% 5. 数据反归一化
T_ga = mapminmax('reverse',t_ga,outputps);
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
%% 保存训练好的神经网络
save('GA-BP','net');
function [W1, B1, W2, B2]=gadecod(x)
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
S1 = 7;
% 训练数据
p = inputn;
t = outputn;

R = size(p,1);
S2 = size(t,1);
S = R*S1 + S1*S2 + S1 + S2;
aa = ones(S,1)*[-1,1];
% 前R*S1个编码为W1
for i=1:S1,
    for k=1:R,
      W1(i,k)=x(R*(i-1)+k);
    end
end
% 接着的S1*S2个编码（即第R*S1个后的编码）为W2
for i=1:S2,
   for k=1:S1,
      W2(i,k)=x(S1*(i-1)+k+R*S1);
   end
end
% 接着的S1个编码（即第R*S1+S1*S2个后的编码）为B1
for i=1:S1,
   B1(i,1)=x((R*S1+S1*S2)+i);
end
% 接着的S2个编码（即第R*S1+S1*S2+S1个后的编码）为B2
for i=1:S2,
   B2(i,1)=x((R*S1+S1*S2+S1)+i);
end
end