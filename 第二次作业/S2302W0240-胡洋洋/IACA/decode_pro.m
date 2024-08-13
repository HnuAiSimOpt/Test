function [Population_decode]=decode_pro(popsize,F,C,n,M,Style,T,store,Job,pr_cun,pr_yun,pr_pause,pr_machine,protime,t_fn,t_cn,Weight,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    IT=Population_decode(i).IT;
    Ch=Population_decode(i).Chromesome;
    bj_decode=Population_decode(i).decode;
    objectives=Population_decode(i).objectives;
    J_pro=Ch(1,1:n); %工件序列
    supply=Ch(2,1:n); %供应方式选择
    bj_decode_new=zeros(4,n); %对生产部分交叉变异后的个体重新计算供应部分工件信息
    start_time=cell(1,F*M); %记录各台机器上的加工开始时间和加工结束时间
    end_time=cell(1,F*M);
    factory_bj=cell(1,F); %记录各工厂的加工备件集
    %% 解码生产调度中各工件的时间表以及目标值
    for j=1:n %进行所有备件加工工厂、库存调拨、时间排程
        job=J_pro(j); %当前处理备件
        kind=Job(job); %当前备件的类型
        if supply(1,job)<=F
            fa=supply(1,job); %确定该备件选择的加工工厂
            bj_decode_new(1,job)=fa; %储存该备件的加工工厂
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
            bj_decode_new(2,job)=supply(job)-F; %储存该备件的调拨仓库编号
        end
        bj_decode_new(3,job)=starttime;
        bj_decode_new(4,job)=endtime;
    end
    %% 计算供应方的总成本（库存+运输+提前/延迟惩罚）
    Time_of_arrive=zeros(1,n); %储存各场点的备件送达时间
    Cun_cost=0;
    Yun_cost=0;
    Miss_cost=0;
    cangku=store;
    for j=1:n
        kind=Job(j);
        if bj_decode_new(1,j)~=0
            gong=bj_decode_new(1,j);
            Time_of_arrive(j)=bj_decode_new(4,j)+t_fn(gong,j);
            yun_cost=t_cn(gong,j)*pr_yun; %计算备件来自工厂加工时的运输成本
        else
            cang=bj_decode_new(2,j);
            [~,pos_kind]=find(cangku{cang}(1,:)==kind);
            cangku{cang}(2,pos_kind)=cangku{cang}(2,pos_kind)-1;
            if t_cn(cang,j)<IT(1,j) %判断零时刻从仓库调拨时到达运维需求场点的时间是否早于规定的交货时间
                Time_of_arrive(j)=IT(1,j);
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
        miss_cost=pr_cun(1,kind)*max(0,IT(1,j)-Time_of_arrive(j))+Weight(1,j)*max(0,Time_of_arrive(j)-IT(1,j)); %计算某场点的提前或拖期成本
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
    miss_c_change=0;
    for j=1:n
        if bj_decode(2,j)~=0
            miss_c_before=0;
        else
            miss_c_before=pr_machine(j)*max(0,IT(j)-bj_decode(4,j)-t_fn(bj_decode(1,j),j))+pr_pause(j)*max(0,bj_decode(4,j)+t_fn(bj_decode(1,j),j)-IT(j));
        end
        if bj_decode_new(2,j)~=0
            miss_c_after=0;
        else
            miss_c_after=pr_machine(j)*max(0,IT(j)-bj_decode_new(4,j)-t_fn(bj_decode_new(1,j),j))+pr_pause(j)*max(0,bj_decode_new(4,j)+t_fn(bj_decode_new(1,j),j)-IT(j));
        end
        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
    end
    bj_decode(1:4,:)=bj_decode_new;
    objectives(1)=COST_supply;
    objectives(2)=objectives(2)+miss_c_change;
    Population_decode(i).decode=bj_decode;
    Population_decode(i).machine_start_time=start_time;
    Population_decode(i).machine_end_time=end_time;
    Population_decode(i).factory_bj=factory_bj;
    Population_decode(i).objectives=objectives;     
end