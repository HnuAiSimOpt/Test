function [Population_cancel]=orientate_cancel(Population_home,popsize,n,F,w,S,Job,pretime,t_fn,t_cn,transfertime,pr_cun,pr_machine,pr_pause,pr_yun,C_pre,I_time,maintain_EL,Weight)
% 对每个维护人员上最后一个进行维护活动的最后一个装备判断其维护后相较于初始是否降低了成本
Population_cancel=Population_home;
for i=1:popsize
    Population_chu=Population_cancel(i);
    chrom=Population_cancel(i).Chromesome;
    bj_decode=Population_cancel(i).decode;
    worker_bj=Population_cancel(i).worker_bj;
    worker_protime=Population_cancel(i).worker_protime;
    objectives=Population_cancel(i).objectives;
    objectives_change=objectives;
    IT=Population_cancel(i).IT;
    IT_new=IT;
    for s=1:w*S
        if ~isempty(worker_bj{s})
            equip=worker_bj{s}(length(worker_bj{s})); %维护人员s上的最后一个维护装备
            kind=Job(equip);
            num_of_worker=bj_decode(5,equip);
            num_of_method=bj_decode(6,equip);
            if length(worker_bj{s})>1 %如果此维护人员s上的维护装备超过1个
                equip_last=worker_bj{s}(length(worker_bj{s})-1); %维护人员上倒数第二个维护装备
                if chrom(2,equip)<=F   
                    cost_nows=max(0,I_time(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))*pr_machine(equip)+max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-I_time(equip))*pr_pause(equip);
                    % 计算不进行维护活动需求方的付出成本
                    Miss_cost_after=max(0,IT(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))*pr_machine(equip)+max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT(equip))*pr_pause(equip);
                    % 计算进行维护活动后需求方对于备件不准时送达的损失成本
                    trans_cost_after=pr_yun*transfertime(equip_last,equip); %计算进行维护活动所需的工人转移成本
                    main_cost_after=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算进行维护活动所需的维护成本
                    if bj_decode(7,equip)>maintain_EL(2,equip)
                        cost_ws=Miss_cost_after+trans_cost_after+main_cost_after+pr_pause(equip)*(bj_decode(8,equip)-maintain_EL(2,equip));
                    else
                        cost_ws=Miss_cost_after+trans_cost_after+main_cost_after+pr_pause(equip)*pretime(num_of_worker,num_of_method);
                    end
                    if  cost_ws>cost_nows %如果执行维护活动后的成本高于维护前的
                        chrom(2,n+equip)=0;
                        worker_protime{1,s}(length(worker_protime{1,s}))=[];
                        bj_decode(5:8,equip)=0;
                        worker_bj{s}(length(worker_bj{s}))=[];
                        worker_protime{2,s}(length(worker_protime{2,s}))=[];
                        objectives_change(2)=objectives_change(2)+cost_nows-cost_ws;
                        IT_new(equip)=I_time(equip); %取消维护活动后其理想交货期
                        miss_before=pr_cun(kind)*max(0,IT(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))+Weight(equip)*max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT(equip));
                        % 计算装备equip进行维护活动时供应方的惩罚成本
                        miss_after=pr_cun(kind)*max(0,IT_new(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))+Weight(equip)*max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT_new(equip));
                        % 计算装备equip取消维护活动时供应方的惩罚成本
                        objectives_change(1)=objectives_change(1)+miss_after-miss_before;
                    end
                else
                    chrom(2,n+equip)=0;
                    bj_decode(5:8,equip)=0;
                    worker_bj{s}(length(worker_bj{s}))=[];
                    worker_protime{1,s}(length(worker_protime{1,s}))=[];
                    worker_protime{2,s}(length(worker_protime{2,s}))=[];
                    cost_nows=0;
        %             Miss_cost_after=max(0,IT(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))*pr_machine(equip)+max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT(equip))*pr_pause(equip);
                    % 计算进行维护活动后需求方对于备件不准时送达的损失成本
                    trans_cost_after=pr_yun*transfertime(equip_last,equip); %计算进行维护活动所需的工人转移成本
                    main_cost_after=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算进行维护活动所需的维护成本
                    if bj_decode(7,equip)>maintain_EL(2,equip)
                        cost_ws=trans_cost_after+main_cost_after+pr_pause(equip)*(bj_decode(8,equip)-maintain_EL(2,equip));
                    else
                        cost_ws=trans_cost_after+main_cost_after+pr_pause(equip)*pretime(num_of_worker,num_of_method);
                    end
                    objectives_change(2)=objectives_change(2)+cost_nows-cost_ws;
                    IT_new(equip)=I_time(equip); %取消维护活动后其理想交货期
                    cun_before=pr_cun(kind)*(IT(equip)-t_cn(bj_decode(2,equip),equip));
                    % 计算装备equip进行维护活动时供应方的惩罚成本
                    cun_after=pr_cun(kind)*(IT_new(equip)-t_cn(bj_decode(2,equip),equip));
                    % 计算装备equip取消维护活动时供应方的惩罚成本
                    objectives_change(1)=objectives_change(1)+cun_after-cun_before;
                end
            else %如果维护人员s上的维护装备只有一台
                if chrom(2,equip)<=F   
                    cost_nows=max(0,I_time(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))*pr_machine(equip)+max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-I_time(equip))*pr_pause(equip);
                    % 计算不进行维护活动需求方的付出成本
                    Miss_cost_after=max(0,IT(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))*pr_machine(equip)+max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT(equip))*pr_pause(equip);
                    % 计算进行维护活动后需求方对于备件不准时送达的损失成本
                    main_cost_after=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算进行维护活动所需的维护成本
                    if bj_decode(7,equip)>maintain_EL(2,equip)
                        cost_ws=Miss_cost_after+main_cost_after+pr_pause(equip)*(bj_decode(8,equip)-maintain_EL(2,equip));
                    else
                        cost_ws=Miss_cost_after+main_cost_after+pr_pause(equip)*pretime(num_of_worker,num_of_method);
                    end
                    if  cost_ws>cost_nows %如果执行维护活动后的成本高于维护前的
                        chrom(2,n+equip)=0;
                        worker_protime{1,s}(length(worker_protime{1,s}))=[];
                        bj_decode(5:8,equip)=0;
                        worker_bj{s}(length(worker_bj{s}))=[];
                        worker_protime{2,s}(length(worker_protime{2,s}))=[];
                        objectives_change(2)=objectives_change(2)+cost_nows-cost_ws;
                        IT_new(equip)=I_time(equip); %取消维护活动后其理想交货期
                        miss_before=pr_cun(kind)*max(0,IT(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))+Weight(equip)*max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT(equip));
                        % 计算装备equip进行维护活动时供应方的惩罚成本
                        miss_after=pr_cun(kind)*max(0,IT_new(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip))+Weight(equip)*max(0,bj_decode(4,equip)+t_fn(bj_decode(1,equip),equip)-IT_new(equip));
                        % 计算装备equip取消维护活动时供应方的惩罚成本
                        objectives_change(1)=objectives_change(1)+miss_after-miss_before;
                    end
                else
                    chrom(2,n+equip)=0;
                    bj_decode(5:8,equip)=0;
                    worker_bj{s}(length(worker_bj{s}))=[];
                    worker_protime{1,s}(length(worker_protime{1,s}))=[];
                    worker_protime{2,s}(length(worker_protime{2,s}))=[];
                    cost_nows=0;
                    main_cost_after=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算进行维护活动所需的维护成本
                    if bj_decode(7,equip)>maintain_EL(2,equip)
                        cost_ws=main_cost_after+pr_pause(equip)*(bj_decode(8,equip)-maintain_EL(2,equip));
                    else
                        cost_ws=main_cost_after+pr_pause(equip)*pretime(num_of_worker,num_of_method);
                    end
                    objectives_change(2)=objectives_change(2)+cost_nows-cost_ws;
                    IT_new(equip)=I_time(equip); %取消维护活动后其理想交货期
                    cun_before=pr_cun(kind)*(IT(equip)-t_fn(bj_decode(2,equip),equip));
                    % 计算装备equip进行维护活动时供应方的惩罚成本
                    cun_after=pr_cun(kind)*(IT_new(equip)-t_fn(bj_decode(2,equip),equip));
                    % 计算装备equip取消维护活动时供应方的惩罚成本
                    objectives_change(1)=objectives_change(1)+cun_after-cun_before;
                end
            end
        end
    end
    R=dominate(objectives,objectives_change);
    if ~R&&~isequal(objectives,objectives_change)
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.worker_bj=worker_bj;
        Population_chu.worker_protime=worker_protime;
        Population_chu.IT=IT_new;
        Population_chu.objectives=objectives_change;
        Population_cancel=[Population_cancel Population_chu];
    end
end
end