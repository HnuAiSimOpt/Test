%%
clc;clear;
warning off;
%% 导入数据
%% 
data = xlsread('temp.xlsx', 'Sheet1');
% 输入数据
input =data(:,1:6)';
output=data(:,7)';
nwhole =size(data,1);
train_ratio=0.8;
ntrain=round(nwhole*train_ratio);
ntest =nwhole-ntrain;
% 准备输入和输出训练数据
input_train =input(:,1:ntrain);
output_train=output(:,1:ntrain);
% 准备测试数据
input_test =input(:, ntrain+1:ntrain+ntest);
output_test=output(:,ntrain+1:ntrain+ntest);

%% 归一化（全部特征 均归一化）
[inputn_train,inputps]  =mapminmax(input_train);
[outputn_train,outputps]=mapminmax(output_train);
inputn_test =mapminmax('apply',input_test,inputps); 
outputn_test=mapminmax('apply',output_test,outputps); 
%% LSTM 层设置，参数设置
inputSize  = size(inputn_train,1);   %数据输入x的特征维度
outputSize = size(outputn_train,1);  %数据输出y的维度  
numhidden_units1=60;

%% lstm
layers = [ ...
    sequenceInputLayer(inputSize)                 %输入层设置
    lstmLayer(numhidden_units1,'name','hidden1')  %学习层设置(cell层）
    dropoutLayer(0.4,'name','dropout_1')
    fullyConnectedLayer(outputSize)               % 全连接层设置（影响输出维度）
    regressionLayer('name','out')];
%% trainoption(lstm)
opts = trainingOptions('adam', ...
    'MaxEpochs',1000, ...
    'GradientThreshold',1,...
    'ExecutionEnvironment','cpu',...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',100, ...                % epoch后学习率更新
    'LearnRateDropFactor',0.8, ...
    'Verbose',0, ...
    'Plots','training-progress'... 
    );

%% LSTM网络训练
tic
LSTMnet = trainNetwork(inputn_train ,outputn_train ,layers,opts);
toc;
[LSTMnet,LSTMoutputr_train]= predictAndUpdateState(LSTMnet,inputn_train);
LSTMoutput_train = mapminmax('reverse',LSTMoutputr_train,outputps);
%% LSTM测试数据
%%
%网络测试输出
[LSTMnet,LSTMoutputr_test] = predictAndUpdateState(LSTMnet,inputn_test);
%网络输出反归一化
LSTMoutput_test= mapminmax('reverse',LSTMoutputr_test,outputps);
%% LSTM数据输出
%%
%-------------------------------------------------------------------------------------
error_test=LSTMoutput_test'-output_test';
pererror_test=error_test./output_test';
error=error_test';
pererror=pererror_test';
avererror=sum(abs(error))/(ntest);
averpererror=sum(abs(pererror))/(ntest);
RMSE = sqrt(mean((error).^2));
disp('LSTM网络预测绝对平均误差MAE');
disp(avererror);
disp('LSTM网络预测平均绝对误差百分比MAPE');
disp(averpererror)
disp('LSTM网络预测均方根误差RMSE')
disp(RMSE)

%% LSTM数据可视化分析
%测试数据
figure()
plot(LSTMoutput_test,'b-^','linewidth',1.5)     
hold on
plot(output_test,'r-o','linewidth',1)           
legend( '预测测试数据','实际分析数据','Location','NorthWest','FontName','宋体');
title('LSTM网络预测结果','fontsize',12,'FontName','宋体')
xlabel('样本数','fontsize',12,'FontName','宋体');
ylabel('磨损值','fontsize',12,'FontName','宋体');
%-------------------------------------------------------------------------------------
figure  
plot(pererror_test,'b-*','Color',[255 50 0]./255,'LineWidth',1.5)
legend('LSTM网络测试相对误差','Location','NorthEast','FontName','宋体')
title('LSTM网络预测相对误差','fontsize',12,'FontName','宋体')
ylabel('误差','fontsize',12,'FontName','宋体')
xlabel('样本','fontsize',12,'FontName','宋体')
%-------------------------------------------------------------------------------------