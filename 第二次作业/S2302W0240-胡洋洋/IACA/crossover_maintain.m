function [Child]=crossover_maintain(father1,father2,n)
child1=father1;
child2=father2;
father1_es=father1(1,n+1:2*n); 
father2_es=father2(1,n+1:2*n); %��������ά�����ֵ�װ������
father1_ws=father1(2,n+1:2*n);
father2_ws=father2(2,n+1:2*n); %��������ά�����ֵ�ά������ѡ��
%% װ��ά��˳��㽻��
num=unidrnd(n); %ȷ�����н�������Ļ���λ����
pos=sort(randperm(n,num)); %ѡ����н�������Ļ���λ��
child1_es=father1_es;
child2_es=father2_es;
job1=father1_es(pos);
job2=father2_es(pos); %�����н��н��������װ��
[~,~,col1]=intersect(job2,child1_es);
[~,~,col2]=intersect(job1,child2_es);
child1_es(col1)=0;
child2_es(col2)=0; %������1���븸��2ѡ��Ľ���װ����ͬ��װ��λ����0��ͬ������2���븸��1ѡ��Ľ���װ����ͬ��װ��λ����0
child1_es(child1_es==0)=job2;
child2_es(child2_es==0)=job1;
%% ά������ѡ��㽻��
child1_ws=father1_ws;
child2_ws=father2_ws;
num=randperm(n,2); %ѡ����������λ���ɽ��������
inter1=father1_ws(1,min(num):max(num));
inter2=father2_ws(1,min(num):max(num)); %�ҵ��������������н��н�������Ļ���Ƭ��
child1_ws(1,min(num):max(num))=inter2;
child2_ws(1,min(num):max(num))=inter1;
child1(:,n+1:2*n)=[child1_es;child1_ws];
child2(:,n+1:2*n)=[child2_es;child2_ws];
Child=[child1;child2];