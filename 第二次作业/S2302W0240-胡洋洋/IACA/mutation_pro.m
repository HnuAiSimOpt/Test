function [mutationPopulation]=mutation_pro(crossPopulation,popsize,n,Job,Style,Pm)
mutationPopulation=crossPopulation;
for i=1:popsize
    if rand<Pm
        chromesome=mutationPopulation(i).Chromesome;
        child=chromesome;
        %% 供应部分的工件序列变异
        father_os=chromesome(1,1:n);
        [child_os]=mutate_os(father_os,n);
        child(1,1:n)=child_os;
        %% 工件加工机器和仓库选择部分变异
        father_fcs=chromesome(2,1:n);
        [child_fcs]=mutate_fcs(father_fcs,Job,Style);
        child(2,1:n)=child_fcs;
        mutationPopulation(i).Chromesome=child;
    end
end
end

function [child_os]=mutate_os(father_os,n)
child_os=father_os; %供应部分的工件序列
num1=randperm(n,2); %确定进行逆序变异的区间范围
inter1=father_os(1,min(num1):max(num1)); %进行逆序变异的基因片段
inter1_out=inter1(end:-1:1);
child_os(1,min(num1):max(num1))=inter1_out; %逆序变异后的工件加工顺序
end

function [child_fcs]=mutate_fcs(father_fcs,Job,Style)
child_fcs=father_fcs;
%% 工厂仓库选择层变异
kind=randperm(Style,1); %随机选择一种类型的工件执行变异操作
[~,bj_kind]=find(Job==kind); %找到此类型的全部工件集合
while length(bj_kind)<2
    kind=randperm(Style,1); %随机选择一种类型的工件执行变异操作
    [~,bj_kind]=find(Job==kind); %找到此类型的全部工件集合
end
num1=randperm(length(bj_kind),2);
bj1=bj_kind(num1(1)); 
bj2=bj_kind(num1(2)); %随机选择此类型工件集中的两个不同工件
fa_c1=father_fcs(1,bj1);
fa_c2=father_fcs(1,bj2); %确定两工件分别选择的工厂或仓库
if fa_c1~=fa_c2
    child_fcs(bj1)=fa_c2;
    child_fcs(bj2)=fa_c1; %交换两工件的工厂或仓库选择
end
end

