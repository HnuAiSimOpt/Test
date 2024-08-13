%% I. 清空环境变量
clear all
close all
clc

%% II. 训练集/测试集产生
%%
% 1. 导入数据
load X.mat
load Y.mat

%% 刀具磨损量
% 训练集
n = 160;
temp = randperm(size(X,1));
P_train = X(temp(1:n),:)'; 
T_train = Y(temp(1:n),:)';
%测试集
P_test = [X(1:4,:);X(5:2:315,:)]';
T_test = [Y(1:4,:);Y(5:2:315,:)]';


N = size(P_test,2);

%% III. 数据归一化
[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);

[t_train, ps_output] = mapminmax(T_train,0,1);              

%% IV. BP神经网络创建、训练及仿真测试
%%
% 1. 创建网络
net = newff(p_train,t_train,62);    %62是隐含层神经元的个数

%%
% 2. 设置训练参数
net.trainParam.epochs = 5000;   %迭代次数
net.trainParam.goal = 1e-5;      %mse均方根误差小于这个值训练结束
net.trainParam.lr = 0.01;         %学习率

%%
% 3. 训练网络
net = train(net,p_train,t_train);

%%
% 4. 仿真测试
t_sim = sim(net,p_test);         %返回65个样本的预测值

%%
% 5. 数据反归一化
T_sim = mapminmax('reverse',t_sim,ps_output);   %反归一化结果
for i = 1:length(T_sim)
    if T_sim(i)<=0
        T_sim(i)=0;
    end
end
%% V. 性能评价
%%
% 1. 相对误差error
error = abs(T_sim - T_test)./T_test;
jueduierror = abs(T_sim - T_test);
MAE = sum(abs(T_test - T_sim))./length(T_sim);
RMSE = sqrt(sum((T_test - T_sim).^2)./length(T_sim));
MAPE = sum(abs(T_test - T_sim)./T_test)./length(T_sim).*100;
fenzi = sum(T_test .* T_sim) - (sum(T_test) * sum(T_sim)) / length(T_test);  
fenmu = sqrt((sum(T_test .^2) - sum(T_test)^2 / length(T_test)) * (sum(T_sim .^2) - sum(T_sim)^2 / length(T_test)));  
PCC = fenzi / fenmu; 
%%
% 2. 决定系数R^2
% R2 = (N * sum(T_sim .* T_test) - sum(T_sim) * sum(T_test))^2 / ((N * sum((T_sim).^2) - (sum(T_sim))^2) * (N * sum((T_test).^2) - (sum(T_test))^2)); 

%%
% 3. 结果对比
result = [T_test' T_sim' error'];     %输出真实值，预测值，误差

%% VI. 刀具磨损量预测绘图
x = 1:160;
wucha = bar(x,jueduierror);
set(wucha,'FaceColor',[233/255 30/255 99/255]);
grid on;
box off;
hold on;
yuce = plot(x,T_sim,'Color','b','LineWidth',1,'marker','.');
shiji = plot(x,T_test,'Color','k','LineWidth',1.5);
tuli = legend([shiji,yuce,wucha],'真实值','预测值','绝对误差','Location','northwest','fontsize',12); %加注多条线的图例
set(tuli,'Box','off')
xlim([0,161]) %%x显示范围
set(gca,'XTick',[0:20:161]) %%x标尺增量
ylim([0.0001,0.35]) %%y1显示范围
set(gca,'yTick',[0:0.05:0.35]) %%y1标尺增量
set(gca,'FontSize',12);
xlabel('样本数','FontSize',14);
ylabel('后刀面平均磨损量VBave/mm','FontSize',14)
% title({'验证集磨损量预测结果';'预测模型：BPNN'},'FontSize',14)
set(gcf,'position',[700,300,750,350]);