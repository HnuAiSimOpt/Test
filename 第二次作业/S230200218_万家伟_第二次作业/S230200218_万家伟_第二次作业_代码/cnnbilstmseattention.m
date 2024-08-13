      %%  清空环境变量
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行

%%  导入数据
res = xlsread('shuju.xlsx');

%%  数据分析
num_size = 0.7;                              % 训练集占数据集比例
outdim = 1;                                  % 最后一列为输出
num_samples = size(res, 1);                  % 样本个数
%res = res(randperm(num_samples), :);         % 打乱数据集（不希望打乱时，注释该行）
num_train_s = round(num_size * num_samples); % 训练集样本个数
f_ = size(res, 2) - outdim;                  % 输入特征维度

%%  划分训练集和测试集
P_train = res(1: num_train_s, 1: f_)';
T_train = res(1: num_train_s, f_ + 1: end)';
M = size(P_train, 2);

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);

%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);

%%  数据平铺
%   将数据平铺成1维数据只是一种处理方式
%   也可以平铺成2维数据，以及3维数据，需要修改对应模型结构
%   但是应该始终和输入层数据结构保持一致
p_train =  double(reshape(p_train, f_, 1, 1, M));
p_test  =  double(reshape(p_test , f_, 1, 1, N));
t_train =  double(t_train)';
t_test  =  double(t_test )';

%%  数据格式转换
for i = 1 : M
    Lp_train{i, 1} = p_train(:, :, 1, i);
end

for i = 1 : N
    Lp_test{i, 1}  = p_test( :, :, 1, i);
end
    
%%  建立模型
lgraph = layerGraph();                                                 % 建立空白网络结构

tempLayers = [
    sequenceInputLayer([f_, 1, 1], "Name", "sequence")                 % 建立输入层，输入数据结构为[f_, 1, 1]
    sequenceFoldingLayer("Name", "seqfold")];                          % 建立序列折叠层
lgraph = addLayers(lgraph, tempLayers);                                % 将上述网络结构加入空白结构中

tempLayers = convolution2dLayer([3, 1], 32, "Name", "conv_1");         % 卷积层 卷积核[3, 1] 步长[1, 1] 通道数 32
lgraph = addLayers(lgraph,tempLayers);                                 % 将上述网络结构加入空白结构中
 
tempLayers = [
    reluLayer("Name", "relu_1")                                        % 激活层
    convolution2dLayer([3, 1], 64, "Name", "conv_2")                   % 卷积层 卷积核[3, 1] 步长[1, 1] 通道数 64
    reluLayer("Name", "relu_2")];                                      % 激活层
lgraph = addLayers(lgraph, tempLayers);                                % 将上述网络结构加入空白结构中

tempLayers = [
    globalAveragePooling2dLayer("Name", "gapool")                      % 全局平均池化层
    fullyConnectedLayer(16, "Name", "fc_2")                            % SE注意力机制，通道数的1 / 4
    reluLayer("Name", "relu_3")                                        % 激活层
    fullyConnectedLayer(64, "Name", "fc_3")                            % SE注意力机制，数目和通道数相同
    sigmoidLayer("Name", "sigmoid")];                                  % 激活层
lgraph = addLayers(lgraph, tempLayers);                                % 将上述网络结构加入空白结构中

tempLayers = multiplicationLayer(2, "Name", "multiplication");         % 点乘的注意力
lgraph = addLayers(lgraph, tempLayers);                                % 将上述网络结构加入空白结构中

tempLayers = [
    sequenceUnfoldingLayer("Name", "sequnfold")                        % 建立序列反折叠层
    flattenLayer("Name", "flatten")                                    % 网络铺平层
    bilstmLayer(6, "Name", "bilstm", "OutputMode", "last")             % BiLSTM层
    fullyConnectedLayer(1, "Name", "fc")                               % 全连接层
    regressionLayer("Name", "regressionoutput")];                      % 回归层
lgraph = addLayers(lgraph, tempLayers);                                % 将上述网络结构加入空白结构中

lgraph = connectLayers(lgraph, "seqfold/out", "conv_1");               % 折叠层输出 连接 卷积层输入;
lgraph = connectLayers(lgraph, "seqfold/miniBatchSize", "sequnfold/miniBatchSize"); 
                                                                       % 折叠层输出 连接 反折叠层输入  
lgraph = connectLayers(lgraph, "conv_1", "relu_1");                    % 卷积层输出 链接 激活层
lgraph = connectLayers(lgraph, "conv_1", "gapool");                    % 卷积层输出 链接 全局平均池化
lgraph = connectLayers(lgraph, "relu_2", "multiplication/in2");        % 激活层输出 链接 相乘层
lgraph = connectLayers(lgraph, "sigmoid", "multiplication/in1");       % 全连接输出 链接 相乘层
lgraph = connectLayers(lgraph, "multiplication", "sequnfold/in");      % 点乘输出

%%  参数设置
options = trainingOptions('adam', ...      % Adam 梯度下降算法
    'MaxEpochs', 1000, ...                 % 最大迭代次数
    'InitialLearnRate', 1e-2, ...          % 初始学习率为0.01
    'LearnRateSchedule', 'piecewise', ...  % 学习率下降
    'LearnRateDropFactor', 0.1, ...        % 学习率下降因子 0.5
    'LearnRateDropPeriod', 700, ...        % 经过700次训练后 学习率为 0.01 * 0.1
    'Shuffle', 'every-epoch', ...          % 每次训练打乱数据集
    'Plots', 'training-progress', ...      % 画出曲线
    'Verbose', false);

%%  训练模型
net = trainNetwork(Lp_train, t_train, lgraph, options);

%%  模型预测
t_sim1 = predict(net, Lp_train);
t_sim2 = predict(net, Lp_test );

%%  数据反归一化
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

%%  均方根误差
error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

%%  显示网络结构
analyzeNetwork(net)

%%  绘图
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'训练集预测结果对比'; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'测试集预测结果对比'; ['RMSE=' num2str(error2)]};
title(string)
xlim([1, N])
grid

%%  相关指标计算
%  R2
R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;

disp(['训练集数据的R2为：', num2str(R1)])
disp(['测试集数据的R2为：', num2str(R2)])

%  MAE
mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
mae2 = sum(abs(T_sim2' - T_test )) ./ N ;

disp(['训练集数据的MAE为：', num2str(mae1)])
disp(['测试集数据的MAE为：', num2str(mae2)])

%  MBE
mbe1 = sum(T_sim1' - T_train) ./ M ;
mbe2 = sum(T_sim2' - T_test ) ./ N ;

disp(['训练集数据的MBE为：', num2str(mbe1)])
disp(['测试集数据的MBE为：', num2str(mbe2)])