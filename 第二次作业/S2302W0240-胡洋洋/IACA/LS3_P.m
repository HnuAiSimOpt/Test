function [Population_orss]=LS3_P(Population_decode,popsize,n,F,Job,Style,t_cn,pr_yun,pr_cun)
% �����Ĳֿ�ѡ�񽻻���������ɱ���ͬʱ�ܹ���С����ʱ�䣬������Խ��ͳɱ�
Population_orss=Population_decode;
for i=1:popsize
    chrom=Population_orss(i).Chromesome;
    chrom_fcs=chrom(2,1:n); %�����ļӹ������Ͳֿ�ѡ������
    bj_decode=Population_orss(i).decode;
    objectives=Population_orss(i).objectives;
    [~,J_cs]=find(chrom_fcs>F); %�ҵ��ɲֿ�����Ĺ�������
    for kk=1:Style
        J_set=J_cs(Job(J_cs)==kk); %�ҵ��ɲֿ����������Ϊkk�Ĺ���
        if length(J_set)>1
            J=J_set(unidrnd(length(J_set))); %���ѡ��һ���������вֿ⽻��
            st=chrom_fcs(1,J)-F; %����Jѡ��Ĳֿ�
            J_set(J_set==J)=[];
            time_change=zeros(1,length(J_set)); %��¼����J����һ���������ֿ�������ʱ��仯��
            for j=1:length(J_set)
                J_new=J_set(j); %ȷ�������ֿ����һ����
                st_new=chrom_fcs(1,J_new)-F; %��һ����ѡ��Ĳֿ�
                if st_new==st
                    time_change(j)=0;
                else
                    time_change(j)=t_cn(st_new,J)+t_cn(st,J_new)-t_cn(st,J)-t_cn(st_new,J_new);
                end
            end
            if ~isempty(find(time_change<0, 1))
                [~,pos]=min(time_change); %�ҵ��͹���J�����ֿ�ѡ�������ʱ���С���Ĺ�������
                J_change=J_set(pos); %�ҵ��͹���J�����ֿ�Ĺ���
                st_change=chrom_fcs(1,J_change);
                chrom_fcs(1,J)=st_change;
                chrom_fcs(1,J_change)=st+F;
                bj_decode(2,J)=st_change-F;
                bj_decode(2,J_change)=st;
                objectives(1)=objectives(1)+time_change(pos)*(pr_yun-pr_cun(1,kk)); %���㽻���ֿ��ĳɱ��仯
            end
        end
    end
    chrom(2,1:n)=chrom_fcs;
    Population_orss(i).Chromesome=chrom;
    Population_orss(i).decode=bj_decode;
    Population_orss(i).objectives=objectives;
end
end