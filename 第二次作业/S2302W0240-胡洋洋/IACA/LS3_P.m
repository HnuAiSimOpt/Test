function [Population_orss]=LS3_P(Population_decode,popsize,n,F,Job,Style,t_cn,pr_yun,pr_cun)
% 工件的仓库选择交换，增大库存成本的同时能够减小运输时间，总体而言降低成本
Population_orss=Population_decode;
for i=1:popsize
    chrom=Population_orss(i).Chromesome;
    chrom_fcs=chrom(2,1:n); %工件的加工工厂和仓库选择序列
    bj_decode=Population_orss(i).decode;
    objectives=Population_orss(i).objectives;
    [~,J_cs]=find(chrom_fcs>F); %找到由仓库调拨的工件集合
    for kk=1:Style
        J_set=J_cs(Job(J_cs)==kk); %找到由仓库调拨且类型为kk的工件
        if length(J_set)>1
            J=J_set(unidrnd(length(J_set))); %随机选择一个工件进行仓库交换
            st=chrom_fcs(1,J)-F; %工件J选择的仓库
            J_set(J_set==J)=[];
            time_change=zeros(1,length(J_set)); %记录工件J和另一工件交换仓库后的运输时间变化量
            for j=1:length(J_set)
                J_new=J_set(j); %确定交换仓库的另一工件
                st_new=chrom_fcs(1,J_new)-F; %另一工件选择的仓库
                if st_new==st
                    time_change(j)=0;
                else
                    time_change(j)=t_cn(st_new,J)+t_cn(st,J_new)-t_cn(st,J)-t_cn(st_new,J_new);
                end
            end
            if ~isempty(find(time_change<0, 1))
                [~,pos]=min(time_change); %找到和工件J交换仓库选择后运输时间减小最大的工件索引
                J_change=J_set(pos); %找到和工件J交换仓库的工件
                st_change=chrom_fcs(1,J_change);
                chrom_fcs(1,J)=st_change;
                chrom_fcs(1,J_change)=st+F;
                bj_decode(2,J)=st_change-F;
                bj_decode(2,J_change)=st;
                objectives(1)=objectives(1)+time_change(pos)*(pr_yun-pr_cun(1,kk)); %计算交换仓库后的成本变化
            end
        end
    end
    chrom(2,1:n)=chrom_fcs;
    Population_orss(i).Chromesome=chrom;
    Population_orss(i).decode=bj_decode;
    Population_orss(i).objectives=objectives;
end
end