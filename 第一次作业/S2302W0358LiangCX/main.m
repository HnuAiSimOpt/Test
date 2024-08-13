%%  清空环境
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行


%%  导入数据（时间序列的单列数据）
result = xlsread('不同时间数据变化.xlsx');

%%  数据分析
num_samples = length(result);  % 对表格数据行数识别为样本个数，为119
kim = 17;                      % 延时步长，后续数据转换的行向量个数，17*7=119
zim =  1;                      % 跨1个时间点进行预测，即预测下一数据

%%  构造数据集，数据转换为矩阵
for i = 1: num_samples - kim - zim + 1
    res(i, :) = [reshape(result(i: i + kim - 1), 1, kim), result(i + kim + zim - 1)];
end

%%  数据集分析
outdim = 1;                                  % 将最后一列为输出
num_size = 0.7;                              % 分配训练集占数据集比例
num_train_s = round(num_size * num_samples); % 计算训练集样本个数
f_ = size(res, 2) - outdim;                  % 输入特征维度，分离自变量（时间）


P_train = res(1: num_train_s, 1: f_)';       %训练集特征，’保证转置有意义
T_train = res(1: num_train_s, f_ + 1: end)'; %训练集目标
M = size(P_train, 2);                        %计算

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);

%%  数据处理，建立神经网络处理模型
[p_train, ps_input] = mapminmax(P_train, 0, 1);   %输入数据预处理，归一化
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);  %输出数据预处理
t_test = mapminmax('apply', T_test, ps_output);

net = newff(p_train, t_train, 5);                 %创建模型

%%  设置训练参数
net.trainParam.epochs = 10000;    %迭代次数 
net.trainParam.goal = 1e-6;       %误差阈值
net.trainParam.lr = 0.01;         %学习率

net= train(net, p_train, t_train);

%%  仿真测试
t_sim1 = sim(net, p_train);
t_sim2 = sim(net, p_test);

T_sim1 = mapminmax('reverse', t_sim1, ps_output);    %返回原始数据，反归一化
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

error1 = sqrt(sum((T_sim1 - T_train).^2) ./ M);      %计算训练均方根误差
error2 = sqrt(sum((T_sim2 - T_test ).^2) ./ N);      %计算测试均方根误差

%%  绘图
figure
plot(1: M, T_train, 'r-', 1: M, T_sim1, 'b-', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {strcat('训练集预测结果对比：', ['RMSE=' num2str(error1)])};   %表头，并显示均方根误差
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-', 1: N, T_sim2, 'b-', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {strcat('测试集预测结果对比：', ['RMSE=' num2str(error2)])};
title(string)
xlim([1, N])
grid

%%  相关指标计算
% R2，决定系数（0，1）
R1 = 1 - norm(T_train - T_sim1)^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2)^2 / norm(T_test  - mean(T_test ))^2;

disp(['训练集数据的R2为：', num2str(R1)])
disp(['测试集数据的R2为：', num2str(R2)])

% MAE，平均绝对误差
mae1 = sum(abs(T_sim1 - T_train)) ./ M ;
mae2 = sum(abs(T_sim2 - T_test )) ./ N ;

disp(['训练集数据的MAE为：', num2str(mae1)])
disp(['测试集数据的MAE为：', num2str(mae2)])

% MBE，平均偏差误差
mbe1 = sum(T_sim1 - T_train) ./ M ;
mbe2 = sum(T_sim2 - T_test ) ./ N ;

disp(['训练集数据的MBE为：', num2str(mbe1)])
disp(['测试集数据的MBE为：', num2str(mbe2)])

%  MAPE，平均绝对百分比误差
mape1 = sum(abs((T_sim1 - T_train)./T_train)) ./ M ;
mape2 = sum(abs((T_sim2 - T_test )./T_test )) ./ N ;

disp(['训练集数据的MAPE为：', num2str(mape1)])
disp(['测试集数据的MAPE为：', num2str(mape2)])

%%  绘制散点图
sz = 25;
c = 'b';

figure
scatter(T_train, T_sim1, sz, c)
hold on
plot(xlim, ylim, '--k')
xlabel('训练集真实值');
ylabel('训练集预测值');
xlim([min(T_train) max(T_train)])
ylim([min(T_sim1) max(T_sim1)])
title('训练集预测值 vs. 训练集真实值')

figure
scatter(T_test, T_sim2, sz, c)
hold on
plot(xlim, ylim, '--k')
xlabel('测试集真实值');
ylabel('测试集预测值');
xlim([min(T_test) max(T_test)])
ylim([min(T_sim2) max(T_sim2)])
title('测试集预测值 vs. 测试集真实值')
