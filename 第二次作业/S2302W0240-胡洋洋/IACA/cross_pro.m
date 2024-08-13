function [crossPopulation,cross_size]=cross_pro(Population_st,popsize,n,F,Job,store,Pc)
crossPopulation=Population_st;
flag=0;
for i=1:popsize/2
    if rand<Pc
        flag=flag+1; %计算进行交叉操作的次数
        f=randperm(popsize,2); %从种群中选择两个父代
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
crossPopulation=crossPopulation(1:2*flag); %获得最终的交叉种群
cross_size=2*flag; %交叉产生的新种群大小
end

function [Child]=crossover_supply(father1,father2,n,F,Job,store)
child1=father1;
child2=father2;
father1_os=father1(1,1:n); 
father2_os=father2(1,1:n); %父代个体供应部分的工件排列
father1_fcs=father1(2,1:n);
father2_fcs=father2(2,1:n); %父代个体供应部分的工件加工工厂和仓库选择
%% 工件排列层交叉
num=unidrnd(n); %确定进行交叉操作的基因位数量
pos=sort(randperm(n,num)); %选择进行交叉操作的基因位置
child1_os=father1_os;
child2_os=father2_os;
job1=father1_os(pos);
job2=father2_os(pos); %父代中进行交叉操作的工件
[~,~,col1]=intersect(job2,child1_os);
[~,~,col2]=intersect(job1,child2_os);
child1_os(col1)=0;
child2_os(col2)=0; %将父代1中与父代2选择的交叉工件相同的工件位置置0；同理将父代2中与父代1选择的交叉工件相同的工件位置置0
child1_os(child1_os==0)=job2;
child2_os(child2_os==0)=job1;
%% 工厂仓库选择层交叉
child1_fcs=father1_fcs;
child2_fcs=father2_fcs;
num=unidrnd(n); %确定进行交叉操作的工件数
pos=randperm(n,num); %选择进行交叉操作的工件
for k=1:length(pos)
    j=pos(k); %交叉工件
    kind=Job(j); %确定此进行交叉操作的工件类型
    [~,samekind]=find(Job==kind);
    samekind(samekind==j)=[]; %找到所有工件中和工件j属于同种类型的工件集合
    if father1_fcs(j)<=F&&father2_fcs(j)<=F&&father1_fcs(j)~=father2_fcs(j)
        child1_fcs(j)=father2_fcs(j);
        child2_fcs(j)=father1_fcs(j); %将父代两个体选中工件选择的工厂交换产生子个体
    else
        if father1_fcs(j)>F&&father2_fcs(j)>F&&father1_fcs(j)~=father2_fcs(j)    
            ca1_new=father2_fcs(j); %父代1此交叉工件的新仓库选择
            ca2_new=father1_fcs(j); %父代2次交叉工件的新仓库选择 
            [~,pos1]=find(store{ca1_new-F}(1,:)==kind);
            [~,pos2]=find(store{ca2_new-F}(1,:)==kind); %找到两个父代个体此类型工件分别在新仓库中的储存位置
            if length(find(father1_fcs(samekind)==ca1_new))<store{ca1_new-F}(2,pos1)&&length(find(father2_fcs(samekind)==ca2_new))<store{ca2_new-F}(2,pos2)
                child1_fcs(j)=ca1_new;
                child2_fcs(j)=ca2_new;
            end
        else
            if father1_fcs(j)<=F&&father2_fcs(j)>F  
                ca1_new=father2_fcs(j); %父代个体1交换后的仓库
                [~,pos_new]=find(store{ca1_new-F}(1,:)==kind);
                if length(find(father1_fcs(samekind)==ca1_new))<store{ca1_new-F}(2,pos_new)
                    child1_fcs(j)=ca1_new;
                    child2_fcs(j)=father1_fcs(j);
                end
            else
                if father1_fcs(j)>F&&father2_fcs(j)<=F 
                    ca2_new=father1_fcs(j); %父代个体2交叉后的仓库
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
    father2_fcs=child2_fcs; %更新父代个体以便下一个工件的交叉操作
end
child1(:,1:n)=[child1_os;child1_fcs];
child2(:,1:n)=[child2_os;child2_fcs];
Child=[child1;child2];
end