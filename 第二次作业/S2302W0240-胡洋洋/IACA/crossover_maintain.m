function [Child]=crossover_maintain(father1,father2,n)
child1=father1;
child2=father2;
father1_es=father1(1,n+1:2*n); 
father2_es=father2(1,n+1:2*n); %父代个体维护部分的装备排列
father1_ws=father1(2,n+1:2*n);
father2_ws=father2(2,n+1:2*n); %父代个体维护部分的维护工人选择
%% 装备维护顺序层交叉
num=unidrnd(n); %确定进行交叉操作的基因位数量
pos=sort(randperm(n,num)); %选择进行交叉操作的基因位置
child1_es=father1_es;
child2_es=father2_es;
job1=father1_es(pos);
job2=father2_es(pos); %父代中进行交叉操作的装备
[~,~,col1]=intersect(job2,child1_es);
[~,~,col2]=intersect(job1,child2_es);
child1_es(col1)=0;
child2_es(col2)=0; %将父代1中与父代2选择的交叉装备相同的装备位置置0；同理将父代2中与父代1选择的交叉装备相同的装备位置置0
child1_es(child1_es==0)=job2;
child2_es(child2_es==0)=job1;
%% 维护工人选择层交叉
child1_ws=father1_ws;
child2_ws=father2_ws;
num=randperm(n,2); %选择两个基因位构成交叉的区间
inter1=father1_ws(1,min(num):max(num));
inter2=father2_ws(1,min(num):max(num)); %找到两个父代个体中进行交叉操作的基因片段
child1_ws(1,min(num):max(num))=inter2;
child2_ws(1,min(num):max(num))=inter1;
child1(:,n+1:2*n)=[child1_es;child1_ws];
child2(:,n+1:2*n)=[child2_es;child2_ws];
Child=[child1;child2];