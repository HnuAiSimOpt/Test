function [mutationPopulation]=mutation_pro(crossPopulation,popsize,n,Job,Style,Pm)
mutationPopulation=crossPopulation;
for i=1:popsize
    if rand<Pm
        chromesome=mutationPopulation(i).Chromesome;
        child=chromesome;
        %% ��Ӧ���ֵĹ������б���
        father_os=chromesome(1,1:n);
        [child_os]=mutate_os(father_os,n);
        child(1,1:n)=child_os;
        %% �����ӹ������Ͳֿ�ѡ�񲿷ֱ���
        father_fcs=chromesome(2,1:n);
        [child_fcs]=mutate_fcs(father_fcs,Job,Style);
        child(2,1:n)=child_fcs;
        mutationPopulation(i).Chromesome=child;
    end
end
end

function [child_os]=mutate_os(father_os,n)
child_os=father_os; %��Ӧ���ֵĹ�������
num1=randperm(n,2); %ȷ�����������������䷶Χ
inter1=father_os(1,min(num1):max(num1)); %�����������Ļ���Ƭ��
inter1_out=inter1(end:-1:1);
child_os(1,min(num1):max(num1))=inter1_out; %��������Ĺ����ӹ�˳��
end

function [child_fcs]=mutate_fcs(father_fcs,Job,Style)
child_fcs=father_fcs;
%% �����ֿ�ѡ������
kind=randperm(Style,1); %���ѡ��һ�����͵Ĺ���ִ�б������
[~,bj_kind]=find(Job==kind); %�ҵ������͵�ȫ����������
while length(bj_kind)<2
    kind=randperm(Style,1); %���ѡ��һ�����͵Ĺ���ִ�б������
    [~,bj_kind]=find(Job==kind); %�ҵ������͵�ȫ����������
end
num1=randperm(length(bj_kind),2);
bj1=bj_kind(num1(1)); 
bj2=bj_kind(num1(2)); %���ѡ������͹������е�������ͬ����
fa_c1=father_fcs(1,bj1);
fa_c2=father_fcs(1,bj2); %ȷ���������ֱ�ѡ��Ĺ�����ֿ�
if fa_c1~=fa_c2
    child_fcs(bj1)=fa_c2;
    child_fcs(bj2)=fa_c1; %�����������Ĺ�����ֿ�ѡ��
end
end

