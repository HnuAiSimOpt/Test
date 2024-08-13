function [Population_nds]=nondominant_sort(Population_decode,popsize,aim)
Population_nds=Population_decode;
rank=1; 
person(1:popsize)=struct('n',0,'s',[]); %����ĳһ���屻֧�������Ŀ�ͱ��˸���֧��ĸ�����Ŀ
F(rank).f=[]; %�������ڲ�ͬ�ȼ��ĸ�����Ϣ
I=1:popsize;
for i=1:popsize
    object_i=Population_decode(i).objectives(1:aim); %��ȡ�����Ŀ��ֵ
    I(1:i)=[];
    if ~isempty(I)
        for jj=1:length(I)
            j=I(jj);
            object_j=Population_decode(j).objectives(1:aim);
            log_num_i=dominate(object_i,object_j);  %���������֧������ж�
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
F(rank).f=col; %����֧��ȼ�Ϊ1�ĸ���
%% ���������ǰ������
while ~isempty(F(rank).f) %ȷ��ÿ���ȼ������ĸ���
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
for ii=1:rank %Ϊÿ���������ȼ����
    if ~isempty(F(ii).f)
        [~,col]=size(F(ii).f);
        for jj=1:col
            Population_nds(F(ii).f(jj)).rank=ii;
        end
    end    
end
[~,index]=sort([Population_nds.rank]); %���յȼ�����Ⱥ�еĸ����������
Population_nds=Population_nds(index);
end