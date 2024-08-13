function [crossPopulation,cross_size]=cross_pro(Population_st,popsize,n,F,Job,store,Pc)
crossPopulation=Population_st;
flag=0;
for i=1:popsize/2
    if rand<Pc
        flag=flag+1; %������н�������Ĵ���
        f=randperm(popsize,2); %����Ⱥ��ѡ����������
        father1=Population_st(f(1)).Chromesome;
        father2=Population_st(f(2)).Chromesome;
        [Child]=crossover_supply(father1,father2,n,F,Job,store); 
        crossPopulation(2*flag-1).Chromesome=Child(1:2,:);
        crossPopulation(2*flag).Chromesome=Child(3:4,:);
        crossPopulation(2*flag-1).decode=Population_st(f(1)).decode;
        crossPopulation(2*flag).decode=Population_st(f(2)).decode;
        crossPopulation(2*flag-1).worker_bj=Population_st(f(1)).worker_bj;
        crossPopulation(2*flag).worker_bj=Population_st(f(2)).worker_bj;
        crossPopulation(2*flag-1).worker_protime=Population_st(f(1)).worker_protime;
        crossPopulation(2*flag).worker_protime=Population_st(f(2)).worker_protime;
        crossPopulation(2*flag-1).IT=Population_st(f(1)).IT;
        crossPopulation(2*flag).IT=Population_st(f(2)).IT;
        crossPopulation(2*flag-1).objectives=Population_st(f(1)).objectives;
        crossPopulation(2*flag).objectives=Population_st(f(2)).objectives;
    end
end
crossPopulation=crossPopulation(1:2*flag); %������յĽ�����Ⱥ
cross_size=2*flag; %�������������Ⱥ��С
end

function [Child]=crossover_supply(father1,father2,n,F,Job,store)
child1=father1;
child2=father2;
father1_os=father1(1,1:n); 
father2_os=father2(1,1:n); %�������幩Ӧ���ֵĹ�������
father1_fcs=father1(2,1:n);
father2_fcs=father2(2,1:n); %�������幩Ӧ���ֵĹ����ӹ������Ͳֿ�ѡ��
%% �������в㽻��
num=unidrnd(n); %ȷ�����н�������Ļ���λ����
pos=sort(randperm(n,num)); %ѡ����н�������Ļ���λ��
child1_os=father1_os;
child2_os=father2_os;
job1=father1_os(pos);
job2=father2_os(pos); %�����н��н�������Ĺ���
[~,~,col1]=intersect(job2,child1_os);
[~,~,col2]=intersect(job1,child2_os);
child1_os(col1)=0;
child2_os(col2)=0; %������1���븸��2ѡ��Ľ��湤����ͬ�Ĺ���λ����0��ͬ������2���븸��1ѡ��Ľ��湤����ͬ�Ĺ���λ����0
child1_os(child1_os==0)=job2;
child2_os(child2_os==0)=job1;
%% �����ֿ�ѡ��㽻��
child1_fcs=father1_fcs;
child2_fcs=father2_fcs;
num=unidrnd(n); %ȷ�����н�������Ĺ�����
pos=randperm(n,num); %ѡ����н�������Ĺ���
for k=1:length(pos)
    j=pos(k); %���湤��
    kind=Job(j); %ȷ���˽��н�������Ĺ�������
    [~,samekind]=find(Job==kind);
    samekind(samekind==j)=[]; %�ҵ����й����к͹���j����ͬ�����͵Ĺ�������
    if father1_fcs(j)<=F&&father2_fcs(j)<=F&&father1_fcs(j)~=father2_fcs(j)
        child1_fcs(j)=father2_fcs(j);
        child2_fcs(j)=father1_fcs(j); %������������ѡ�й���ѡ��Ĺ������������Ӹ���
    else
        if father1_fcs(j)>F&&father2_fcs(j)>F&&father1_fcs(j)~=father2_fcs(j)    
            ca1_new=father2_fcs(j); %����1�˽��湤�����²ֿ�ѡ��
            ca2_new=father1_fcs(j); %����2�ν��湤�����²ֿ�ѡ�� 
            [~,pos1]=find(store{ca1_new-F}(1,:)==kind);
            [~,pos2]=find(store{ca2_new-F}(1,:)==kind); %�ҵ�����������������͹����ֱ����²ֿ��еĴ���λ��
            if length(find(father1_fcs(samekind)==ca1_new))<store{ca1_new-F}(2,pos1)&&length(find(father2_fcs(samekind)==ca2_new))<store{ca2_new-F}(2,pos2)
                child1_fcs(j)=ca1_new;
                child2_fcs(j)=ca2_new;
            end
        else
            if father1_fcs(j)<=F&&father2_fcs(j)>F  
                ca1_new=father2_fcs(j); %��������1������Ĳֿ�
                [~,pos_new]=find(store{ca1_new-F}(1,:)==kind);
                if length(find(father1_fcs(samekind)==ca1_new))<store{ca1_new-F}(2,pos_new)
                    child1_fcs(j)=ca1_new;
                    child2_fcs(j)=father1_fcs(j);
                end
            else
                if father1_fcs(j)>F&&father2_fcs(j)<=F 
                    ca2_new=father1_fcs(j); %��������2�����Ĳֿ�
                    [~,pos_new]=find(store{ca2_new-F}(1,:)==kind);
                    if length(find(father2_fcs(samekind)==ca2_new))<store{ca2_new-F}(2,pos_new)
                        child1_fcs(j)=father2_fcs(j);
                        child2_fcs(j)=ca2_new;
                    end
                end
            end
        end
    end
    father1_fcs=child1_fcs; 
    father2_fcs=child2_fcs; %���¸��������Ա���һ�������Ľ������
end
child1(:,1:n)=[child1_os;child1_fcs];
child2(:,1:n)=[child2_os;child2_fcs];
Child=[child1;child2];
end