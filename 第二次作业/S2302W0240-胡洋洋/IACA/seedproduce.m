function [Seed]=seedproduce(n,F,M,protime,Job,chrom_fcs,t_fn,Style,I_time)
Seed=cell(1,3); %储存最终的三种种子序列
Seed{1,1}=randperm(n); %储存第一种随机的种子序列
[~,index_fa]=find(chrom_fcs<=F);
bj_fa=zeros(1,length(index_fa));
duestart_L=zeros(1,length(index_fa)); %备件最晚交货时间减去在工厂中最后一个阶段机器上的加工时间
duestart_A=zeros(1,length(index_fa)); %备件最晚交货时间减去在工厂中所有阶段机器上的总加工时间
Atime=zeros(1,Style); %储存各种类型备件在所有阶段的加工时间和
for j=1:Style
    Atime(1,j)=sum(protime(:,j));
end
for i=1:length(index_fa)
    kind=Job(index_fa(i)); %当前备件的类型
    duestart_L(i)=I_time(1,index_fa(i))-protime(M,kind)-t_fn(chrom_fcs(1,index_fa(i)),index_fa(i)); %该备件在各个工厂中的最后一台机器上的最晚开始时间
    duestart_A(i)=I_time(1,index_fa(i))-Atime(1,kind)-t_fn(chrom_fcs(1,index_fa(i)),index_fa(i));
    bj_fa(i)=index_fa(i);
end
[~,index_duestart_L]=sort(duestart_L);
[~,index_duestart_A]=sort(duestart_A);
Se_fa_L=bj_fa(index_duestart_L); 
Se_fa_A=bj_fa(index_duestart_A);
[~,bj_st]=find(chrom_fcs>F);
index_st=randperm(length(bj_st));
Se_st=bj_st(index_st);
Seed{1,2}=[Se_fa_L Se_st]; %根据第二种初始化规则——LSL规则得到的种子序列（即通过比较最晚到期日和工厂内最后一阶段机器上加工时间以及工厂运至现场时间的差值形成）
Seed{1,3}=[Se_fa_A Se_st]; %根据第三种初始化规则——ASL规则得到的种子序列（即通过比较最晚到期日和工厂内所有阶段机器上加工时间以及工厂运至现场时间的差值形成）