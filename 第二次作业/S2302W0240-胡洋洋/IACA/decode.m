function [Population_decode]=decode(popsize,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,IT,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    Ch=Population_decode(i).Chromesome;
    J_pro=Ch(1,1:n); %工件序列
    supply=Ch(2,1:n); %供应方式选择
    J_maintain=Ch(1,n+1:2*n); %装备维护序列
    workerselect=Ch(2,n+1:2*n); %装备维护人员选择
    bj_decode=zeros(8,n); %依次为各场点的所有备件分配工厂、仓库、加工开始时间、加工结束时间、维护人员选择、维护策略选择、装备维护开始时间、装备维护结束时间
    start_time=cell(1,F*M); %记录各台机器上的加工开始时间和加工结束时间
    end_time=cell(1,F*M);
    main_t=cell(2,w*S); %记录各个维护人员的每个维护活动的开始时间和结束时间
    factory_bj=cell(1,F); %记录各工厂的加工备件集
    worker_bj=cell(1,w*S); %记录各维护工人的维护装备集
    %% 解码生产调度中各工件的时间表以及目标值
    for j=1:n %进行所有备件加工工厂、库存调拨、时间排程
        job=J_pro(j); %当前处理备件
        kind=Job(job); %当前备件的类型
        if supply(1,job)<=F
            fa=supply(1,job); %确定该备件选择的加工工厂
            bj_decode(1,job)=fa; %储存该备件的加工工厂
            if isempty(factory_bj{fa}) %判断该工厂是否已有备件加工，如果没有
                for k=1:M
                    if k==1
                        start_time{(fa-1)*M+k}(1)=0; %该工厂第一台机器上第一个工件的加工开始时间
                    else
                        start_time{(fa-1)*M+k}(1)=end_time{(fa-1)*M+k-1}(1);
                    end
                    end_time{(fa-1)*M+k}(1)=start_time{(fa-1)*M+k}(1)+protime(k,kind); %储存该工件在选定工厂中流水线各台机器的开始时间和结束时间
                end
            else 
                for k=1:M
                    if k==1
                        ST=end_time{(fa-1)*M+k}(length(end_time{(fa-1)*M+k}));
                        ET=ST+protime(k,kind);
                        start_time{(fa-1)*M+k}=[start_time{(fa-1)*M+k} ST];
                        end_time{(fa-1)*M+k}=[end_time{(fa-1)*M+k} ET];
                    else
                        ST=max(end_time{(fa-1)*M+k-1}(length(end_time{(fa-1)*M+k-1})),end_time{(fa-1)*M+k}(length(end_time{(fa-1)*M+k})));
                        ET=ST+protime(k,kind);
                        start_time{(fa-1)*M+k}(length(start_time{(fa-1)*M+k})+1)=ST;
                        end_time{(fa-1)*M+k}(length(end_time{(fa-1)*M+k})+1)=ET;
                    end
                end
            end
            starttime=start_time{(fa-1)*M+1}(length(start_time{(fa-1)*M+1}));
            endtime=end_time{fa*M}(length(end_time{fa*M}));
            factory_bj{fa}=[factory_bj{fa} job];
        else
            starttime=0;
            endtime=0;
            bj_decode(2,job)=supply(job)-F; %储存该备件的调拨仓库编号
        end
        bj_decode(3,job)=starttime;
        bj_decode(4,job)=endtime;
    end
    %% 解码各装备维护活动的计划表及目标值
    IT_new=IT; %储存进行维护活动后的理想交货期
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
        end
    end
    %% 计算供应方的总成本（库存+运输+提前/延迟惩罚）
    Time_of_arrive=zeros(1,n); %储存各场点的备件送达时间
    Cun_cost=0;
    Yun_cost=0;
    Miss_cost=0;
    cangku=store;
    for j=1:n
        kind=Job(j);
        if bj_decode(1,j)~=0
            gong=bj_decode(1,j);
            Time_of_arrive(j)=bj_decode(4,j)+t_fn(gong,j);
            yun_cost=t_cn(gong,j)*pr_yun; %计算备件来自工厂加工时的运输成本
        else
            cang=bj_decode(2,j);
            [~,pos_kind]=find(cangku{cang}(1,:)==kind);
            cangku{cang}(2,pos_kind)=cangku{cang}(2,pos_kind)-1;
            if t_cn(cang,j)<IT_new(1,j) %判断零时刻从仓库调拨时到达运维需求场点的时间是否早于规定的交货时间
                Time_of_arrive(j)=IT_new(1,j);
                cun_time=Time_of_arrive(j)-t_cn(cang,j);
                cun_cost=pr_cun(1,kind)*cun_time; %该备件的库存成本
            else
                Time_of_arrive(j)=t_cn(cang,j);
                cun_cost=0;
            end
            yun_cost=t_cn(cang,j)*pr_yun; %计算备件来自仓库调拨时的运输成本
            Cun_cost=Cun_cost+cun_cost;
        end
        Yun_cost=Yun_cost+yun_cost; %运输总成本
        miss_cost=pr_cun(1,kind)*max(0,IT_new(1,j)-Time_of_arrive(j))+Weight(1,j)*max(0,Time_of_arrive(j)-IT_new(1,j)); %计算某场点的提前或拖期成本
        Miss_cost=Miss_cost+miss_cost; %计算各场点的提前或延期成本和
    end
    for j=1:Style
        num=0;
        for k=1:C
            if ~isempty(cangku{k})
                [~,pos]=find(cangku{k}(1,:)==j);
                if ~isempty(pos)
                    num=num+cangku{k}(2,pos); %计算该类型备件在所有仓库中的总剩余数量
                end
            end
        end
        Cun_cost=Cun_cost+pr_cun(1,j)*num*T; %计算加上各类型剩余备件的库存成本后的总库存成本
    end
    COST_supply=Yun_cost+Cun_cost+Miss_cost; %供应方总成本（运输、库存和提前/拖期成本之和） 
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
    objective=[COST_supply COST_customer];
    Population_decode(i).decode=bj_decode;
    Population_decode(i).machine_start_time=start_time;
    Population_decode(i).machine_end_time=end_time;
    Population_decode(i).factory_bj=factory_bj;
    Population_decode(i).worker_bj=worker_bj;
    Population_decode(i).worker_protime=main_t;
    Population_decode(i).objectives=objective;
    Population_decode(i).IT=IT_new;
end