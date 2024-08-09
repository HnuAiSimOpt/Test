clc
clear
close all
%% 导入数据
load shuju.mat
%% 训练数据处理
for i=1:size(input,2)
    maxinput=max(input(:,i));
    input(:,i)=input(:,i)/max(input(:,i));
end
demands=input(1:72,5);
orgin=input(1:72,1:4);
in=orgin;
out=demands;
i=1;
while ~isempty(in)
    pick=4;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        X{i}=in';
        Y(i)=out(end);
        break;
    end
end
%% 网络参数设置
inputSize = 4;
numHiddenUnits = 110;
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(1)
    regressionLayer];
maxEpochs = 2750;
options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0);
%% 训练
net = trainNetwork(X,Y',layers,options);
save('net.mat','net')
trainY=double(predict(net,X));
figure, ploterrhist(trainY-Y')
figure, plot(trainY,'-o')
hold on
plot(Y,'-^')
title('微磨具磨损训练结果')
xlabel('数据组数')
ylabel('归一化处理后磨损值');
legend('BiLSTM模型预测值','实际磨损值','Location','NorthWest')
%% 测试数据处理
clear X Y
demands=input(73:90,5);
orgin=input(73:90,1:4);
in=orgin;
out=demands;
i=1;
while ~isempty(in)
    pick=4;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        X{i}=in';
        Y(i)=out(end);
        break
    end
end
%% 测试
testY=double(predict(net,X));
for i=1:18
    testYreal=abs(testY*maxinput)
    Yreal=abs(Y*maxinput)
end
figure, ploterrhist(testYreal-Yreal'), title('test')
figure, plot(testYreal,'-o')
hold on
plot(Yreal,'-^')
title('微磨具磨损预测结果')
xlabel('数据组数')
ylabel('归一化处理后磨损值');
legend('BiLSTM模型预测值','实际磨损值','Location','NorthWest')
%% 计算误差
RMSE=sqrt(mean((testYreal-Yreal').^2))
R=corrcoef(testYreal,Yreal')
r=R(1,2)
disp(['均方根误差',num2str(RMSE)])
disp(['决定系数R^2为',num2str(r)])
