function [mutationPopulation]=mutation_main(crossPopulation,popsize,n,Pm)
mutationPopulation=crossPopulation;
for i=1:popsize
    if rand<Pm
        chromesome=mutationPopulation(i).Chromesome;
        child=chromesome;
        %% 供应和维护两部分的工件序列变异
        father_es=chromesome(1,n+1:2*n);
        [child_es]=mutate_es(father_es,n);
        child(1,n+1:2*n)=child_es;
        %% 工件加工机器和仓库选择、装备维护人员和策略选择两部分变异
        father_ws=chromesome(2,n+1:2*n);
        [child_ws]=mutate_ws(father_ws,n);
        child(2,n+1:2*n)=child_ws;
        mutationPopulation(i).Chromesome=child;
    end
end
end

function [child_es]=mutate_es(father_es,n)
child_es=father_es; %维护部分的装备序列
num2=randperm(n,2);
inter2=father_es(1,min(num2):max(num2));
inter2_out=inter2(end:-1:1);
child_es(1,min(num2):max(num2))=inter2_out; %逆序变异后的装备维护顺序
end

function [child_ws]=mutate_ws(father_ws,n)
child_ws=father_ws;
%% 维护人员选择层变异
num2=randperm(n,2);
w1=father_ws(1,num2(1));
w2=father_ws(1,num2(2)); %确定随机选择的两个场点装备的维护人员选择
if w1~=w2
    child_ws(1,num2(1))=w2;
    child_ws(1,num2(2))=w1; %交换两装备的维护人员选择
end
end