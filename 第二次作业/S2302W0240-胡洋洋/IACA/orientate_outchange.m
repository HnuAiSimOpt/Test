function [Population_change]=orientate_outchange(Population_home,popsize,n,w,S,Job,pretime,transfertime,t_fn,pr_cun,pr_yun,pr_machine,pr_pause,MHV,repair,rate,maintain_EL,Weight)
% 功能说明：随机交换两个维护工人上的任一维护装备，目的是保持种群的多样性
Population_change=Population_home;
for s=1:popsize
    chrom=Population_home(s).Chromesome;
    bj_decode=Population_home(s).decode;
    worker_bj=Population_home(s).worker_bj;
    worker_protime=Population_home(s).worker_protime;
    IT=Population_home(s).IT;
    IT_new=IT;
    objectives=Population_home(s).objectives;
    objectives_change=objectives;
    worker=zeros(1,w*S);
    for wo=1:w*S
        if ~isempty(worker_bj{wo})
            worker(wo)=wo;
        end
    end
    worker(worker==0)=[];
    if length(worker)>1
        wo_num=randperm(length(worker),2);
        wo_max=worker(wo_num(1));
        wo_min=worker(wo_num(2)); %确定两个交换维护装备的维护工人
        pos_max=randperm(length(worker_bj{wo_max}),1); 
        swap_bj1=worker_bj{wo_max}(pos_max);  %随机找到其中一个工人的交换装备
        pos_min=randperm(length(worker_bj{wo_min}),1);
        swap_bj2=worker_bj{wo_min}(pos_min); %随机确定另一工人的交换装备
        worker_bj{wo_max}(pos_max)=swap_bj2;
        worker_bj{wo_min}(pos_min)=swap_bj1; %交换两个选定工人的选定装备
        [~,index1]=find(chrom(1,n+1:2*n)==swap_bj1);
        [~,index2]=find(chrom(1,n+1:2*n)==swap_bj2); 
        chrom(1,n+index1)=swap_bj2;
        chrom(1,n+index2)=swap_bj1; %在维护序列中交换这两装备
        kind1=Job(swap_bj1);
        kind2=Job(swap_bj2); %确定这两装备的备件类型便于之后对于提前和延迟惩罚的计算
        chrom(2,n+swap_bj1)=wo_min;
        chrom(2,n+swap_bj2)=wo_max; %交换这两装备的维护工人选择
        worker1=bj_decode(5,swap_bj1);
        method1=bj_decode(6,swap_bj1); 
        worker2=bj_decode(5,swap_bj2);
        method2=bj_decode(6,swap_bj2); 
        bj_decode(5,swap_bj1)=worker2;
        bj_decode(6,swap_bj1)=method2;
        bj_decode(5,swap_bj2)=worker1;
        bj_decode(6,swap_bj2)=method1; %更新解码信息表中装备的维护工人和策略选择

        %% 对这两个维护工人的维护装备序列重新计算各目标值
        miss_s_change=0;
        miss_c_change=0;
        pause_change=0;
        if pos_max==1
            trans_change=0;
            st=maintain_EL(1,swap_bj2);
        else
            job_last=worker_bj{wo_max}(pos_max-1); %此交换装备前一个装备
            trans_change=pr_yun*(transfertime(job_last,swap_bj2)-transfertime(job_last,swap_bj1));
            wo_start=worker_protime{2,wo_max}(pos_max-1)+transfertime(job_last,swap_bj2);
            if wo_start<=maintain_EL(1,swap_bj2)
                st=maintain_EL(1,swap_bj2);
            else
                st=wo_start;
            end
        end
        et=st+pretime(worker1,method1);
        IT_new(swap_bj2)=et+MHV(swap_bj2)*repair(method1)/rate(swap_bj2);
        pause_cost_before=pr_pause(swap_bj1)*(max(0,worker_protime{1,wo_max}(pos_max)-maintain_EL(2,swap_bj1))+pretime(worker1,method1));
        pause_cost_after=pr_pause(swap_bj2)*(max(0,st-maintain_EL(2,swap_bj2))+pretime(worker1,method1));
        pause_change=pause_change+pause_cost_after-pause_cost_before;
        worker_protime{1,wo_max}(pos_max)=st;
        worker_protime{2,wo_max}(pos_max)=et;
        bj_decode(7,swap_bj2)=st;
        bj_decode(8,swap_bj2)=et;
        miss_s_before=pr_cun(kind1)*max(0,IT(swap_bj1)-bj_decode(4,swap_bj1)-t_fn(bj_decode(1,swap_bj1),swap_bj1))+Weight(swap_bj1)*max(0,bj_decode(4,swap_bj1)+t_fn(bj_decode(1,swap_bj1),swap_bj1)-IT(swap_bj1));
        miss_s_after=pr_cun(kind2)*max(0,IT_new(swap_bj2)-bj_decode(4,swap_bj2)-t_fn(bj_decode(1,swap_bj2),swap_bj2))+Weight(swap_bj2)*max(0,bj_decode(4,swap_bj2)+t_fn(bj_decode(1,swap_bj2),swap_bj2)-IT_new(swap_bj2));
        miss_c_before=pr_machine(swap_bj1)*max(0,IT(swap_bj1)-bj_decode(4,swap_bj1)-t_fn(bj_decode(1,swap_bj1),swap_bj1))+pr_pause(swap_bj1)*max(0,bj_decode(4,swap_bj1)+t_fn(bj_decode(1,swap_bj1),swap_bj1)-IT(swap_bj1));
        miss_c_after=pr_machine(swap_bj2)*max(0,IT_new(swap_bj2)-bj_decode(4,swap_bj2)-t_fn(bj_decode(1,swap_bj2),swap_bj2))+pr_pause(swap_bj2)*max(0,bj_decode(4,swap_bj2)+t_fn(bj_decode(1,swap_bj2),swap_bj2)-IT_new(swap_bj2));
        miss_s_change=miss_s_change+miss_s_after-miss_s_before;
        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
        for j=pos_max+1:length(worker_bj{wo_max})
            job=worker_bj{wo_max}(j);
            job_last=worker_bj{wo_max}(j-1);
            kind=Job(job);
            if j==pos_max+1
                trans_change=trans_change+pr_yun*(transfertime(swap_bj2,job)-transfertime(swap_bj1,job));
            end
            wo_start=worker_protime{2,wo_max}(j-1)+transfertime(job_last,job);
            if wo_start<=maintain_EL(1,job)
                st=maintain_EL(1,job);
            else
                st=wo_start;
            end
            et=st+pretime(worker1,method1);
            IT_new(job)=et+MHV(job)*repair(method1)/rate(job);
            pause_cost_before=pr_pause(job)*(max(0,worker_protime{1,wo_max}(j)-maintain_EL(2,job))+pretime(worker1,method1));
            pause_cost_after=pr_pause(job)*(max(0,st-maintain_EL(2,job))+pretime(worker1,method1));
            pause_change=pause_change+pause_cost_after-pause_cost_before;
            worker_protime{1,wo_max}(j)=st;
            worker_protime{2,wo_max}(j)=et;
            bj_decode(7,job)=st;
            bj_decode(8,job)=et;
            miss_s_before=pr_cun(kind)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
            miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
            miss_c_before=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
            miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
            miss_s_change=miss_s_change+miss_s_after-miss_s_before;
            miss_c_change=miss_c_change+miss_c_after-miss_c_before;
        end

        if pos_min==1
            st=maintain_EL(1,swap_bj1);
        else
            job_last=worker_bj{wo_min}(pos_min-1); %此交换装备前一个装备
            trans_change=trans_change+pr_yun*(transfertime(job_last,swap_bj1)-transfertime(job_last,swap_bj2));
            wo_start=worker_protime{2,wo_min}(pos_min-1)+transfertime(job_last,swap_bj1);
            if wo_start<=maintain_EL(1,swap_bj1)
                st=maintain_EL(1,swap_bj1);
            else
                st=wo_start;
            end
        end
        et=st+pretime(worker2,method2);
        IT_new(swap_bj1)=et+MHV(swap_bj1)*repair(method2)/rate(swap_bj1);
        pause_cost_before=pr_pause(swap_bj2)*(max(0,worker_protime{1,wo_min}(pos_min)-maintain_EL(2,swap_bj2))+pretime(worker2,method2));
        pause_cost_after=pr_pause(swap_bj1)*(max(0,st-maintain_EL(2,swap_bj1))+pretime(worker2,method2));
        pause_change=pause_change+pause_cost_after-pause_cost_before;
        worker_protime{1,wo_min}(pos_min)=st;
        worker_protime{2,wo_min}(pos_min)=et;
        bj_decode(7,swap_bj1)=st;
        bj_decode(8,swap_bj1)=et;
        miss_s_before=pr_cun(kind2)*max(0,IT(swap_bj2)-bj_decode(4,swap_bj2)-t_fn(bj_decode(1,swap_bj2),swap_bj2))+Weight(swap_bj2)*max(0,bj_decode(4,swap_bj2)+t_fn(bj_decode(1,swap_bj2),swap_bj2)-IT(swap_bj2));
        miss_s_after=pr_cun(kind1)*max(0,IT_new(swap_bj1)-bj_decode(4,swap_bj1)-t_fn(bj_decode(1,swap_bj1),swap_bj1))+Weight(swap_bj1)*max(0,bj_decode(4,swap_bj1)+t_fn(bj_decode(1,swap_bj1),swap_bj1)-IT_new(swap_bj1));
        miss_c_before=pr_machine(swap_bj2)*max(0,IT(swap_bj2)-bj_decode(4,swap_bj2)-t_fn(bj_decode(1,swap_bj2),swap_bj2))+pr_pause(swap_bj2)*max(0,bj_decode(4,swap_bj2)+t_fn(bj_decode(1,swap_bj2),swap_bj2)-IT(swap_bj2));
        miss_c_after=pr_machine(swap_bj1)*max(0,IT_new(swap_bj1)-bj_decode(4,swap_bj1)-t_fn(bj_decode(1,swap_bj1),swap_bj1))+pr_pause(swap_bj1)*max(0,bj_decode(4,swap_bj1)+t_fn(bj_decode(1,swap_bj1),swap_bj1)-IT_new(swap_bj1));
        miss_s_change=miss_s_change+miss_s_after-miss_s_before;
        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
        for j=pos_min+1:length(worker_bj{wo_min})
            job=worker_bj{wo_min}(j);
            kind=Job(job);
            job_last=worker_bj{wo_min}(j-1);
            if j==pos_min+1
                trans_change=trans_change+pr_yun*(transfertime(swap_bj1,job)-transfertime(swap_bj2,job));
            end
            wo_start=worker_protime{2,wo_min}(j-1)+transfertime(job_last,job);
            if wo_start<=maintain_EL(1,job)
                st=maintain_EL(1,job);
            else
                st=wo_start;
            end
            et=st+pretime(worker2,method2);
            IT_new(job)=et+MHV(job)*repair(method2)/rate(job);
            pause_cost_before=pr_pause(job)*(max(0,worker_protime{1,wo_min}(j)-maintain_EL(2,job))+pretime(worker2,method2));
            pause_cost_after=pr_pause(job)*(max(0,st-maintain_EL(2,job))+pretime(worker2,method2));
            pause_change=pause_change+pause_cost_after-pause_cost_before;
            worker_protime{1,wo_min}(j)=st;
            worker_protime{2,wo_min}(j)=et;
            bj_decode(7,job)=st;
            bj_decode(8,job)=et;
            miss_s_before=pr_cun(kind)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
            miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
            miss_c_before=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
            miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
            miss_s_change=miss_s_change+miss_s_after-miss_s_before;
            miss_c_change=miss_c_change+miss_c_after-miss_c_before;
        end

        objectives_change(2)=objectives_change(2)+miss_c_change+trans_change+pause_change; %插入备件后的总成本
        objectives_change(1)=objectives_change(1)+miss_s_change;
        R=dominate(objectives_change,objectives);
        if R
           Population_change(s).Chromesome=chrom;
           Population_change(s).decode=bj_decode;
           Population_change(s).worker_bj=worker_bj;
           Population_change(s).worker_protime=worker_protime;
           Population_change(s).IT=IT_new;
           Population_change(s).objectives=objectives_change;
        end
    end
end
end    