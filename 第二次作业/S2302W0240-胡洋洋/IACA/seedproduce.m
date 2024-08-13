function [Seed]=seedproduce(n,F,M,protime,Job,chrom_fcs,t_fn,Style,I_time)
Seed=cell(1,3); %�������յ�������������
Seed{1,1}=randperm(n); %�����һ���������������
[~,index_fa]=find(chrom_fcs<=F);
bj_fa=zeros(1,length(index_fa));
duestart_L=zeros(1,length(index_fa)); %����������ʱ���ȥ�ڹ��������һ���׶λ����ϵļӹ�ʱ��
duestart_A=zeros(1,length(index_fa)); %����������ʱ���ȥ�ڹ��������н׶λ����ϵ��ܼӹ�ʱ��
Atime=zeros(1,Style); %����������ͱ��������н׶εļӹ�ʱ���
for j=1:Style
    Atime(1,j)=sum(protime(:,j));
end
for i=1:length(index_fa)
    kind=Job(index_fa(i)); %��ǰ����������
    duestart_L(i)=I_time(1,index_fa(i))-protime(M,kind)-t_fn(chrom_fcs(1,index_fa(i)),index_fa(i)); %�ñ����ڸ��������е����һ̨�����ϵ�����ʼʱ��
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
Seed{1,2}=[Se_fa_L Se_st]; %���ݵڶ��ֳ�ʼ�����򡪡�LSL����õ����������У���ͨ���Ƚ��������պ͹��������һ�׶λ����ϼӹ�ʱ���Լ����������ֳ�ʱ��Ĳ�ֵ�γɣ�
Seed{1,3}=[Se_fa_A Se_st]; %���ݵ����ֳ�ʼ�����򡪡�ASL����õ����������У���ͨ���Ƚ��������պ͹��������н׶λ����ϼӹ�ʱ���Լ����������ֳ�ʱ��Ĳ�ֵ�γɣ�