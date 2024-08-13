%%  清空环境变量
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行
tic
% restoredefaultpath
%%  导入数据
input=xlsread('evaluation1','Sheet1')
P_train=input(1:4,1:72)
P_test=input(1:4,73:90)
T_train=input(5,1:72)
T_test=input(5,73:90)
f_=size(P_train, 1);                  % 输入特征维度
outdim = 1;                           % 最后一列为输出
%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);
[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);
%%  划分训练集和测试集
M = size(P_train, 2);
N = size(P_test, 2);
%%  优化算法参数设置
SearchAgents_no = 5;                   % 种群数量
Max_iteration = 5;                    % 最大迭代次数
dim = 3;                               % 优化参数个数
lb = [1e-4, 10, 1e-4];                 % 参数取值下界(学习率，隐藏层节点，正则化系数)
ub = [1e-2, 30, 1e-1];                 % 参数取值上界(学习率，隐藏层节点，正则化系数)
fitness = @(x)fical(x,p_train,t_train,f_);
[Best_score,Best_pos,Convergence_curve]=GA(SearchAgents_no,Max_iteration,lb ,ub,dim,fitness)
%%  记录最佳参数
Best_pos(1, 2) = round(Best_pos(1, 2));
best_lr = Best_pos(1, 1);
best_hd = Best_pos(1, 2);
best_l2 = Best_pos(1, 3);
%%  建立模型
% ----------------------  修改模型结构时需对应修改fical.m中的模型结构  --------------------------
layers = [
    sequenceInputLayer(f_)            % 输入层
    bilstmLayer(best_hd)              % BiLSTM层
    reluLayer                         % Relu激活层
    fullyConnectedLayer(outdim)       % 输出回归层
    regressionLayer];
%%  参数设置
% ----------------------  修改模型参数时需对应修改fical.m中的模型参数  --------------------------
options = trainingOptions('adam', ...           % Adam 梯度下降算法
         'MaxEpochs', 2000, ...                  % 最大训练次数 500
         'InitialLearnRate', best_lr, ...       % 初始学习率 best_lr
         'LearnRateSchedule', 'piecewise', ...  % 学习率下降
         'LearnRateDropFactor', 0.05, ...        % 学习率下降因子 0.1
         'LearnRateDropPeriod', 400, ...        % 经过 400 次训练后 学习率为 best_lr * 0.5
         'Shuffle', 'every-epoch', ...          % 每次训练打乱数据集
         'ValidationPatience', Inf, ...         % 关闭验证
         'L2Regularization', best_l2, ...       % 正则化参数
         'Plots', 'training-progress', ...      % 画出曲线
         'Verbose', false);

%%  训练模型
net = trainNetwork(p_train, t_train, layers, options);

%%  仿真验证
t_sim1 = predict(net, p_train);
t_sim2 = predict(net, p_test );

%%  数据反归一化
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);
T_sim1=double(T_sim1);
T_sim2=double(T_sim2);
%%  均方根误差
error1 = sqrt(sum((T_sim1 - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2 - T_test ).^2) ./ N);
toc

%%  绘图
figure
plot(1 : length(Convergence_curve), Convergence_curve,'linewidth',1.5);
title('GA-BiLSTM', 'FontSize', 10);
xlabel('迭代次数', 'FontSize', 10);
ylabel('适应度值mse', 'FontSize', 10);
grid off

%% 测试集结果
figure;
plotregression(T_test,T_sim2,['回归图']);
figure;
ploterrhist(T_test-T_sim2,['误差直方图']);
%%  均方根误差 RMSE
error1 = sqrt(sum((T_sim1 - T_train).^2)./M);
error2 = sqrt(sum((T_test - T_sim2).^2)./N);

%%
%决定系数
R1 = 1 - norm(T_train - T_sim1)^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test -  T_sim2)^2 / norm(T_test -  mean(T_test ))^2;

%%
%均方误差 MSE
mse1 = sum((T_sim1 - T_train).^2)./M;
mse2 = sum((T_sim2 - T_test).^2)./N;
%%
%RPD 剩余预测残差
SE1=std(T_sim1-T_train);
RPD1=std(T_train)/SE1;

SE=std(T_sim2-T_test);
RPD2=std(T_test)/SE;
%% 平均绝对误差MAE
MAE1 = mean(abs(T_train - T_sim1));
MAE2 = mean(abs(T_test - T_sim2));
%% 平均绝对百分比误差MAPE
MAPE1 = mean(abs((T_train - T_sim1)./T_train));
MAPE2 = mean(abs((T_test - T_sim2)./T_test));
%%  训练集绘图
figure
%plot(1:M,T_train,'r-*',1:M,T_sim1,'b-o','LineWidth',1)
plot(1:M,T_train,'r-*',1:M,T_sim1,'b-o','LineWidth',1.5)
legend('真实值','GA-BiLSTM预测值')
xlabel('预测样本')
ylabel('预测结果')
string={'训练集预测结果对比';['(R^2 =' num2str(R1) ' )' ]};
title(string)
%% 预测集绘图
figure
plot(1:N,T_test,'r-*',1:N,T_sim2,'b-o','LineWidth',1.5)
legend('真实值','GA-BiLSTM预测值')
xlabel('预测样本')
ylabel('预测结果')
string={'测试集预测结果对比';['(R^2 =' num2str(R2) ')']};
title(string)

%% 测试集误差图
figure  
ERROR3=abs(T_test-T_sim2);
plot(ERROR3,'b-*','LineWidth',1.5)
xlabel('测试集样本编号')
ylabel('预测误差')
title('测试集预测误差')
grid on;
legend('GA-BiLSTM预测输出误差')
%% 绘制线性拟合图
%% 训练集拟合效果图
figure
plot(T_train,T_sim1,'*r');
xlabel('真实值')
ylabel('预测值')
string = {'训练集效果图';['R^2_c=' num2str(R1)  '  RMSEC=' num2str(error1) ]};
title(string)
hold on ;h=lsline;
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1])
%% 预测集拟合效果图
figure
plot(T_test,T_sim2,'ob');
xlabel('真实值')
ylabel('预测值')
string1 = {'测试集效果图';['R^2_p=' num2str(R2)  '  RMSEP=' num2str(error2) ]};
title(string1)
hold on ;h=lsline();
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1])
%% 求平均
R3=(R1+R2)./2;
error3=(error1+error2)./2;
%% 总数据线性预测拟合图
tsim=[T_sim1,T_sim2]';
S=[T_train,T_test]';
figure
plot(S,tsim,'ob');
xlabel('真实值')
ylabel('预测值')
string1 = {'所有样本拟合预测图';['R^2_p=' num2str(R3)  '  RMSEP=' num2str(error3) ]};
title(string1)
hold on ;h=lsline();
set(h,'LineWidth',1,'LineStyle','-','Color',[1 0 1])
%% 打印出评价指标
disp(['-----------------------误差计算--------------------------'])
disp(['评价结果如下所示：'])
disp(['平均绝对误差MAE为：',num2str(MAE2)])
disp(['均方误差MSE为：       ',num2str(mse2)])
disp(['均方根误差RMSEP为：  ',num2str(error2)])
disp(['决定系数R^2为：  ',num2str(R2)])
disp(['剩余预测残差RPD为：  ',num2str(RPD2)])
disp(['平均绝对百分比误差MAPE为：  ',num2str(MAPE2)])
grid