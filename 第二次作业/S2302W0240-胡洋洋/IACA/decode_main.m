function [Population_decode]=decode_main(popsize,n,w,S,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    Ch=Population_decode(i).Chromesome;
    bj_decode=Population_decode(i).decode;
    objectives=Population_decode(i).objectives;
    IT=Population_decode(i).IT;
    J_maintain=Ch(1,n+1:2*n); %装备维护序列
    workerselect=Ch(2,n+1:2*n); %装备维护人员选择
    main_t=cell(2,w*S); %记录各个维护人员的每个维护活动的开始时间和结束时间
    worker_bj=cell(1,w*S); %记录各维护工人的维护装备集
    %% 解码各装备维护活动的计划表及目标值
    IT_new=I_time; %储存进行维护活动后的理想交货期
    Maintain_cost=0; %总维护费用
    Transfer_cost=0; %总维护人员转移成本
    Pause_cost=0; %总的装备停工损失
    for j=1:n
        equip=J_maintain(1,j); 
        worker=workerselect(equip); %确定当前装备以及其选择的维护人员
        if worker~=0
            if mod(worker,w)==0
                num_of_worker=w; %选择该维护策略下的维护人员编号
                num_of_method=worker/w; %确定选择的维护策略
            else
                num_of_worker=mod(worker,w); 
                num_of_method=(worker-num_of_worker)/w+1;
            end
            bj_decode(5,equip)=num_of_worker;
            bj_decode(6,equip)=num_of_method;
            main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算该装备的维护费用
            Maintain_cost=Maintain_cost+main_cost;
            if isempty(worker_bj{worker})
                main_t{1,worker}(1)=maintain_EL(1,equip);
                main_t{2,worker}(1)=main_t{1,worker}(1)+pretime(num_of_worker,num_of_method); %计算此装备维护活动的开始和结束时间
                pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
            else
                equip_last=worker_bj{worker}(length(worker_bj{worker})); %找到当前装备所选工人此前维护的最后一个装备
                wo_start=main_t{2,worker}(length(main_t{2,worker}))+transfertime(equip_last,equip); %计算选定工人本次维护活动的最早开始时间
                trans_cost=pr_yun*transfertime(equip_last,equip); %计算每个装备进行维护前的转移成本
                Transfer_cost=Transfer_cost+trans_cost; %计算工人全部转移次数的总成本
                if wo_start<=maintain_EL(1,equip)
                    main_t{1,worker}(length(main_t{1,worker})+1)=maintain_EL(1,equip);
                    main_t{2,worker}(length(main_t{2,worker})+1)=main_t{1,worker}(length(main_t{1,worker}))+pretime(num_of_worker,num_of_method);
                    pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                else
                    if wo_start>maintain_EL(1,equip)&&wo_start<=maintain_EL(2,equip)
                        main_t{1,worker}(length(main_t{1,worker})+1)=wo_start;
                        main_t{2,worker}(length(main_t{2,worker})+1)=main_t{1,worker}(length(main_t{1,worker}))+pretime(num_of_worker,num_of_method);
                        pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                    else
                        main_t{1,worker}(length(main_t{1,worker})+1)=wo_start;
                        main_t{2,worker}(length(main_t{2,worker})+1)=main_t{1,worker}(length(main_t{1,worker}))+pretime(num_of_worker,num_of_method);
                        pause_cost=pr_pause(1,equip)*(main_t{2,worker}(length(main_t{2,worker}))-maintain_EL(2,equip));
                    end
                end
            end
            Pause_cost=Pause_cost+pause_cost; %各进行维护装备交货前的停工损失
            bj_decode(7,equip)=main_t{1,worker}(length(main_t{1,worker}));
            bj_decode(8,equip)=main_t{2,worker}(length(main_t{2,worker}));
            worker_bj{worker}=[worker_bj{worker} equip];
            IT_new(1,equip)=main_t{2,worker}(length(main_t{2,worker}))+MHV(equip)*repair(num_of_method)/rate(equip);
        else
            bj_decode(5:8,equip)=0;
        end
    end
    %% 计算供应方的总成本（库存+运输+提前/延迟惩罚）
    Time_of_arrive=zeros(1,n); %储存各场点的备件送达时间
    miss_s_change=0;
    cun_change=0;
    for j=1:n
        if IT_new(j)~=IT(j)
            kind=Job(j);
            if bj_decode(1,j)~=0
                gong=bj_decode(1,j);
                Time_of_arrive(j)=bj_decode(4,j)+t_fn(gong,j);
                miss_s_before=pr_cun(kind)*max(0,IT(j)-Time_of_arrive(j))+Weight(j)*max(0,Time_of_arrive(j)-IT(j));
                miss_s_after=pr_cun(kind)*max(0,IT_new(j)-Time_of_arrive(j))+Weight(j)*max(0,Time_of_arrive(j)-IT_new(j));
                miss_s_change=miss_s_change+miss_s_after-miss_s_before;
            else
                cang=bj_decode(2,j);
                if t_cn(cang,j)<IT_new(1,j) %判断零时刻从仓库调拨时到达运维需求场点的时间是否早于规定的交货时间
                    cun_change=cun_change+pr_cun(kind)*(IT_new(j)-IT(j));
                end
            end
        end
    end

    %% 计算各装备交货早晚对应的装备浪费和停工损失
    Machine_cost=0; %总的装备利用浪费
    for j=1:n
        if Time_of_arrive(j)>IT_new(j)
            Pause_cost=Pause_cost+pr_pause(1,j)*(Time_of_arrive(j)-IT_new(j));
        else
            Machine_cost=Machine_cost+pr_machine(1,j)*(IT_new(j)-Time_of_arrive(j));
        end
    end
    COST_customer=Maintain_cost+Transfer_cost+Pause_cost+Machine_cost; %需求方的总成本
    objectives(1)=objectives(1)+cun_change+miss_s_change;
    objectives(2)=COST_customer;
    Population_decode(i).decode=bj_decode;
    Population_decode(i).worker_bj=worker_bj;
    Population_decode(i).worker_protime=main_t;
    Population_decode(i).objectives=objectives;
    Population_decode(i).IT=IT_new;
end