  clc;
clear all;                 
%% 划分数据集
SOH05=xlsread('shuju.xlsx')';
% 归一化
feature=SOH05(:,1:end-1);
label=SOH05(:,2:end);
[xnorm,xopt]=mapminmax(feature,0,1);
[ynorm,yopt]=mapminmax(label,0,1);
input_train =xnorm;
output_train=ynorm;
input_test =xnorm;
output_test=ynorm;

%% 搭建CNN模型
rng('default');
inputSize = 1;
numEpochs = 200; 
batchSize = 89;
nTraining = length(label);
%  CONV -> ReLU -> MAXPOOL -> FC -> DROPOUT -> FC -> SOFTMAX 
layers = [ ...
    sequenceInputLayer(inputSize)
    convolution2dLayer(5,100,'Padding',2,'Stride', 1) % 卷积层 1
    batchNormalizationLayer;
    reluLayer();  % ReLU 层 1
    convolution2dLayer(5,70,'Padding',2,'Stride', 1);  % 卷积层 2
    batchNormalizationLayer;
    maxPooling2dLayer(1,'Stride',1); % 最大池化 池化层 1
    convolution2dLayer(3,50,'Padding',1,'Stride', 1);  % 卷积层 3
    reluLayer(); % ReLU 层 3
    maxPooling2dLayer(1,'Stride',1); 
    convolution2dLayer(3,40,'Padding',1,'Stride', 1);  % 卷积层 4
    reluLayer(); % ReLU 层 2
    maxPooling2dLayer(1,'Stride',1); % 最大池化 池化层 1
    fullyConnectedLayer(1,'Name','fc1')
    
    regressionLayer]

options = trainingOptions('adam',... 
    'InitialLearnRate',1e-3,...% 学习率
    'MiniBatchSize', batchSize, ...
    'MaxEpochs',numEpochs);

[net,info1] = trainNetwork(input_train,output_train,layers,options);
 
%% 提取特征
fLayer = 'fc1';
trainingFeatures = activations(net, input_train, fLayer, ...
             'MiniBatchSize', 16, 'OutputAs', 'channels');
trainingFeatures=cell2mat(trainingFeatures);

for i=1:length(trainingFeatures)
    TF{i}=double(trainingFeatures(:,i));
end

%% 搭建BiLSTM模型
inputSize = 1;
numHiddenUnits = 100;
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    bilstmLayer(numHiddenUnits-30)
    bilstmLayer(numHiddenUnits-60)
    fullyConnectedLayer(1)
    regressionLayer]

options = trainingOptions('adam',... 
    'InitialLearnRate',1e-3,...% 学习率
    'MiniBatchSize', 8, ...
    'MaxEpochs',50, ...
    'Plots','training-progress');

[net1,info1] = trainNetwork(TF,output_train',layers,options);
%% 测试集
% 测试集提取特征
testingFeatures = activations(net, input_test, fLayer, ...
             'MiniBatchSize', 8, 'OutputAs', 'channels');
testingFeatures=cell2mat(testingFeatures);

for i=1:length(testingFeatures)
    TFT{i}=double(testingFeatures(:,i));
end

YPred = predict(net1,TFT);
YPred=mapminmax('reverse',YPred,yopt);
figure
plot(YPred,'b-','LineWidth',1);
hold on;

plot(label,'r','LineWidth',1);
xlabel('样本')
ylabel('数值')
legend('预测结果','真实值')
grid on
title('CNN-BiLSTM 测试集效果')
RMSE=sqrt(mse(label,YPred))

error=abs(label'-double(YPred));
figure
bar(error)
title('误差曲线图')