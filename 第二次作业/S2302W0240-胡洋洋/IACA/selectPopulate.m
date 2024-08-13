function [Population_ch]=selectPopulate(Population_ns,popsize,aim)
% popsize=popsize/2;
Population_rank=[Population_ns.rank]; %��������ĵȼ���Ϣ
child_rank=Population_rank(1:popsize);
last_rank=child_rank(popsize);
[~,col]=find(Population_rank==1);
Population_ch=Population_ns(col);
Num1=size(col,2); %%������Ⱥ�еȼ�Ϊ1�ĸ�����Ŀ
if last_rank==1&&Num1>popsize %���Ӵ���Ⱥ���һ������ĵȼ�Ϊ1�Ҹ����еȼ�Ϊ1�ĸ����������Ӵ���Ⱥ�ܸ�����ʱ
    [Population_cd]=crowding_distance(Population_ns,aim,last_rank);
    Population_ch(1:popsize)=struct('Chromesome',[],'decode',[],'machine_start_time',[],'machine_end_time',[],'factory_bj',[],'worker_bj',[],'worker_protime',[],'objectives',[],'IT',[],'rank',0,'crowded_distance',0);
    Population_array=Population_cd(1:Num1);
    array=[Population_array.crowded_distance];
    [~,array_sort_col]=sort(array,'descend');
    index=array_sort_col(1:popsize);
    Population_ch(1:popsize)=Population_array(index);
else
    if last_rank>1
        [value1,~]=find(Population_rank==last_rank);
        [value2,~]=find(child_rank==last_rank);
        [~,last_rank_size1]=size(value1);
        [~,last_rank_size2]=size(value2);
        if last_rank_size1==last_rank_size2
            Population_ch=Population_ns(1:popsize);
        else
            [Population_cd]=crowding_distance(Population_ns,aim,last_rank);
            Population_ch(1:popsize)=struct('Chromesome',[],'decode',[],'machine_start_time',[],'machine_end_time',[],'factory_bj',[],'worker_bj',[],'worker_protime',[],'objectives',[],'IT',[],'rank',0,'crowded_distance',0);
            num=popsize-last_rank_size2;                                               %����ѡ������һ��ǰ�صĸ�����
            Population_ch(1:num)=Population_cd(1:num);
            Population_array=Population_cd(num+1:num+last_rank_size1);
            array=[Population_array.crowded_distance];
            [~,array_sort_col]=sort(array,'descend');
            index=array_sort_col(1:last_rank_size2);
            Population_ch(num+1:popsize)=Population_array(index);
        end
    end
end