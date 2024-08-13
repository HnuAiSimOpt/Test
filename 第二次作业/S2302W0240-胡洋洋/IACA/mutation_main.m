function [mutationPopulation]=mutation_main(crossPopulation,popsize,n,Pm)
mutationPopulation=crossPopulation;
for i=1:popsize
    if rand<Pm
        chromesome=mutationPopulation(i).Chromesome;
        child=chromesome;
        %% ��Ӧ��ά�������ֵĹ������б���
        father_es=chromesome(1,n+1:2*n);
        [child_es]=mutate_es(father_es,n);
        child(1,n+1:2*n)=child_es;
        %% �����ӹ������Ͳֿ�ѡ��װ��ά����Ա�Ͳ���ѡ�������ֱ���
        father_ws=chromesome(2,n+1:2*n);
        [child_ws]=mutate_ws(father_ws,n);
        child(2,n+1:2*n)=child_ws;
        mutationPopulation(i).Chromesome=child;
    end
end
end

function [child_es]=mutate_es(father_es,n)
child_es=father_es; %ά�����ֵ�װ������
num2=randperm(n,2);
inter2=father_es(1,min(num2):max(num2));
inter2_out=inter2(end:-1:1);
child_es(1,min(num2):max(num2))=inter2_out; %���������װ��ά��˳��
end

function [child_ws]=mutate_ws(father_ws,n)
child_ws=father_ws;
%% ά����Աѡ������
num2=randperm(n,2);
w1=father_ws(1,num2(1));
w2=father_ws(1,num2(2)); %ȷ�����ѡ�����������װ����ά����Աѡ��
if w1~=w2
    child_ws(1,num2(1))=w2;
    child_ws(1,num2(2))=w1; %������װ����ά����Աѡ��
end
end