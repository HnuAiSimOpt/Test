%% I. ��ջ�������
clear all
close all
clc

%% II. ѵ����/���Լ�����
%%
% 1. ��������
load X.mat
load Y.mat

%% ����ĥ����
% ѵ����
n = 160;
temp = randperm(size(X,1));
P_train = X(temp(1:n),:)'; 
T_train = Y(temp(1:n),:)';
%���Լ�
P_test = [X(1:4,:);X(5:2:315,:)]';
T_test = [Y(1:4,:);Y(5:2:315,:)]';


N = size(P_test,2);

%% III. ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);

[t_train, ps_output] = mapminmax(T_train,0,1);              

%% IV. BP�����紴����ѵ�����������
%%
% 1. ��������
net = newff(p_train,t_train,62);    %62����������Ԫ�ĸ���

%%
% 2. ����ѵ������
net.trainParam.epochs = 5000;   %��������
net.trainParam.goal = 1e-5;      %mse���������С�����ֵѵ������
net.trainParam.lr = 0.01;         %ѧϰ��

%%
% 3. ѵ������
net = train(net,p_train,t_train);

%%
% 4. �������
t_sim = sim(net,p_test);         %����65��������Ԥ��ֵ

%%
% 5. ���ݷ���һ��
T_sim = mapminmax('reverse',t_sim,ps_output);   %����һ�����
for i = 1:length(T_sim)
    if T_sim(i)<=0
        T_sim(i)=0;
    end
end
%% V. ��������
%%
% 1. ������error
error = abs(T_sim - T_test)./T_test;
jueduierror = abs(T_sim - T_test);
MAE = sum(abs(T_test - T_sim))./length(T_sim);
RMSE = sqrt(sum((T_test - T_sim).^2)./length(T_sim));
MAPE = sum(abs(T_test - T_sim)./T_test)./length(T_sim).*100;
fenzi = sum(T_test .* T_sim) - (sum(T_test) * sum(T_sim)) / length(T_test);  
fenmu = sqrt((sum(T_test .^2) - sum(T_test)^2 / length(T_test)) * (sum(T_sim .^2) - sum(T_sim)^2 / length(T_test)));  
PCC = fenzi / fenmu; 
%%
% 2. ����ϵ��R^2
% R2 = (N * sum(T_sim .* T_test) - sum(T_sim) * sum(T_test))^2 / ((N * sum((T_sim).^2) - (sum(T_sim))^2) * (N * sum((T_test).^2) - (sum(T_test))^2)); 

%%
% 3. ����Ա�
result = [T_test' T_sim' error'];     %�����ʵֵ��Ԥ��ֵ�����

%% VI. ����ĥ����Ԥ���ͼ
x = 1:160;
wucha = bar(x,jueduierror);
set(wucha,'FaceColor',[233/255 30/255 99/255]);
grid on;
box off;
hold on;
yuce = plot(x,T_sim,'Color','b','LineWidth',1,'marker','.');
shiji = plot(x,T_test,'Color','k','LineWidth',1.5);
tuli = legend([shiji,yuce,wucha],'��ʵֵ','Ԥ��ֵ','�������','Location','northwest','fontsize',12); %��ע�����ߵ�ͼ��
set(tuli,'Box','off')
xlim([0,161]) %%x��ʾ��Χ
set(gca,'XTick',[0:20:161]) %%x�������
ylim([0.0001,0.35]) %%y1��ʾ��Χ
set(gca,'yTick',[0:0.05:0.35]) %%y1�������
set(gca,'FontSize',12);
xlabel('������','FontSize',14);
ylabel('����ƽ��ĥ����VBave/mm','FontSize',14)
% title({'��֤��ĥ����Ԥ����';'Ԥ��ģ�ͣ�BPNN'},'FontSize',14)
set(gcf,'position',[700,300,750,350]);