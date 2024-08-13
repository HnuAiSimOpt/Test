function [Population_orff]=LS2_P(Population_home,popsize,n,F,Job,t_fn,pr_cun,pr_machine,pr_pause,Weight)
% 同一工厂内的工件根据一定规则交换加工顺序
Population_orff=Population_home;
for i=1:popsize
    Population_chu=Population_home(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    factory_bj=Population_chu.factory_bj;
    objectives=Population_chu.objectives;
    objectives_change=objectives;
    IT_new=Population_chu.IT;
    for f=1:F
        J=factory_bj{f}; %工厂f加工的工件集合
        delay_cost=zeros(1,length(J)); %记录此工厂中各工件的延迟惩罚
        for j=1:length(J)
            job=J(j);
            delay_cost(j)=max(0,bj_decode(4,job)+t_fn(f,job)-IT_new(job))*Weight(job);
        end
        [~,posd_f]=max(delay_cost); %找到延迟惩罚最大的工件在工厂中的加工位置
        [~,posd]=find(delay_cost>0); 
        Jd=J(posd); %找到此工厂中所有的延误工件
        J_delay=J(posd_f(1)); %确定延迟惩罚最大的工件
        [~,posd_os]=find(chrom(1,1:n)==J_delay); %确定延迟惩罚最大的工件在工件加工序列中的位置
        kind_delay=Job(J_delay); %最大延误工件的类型
        Jd_same=Jd(Job(Jd)==kind_delay);
        Jd_same(Jd_same==J_delay)=[]; %同一加工工厂中除工件J_delay外类型也为kind_delay的工件集合
        if ~isempty(Jd_same)
            cost_change=zeros(1,length(Jd_same)); %记录两个工件加工顺序交换后的成本变化量
            for k=1:length(Jd_same)
                J_new=Jd_same(k); %找到与工件J_delay同一类型的另一工件
                cost_before=delay_cost(posd_f)+max(0,IT_new(J_new)-bj_decode(4,J_new)-t_fn(f,J_new))*pr_cun(kind_delay)+max(0,bj_decode(4,J_new)+t_fn(f,J_new)-IT_new(J_new))*Weight(J_new); %运输成本不计，因为工件加工顺序互换前后运输成本不改变
                if IT_new(J_delay)<IT_new(J_new)&&bj_decode(4,J_delay)+t_fn(f,J_delay)>bj_decode(4,J_new)+t_fn(f,J_new)&&Weight(J_delay)>Weight(J_new)
                    cost_after=max(0,IT_new(J_new)-bj_decode(4,J_delay)-t_fn(f,J_new))*pr_cun(kind_delay)+max(0,bj_decode(4,J_delay)+t_fn(f,J_new)-IT_new(J_new))*Weight(J_new)+max(0,IT_new(J_delay)-bj_decode(4,J_new)-t_fn(f,J_delay))*pr_cun(kind_delay)+max(0,bj_decode(4,J_new)+t_fn(f,J_delay)-IT_new(J_delay))*Weight(J_delay);
                    cost_change(k)=cost_after-cost_before;
                end
            end
            if ~isempty(find(cost_change<0, 1)) %如果存在交换加工顺序后成本降低的情况
                [~,pos_j]=find(cost_change==min(cost_change),1); %找到成本减小最大的交换工件在集合J_same中的位置
                J_change=Jd_same(pos_j); %即将与最大延误工件交换加工位置的工件
                [~,pos_os_change]=find(chrom(1,1:n)==J_change); %找到交换工件在加工序列中的位置
                [~,pos_f_change]=find(J==J_change); %找到交换工件的此选定工厂中的加工位置
                chrom(1,posd_os)=J_change;
                chrom(1,pos_os_change)=J_delay;
                factory_bj{f}(posd_f)=J_change;
                factory_bj{f}(pos_f_change)=J_delay;
                miss_c_before1=pr_machine(J_delay)*max(0,IT_new(J_delay)-bj_decode(4,J_delay)-t_fn(f,J_delay))+pr_pause(J_delay)*max(0,bj_decode(4,J_delay)+t_fn(f,J_delay)-IT_new(J_delay));
                miss_c_before2=pr_machine(J_change)*max(0,IT_new(J_change)-bj_decode(4,J_change)-t_fn(f,J_change))+pr_pause(J_change)*max(0,bj_decode(4,J_change)+t_fn(f,J_change)-IT_new(J_change));
                miss_c_after1=pr_machine(J_delay)*max(0,IT_new(J_delay)-bj_decode(4,J_change)-t_fn(f,J_delay))+pr_pause(J_delay)*max(0,bj_decode(4,J_change)+t_fn(f,J_delay)-IT_new(J_delay));
                miss_c_after2=pr_machine(J_change)*max(0,IT_new(J_change)-bj_decode(4,J_delay)-t_fn(f,J_change))+pr_pause(J_change)*max(0,bj_decode(4,J_delay)+t_fn(f,J_change)-IT_new(J_change));
                miss_c_change=miss_c_after1+miss_c_after2-miss_c_before1-miss_c_before2;
                starttime_change=bj_decode(3,J_change);
                endtime_change=bj_decode(4,J_change); %交换工件交换前的原加工开始时间和结束时间
                bj_decode(3,J_change)=bj_decode(3,J_delay);
                bj_decode(4,J_change)=bj_decode(4,J_delay);
                bj_decode(3,J_delay)=starttime_change;
                bj_decode(4,J_delay)=endtime_change;
                objectives_change(1)=objectives_change(1)+min(cost_change);
                objectives_change(2)=objectives_change(2)+miss_c_change;
            end
        end
    end
    R=dominate(objectives,objectives_change);
    if ~R&&~isequal(objectives,objectives_change)
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.factory_bj=factory_bj;
        Population_chu.objectives=objectives_change;
%         Population_orff(i)=Population_chu;
        Population_orff=[Population_orff Population_chu];
    end
end
end