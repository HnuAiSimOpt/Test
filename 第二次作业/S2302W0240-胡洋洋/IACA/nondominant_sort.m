function [Population_nds]=nondominant_sort(Population_decode,popsize,aim)
Population_nds=Population_decode;
rank=1; 
person(1:popsize)=struct('n',0,'s',[]); %储存某一个体被支配个体数目和被此个体支配的个体数目
F(rank).f=[]; %储存属于不同等级的个体信息
I=1:popsize;
for i=1:popsize
    object_i=Population_decode(i).objectives(1:aim); %读取个体的目标值
    I(1:i)=[];
    if ~isempty(I)
        for jj=1:length(I)
            j=I(jj);
            object_j=Population_decode(j).objectives(1:aim);
            log_num_i=dominate(object_i,object_j);  %两个个体的支配情况判断
            log_num_j=dominate(object_j,object_i);
            if log_num_i
               person(i).s=[person(i).s,j];
               person(j).n=person(j).n+1;
            end
            if log_num_j
               person(j).s=[person(j).s,i];
               person(i).n=person(i).n+1;
            end
        end
    end
    I=1:popsize;
end
[~,col]=find([person.n]==0);
F(rank).f=col; %储存支配等级为1的个体
%% 后续个体的前沿排序
while ~isempty(F(rank).f) %确定每个等级包含的个体
    Q=[];
    for i=1:length(F(rank).f)
        if ~isempty(person(F(rank).f(i)).s)
            for j=1:length(person(F(rank).f(i)).s)
                person(person(F(rank).f(i)).s(j)).n=person(person(F(rank).f(i)).s(j)).n-1;
                if person(person(F(rank).f(i)).s(j)).n==0
                    Q=[Q,person(F(rank).f(i)).s(j)];
                end
            end
        end
    end
    rank=rank+1;
    F(rank).f=Q;
end
for ii=1:rank %为每个个体分配等级编号
    if ~isempty(F(ii).f)
        [~,col]=size(F(ii).f);
        for jj=1:col
            Population_nds(F(ii).f(jj)).rank=ii;
        end
    end    
end
[~,index]=sort([Population_nds.rank]); %按照等级对种群中的个体进行排序
Population_nds=Population_nds(index);
end