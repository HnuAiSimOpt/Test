clc
clear
close all
input=xlsread('wucha','Sheet1')
bilstm=input(:,1)
bp=input(:,2)
gabp=input(:,3)
N=size(input,1)
figure
plot(1:18,bilstm,'g- .',1:N,bp,'r- .',1:N,gabp,'k- .')
legend('BiLSTM模型','BP神经网络','GABP神经网络')
xlabel('样本数')
ylabel('相对误差')
title('多模型预测结果对比')