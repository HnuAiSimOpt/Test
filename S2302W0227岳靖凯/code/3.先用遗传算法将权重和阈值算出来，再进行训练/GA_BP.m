%% 准备数据
clc;clear;close all;
load('shuju_data.mat')%数据
%% 导入数据
%设置训练数据和测试数据
[m,n]=size(data);
train_num=10; %自变量 
x_train_data=data(1:train_num,1:n-1);
y_train_data=data(1:train_num,n);
%测试数据
x_test_data=data(train_num+1:end,1:n-1);
y_test_data=data(train_num+1:end,n);
x_train_data=x_train_data';
y_train_data=y_train_data';
x_test_data=x_test_data';
%% 标准化
[x_train_regular,x_train_maxmin] = mapminmax(x_train_data);
[y_train_regular,y_train_maxmin] = mapminmax(y_train_data);

%% 初始化参数
input_num=size(x_train_data,1); %输入特征个数
hidden_num=6;   %隐藏层神经元个数
output_num=size(y_train_data,1); %输出特征个数

% 遗传算法参数初始化
iter_num=500;                         %总体进化迭代次数
group_num=40;                      %种群规模
cross_pro=0.4;                       %交叉概率
mutation_pro=0.05;                  %变异概率，相对来说比较小

%这个优化的主要思想就是优化网络参数的初始选择，初始选择对于效果好坏是有较大影响的
num_all=input_num*hidden_num+hidden_num+hidden_num*output_num+output_num;%网络总参数，只含一层隐藏层
lenchrom=ones(1,num_all);  %染色体总长度
limit=[-1*ones(num_all,1) 1*ones(num_all,1)];    %初始参数给定范围

EMS_all=[];
TIME=[];
num_iter_all=1;
for NN=1:num_iter_all
  t1=clock;
%% 初始化种群
input_data=x_train_regular;
output_data=y_train_regular;
for i=1:group_num
    initial=rand(1,length(lenchrom));  %产生0-1的随机数
    initial_chrom(i,:)=limit(:,1)'+(limit(:,2)-limit(:,1))'.*initial; %变成染色体的形式，一行为一条染色体
    %上述产生的是-1~1之间的随机数，1x61的矩阵
    fitness_value=fitness(initial_chrom(i,:),input_num,hidden_num,output_num,input_data,output_data);
    fitness_group(i)=fitness_value;
end
[bestfitness,bestindex]=min(fitness_group);
bestchrom=initial_chrom(bestindex,:);  %最好的染色体
avgfitness=sum(fitness_group)/group_num; %染色体的平均适应度                              
trace=[avgfitness bestfitness]; % 记录每一代进化中最好的适应度和平均适应度
%% 迭代过程
new_chrom=initial_chrom;
new_fitness=fitness_group;
 for num=1:iter_num
    % 选择  
     [new_chrom,new_fitness]=select(new_chrom,new_fitness,group_num);  
     avgfitness=sum(new_fitness)/group_num; 
    %交叉  
     new_chrom=Cross(cross_pro,lenchrom,new_chrom,group_num,limit);
    % 变异  
     new_chrom=Mutation(mutation_pro,lenchrom,new_chrom,group_num,num,iter_num,limit);     
    % 计算适应度   %将处理过后的chrom和适应度转入sgroup和new_fitness里
    for j=1:group_num  
        sgroup=new_chrom(j,:); %新群体 
        new_fitness(j)=fitness(sgroup,input_num,hidden_num,output_num,input_data,output_data);     
    end  
    %找到最小和最大适应度的染色体及它们在种群中的位置
    [newbestfitness,newbestindex]=min(new_fitness);
    [worestfitness,worestindex]=max(new_fitness);
    % 代替上一次进化中最好的染色体
    if  bestfitness>newbestfitness
        bestfitness=newbestfitness;
        bestchrom=new_chrom(newbestindex,:);
    end
    new_chrom(worestindex,:)=bestchrom;
    new_fitness(worestindex)=bestfitness;
    %这两步操作只是使得最烂的数据也变成最好的
    avgfitness=sum(new_fitness)/group_num;
    trace=[trace;avgfitness bestfitness]; %记录每一代进化中最好的适应度和平均适应度
 end
%%
figure(1)
[r ,~]=size(trace);
plot([1:r]',trace(:,2),'b--');
title(['适应度曲线  ' '终止代数＝' num2str(iter_num)]);
xlabel('进化代数');ylabel('适应度');
legend('最佳适应度');
 
%% 把最优初始阀值权值赋予网络预测
% %用遗传算法优化的BP网络进行值预测
% net=newff(x_train_regular,y_train_regular,hidden_num,{'tansig','purelin'},'trainlm');
% input_chrom=bestchrom;
w1=bestchrom(1:input_num*hidden_num);   %输入和隐藏层之间的权重参数
B1=bestchrom(input_num*hidden_num+1:input_num*hidden_num+hidden_num); %隐藏层神经元的偏置
w2=bestchrom(input_num*hidden_num+hidden_num+1:input_num*hidden_num+...
    hidden_num+hidden_num*output_num);  %隐藏层和输出层之间的偏置
B2=bestchrom(input_num*hidden_num+hidden_num+hidden_num*output_num+1:input_num*hidden_num+...
    hidden_num+hidden_num*output_num+output_num); %输出层神经元的偏置
%网络权值赋值
% net.iw{1,1}=reshape(w1,hidden_num,input_num);
% net.lw{2,1}=reshape(w2,output_num,hidden_num);
% net.b{1}=reshape(B1,hidden_num,1);
% net.b{2}=reshape(B2,output_num,1);
% net.trainParam.epochs=200;          %最大迭代次数
% net.trainParam.lr=0.1;                        %学习率
% net.trainParam.goal=0.00001;
% [net,~]=train(net,x_train_regular,y_train_regular);
w1=reshape(w1,hidden_num,input_num);
w2=reshape(w2,output_num,hidden_num);
B1=reshape(B1,hidden_num,1);
B2=reshape(B2,output_num,1);
%将输入数据归一化
x_test_regular = mapminmax('apply',x_test_data,x_train_maxmin);
[~,n1]=size(x_test_regular);

%放入到网络输出数据
A1=tansig(w1*x_test_regular+repmat(B1,1,n1));   %需与main函数中激活函数相同
A2=purelin(w2*A1+repmat(B2,1,n1));      %需与main函数中激活函数相同  
% y_test_regular=sim(net,x_test_regular);
y_test_regular=A2;
%将得到的数据反归一化得到预测数据
GA_BP_predict=mapminmax('reverse',y_test_regular,y_train_maxmin);
errors_nn=sum(abs(GA_BP_predict'-y_test_data)./(y_test_data))/length(y_test_data);
EcRMSE=sqrt(sum((errors_nn).^2)/length(errors_nn));

t2=clock;
Time_all=etime(t2,t1);

EMS_all=[EMS_all,EcRMSE];
TIME=[TIME,Time_all];
end
figure(2)
% EMS_all=[0.142257836480101,0.145475762362687,0.142025031462931,0.144898144312287,0.145330361342209,0.151655962592779,0.142833464193844,0.136991568565291,0.150775201950770,0.146993509081267];
plot(EMS_all,'LineWidth',2)
xlabel('实验次数')
ylabel('误差')
hold on
figure(3)
color=[111,168,86;128,199,252;112,138,248;184,84,246]/255;
plot(y_test_data,'Color',color(2,:),'LineWidth',1)
hold on
plot(GA_BP_predict,'*','Color',color(1,:))
hold on
legend('真实数据','预测数据')
disp('相对容量误差为：')
disp(EcRMSE)
titlestr=['BP神经网络','   误差为：',num2str(min(EcRMSE))];
title(titlestr)