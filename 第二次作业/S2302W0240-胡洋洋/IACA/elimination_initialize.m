function [Population_st,child_size]=elimination_initialize(Population_ch,popsize,n,Job,F,M,CA,store,Style,protime,t_fn,I_time,w,S,aim)
%去除种群内重复的个体，并初始化产生部分新个体

%inputs
% Population_st:选择得到的个体

%outputs
% Population_st：去重和初始化的个体
[Population_child]=elimination(Population_ch,popsize,aim);
[~,index1]=find([Population_child.rank]==0);
[~,col1]=size(index1);
child_size=col1;

if child_size~=0
    %% 初始化种群补充去重的个体
    [Population_child1]=initialization(child_size,n,F,M,Job,CA,store,protime,t_fn,Style,I_time,w,S);
    Population_child(popsize-col1+1:popsize)=Population_child1;
    Population_st=Population_child;
    [Population_st(1:popsize).crowded_distance]=deal(0);
else
    Population_st=Population_child(1:popsize);
end
end