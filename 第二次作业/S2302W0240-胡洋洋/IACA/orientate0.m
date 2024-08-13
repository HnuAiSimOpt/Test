function [Population_or]=orientate0(Population_home,popsize,n,F,w,S,Job,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,pretime,t_fn,transfertime,maintain_EL,I_time,MHV,repair,rate)
% 取消所有由仓库调拨工件的维护活动，既减小了供应方的库存成本，又降低了需求方的维护成本和停工损失
Population_or=Population_home;
for i=1:popsize
%     Population_chu=Population_or0(i);
    chrom=Population_or(i).Chromesome;
    chrom_ws=chrom(2,n+1:2*n); %各装备的维护人员选择
    worker_bj=Population_or(i).worker_bj;
    bj_decode=Population_or(i).decode;
    worker_protime=Population_or(i).worker_protime;
    IT=Population_or(i).IT;
    objectives=Population_or(i).objectives;
    objectives_change=objectives;
    [~,J_st]=find(chrom(2,1:n)>F); %找到选择仓库调拨的工件（装备）集合
    [~,pos_st_ws]=find(chrom_ws(J_st)~=0);
    J_st_ws=J_st(pos_st_ws); %确定仓库调拨仍然安排维护活动的装备集合
    if ~isempty(J_st_ws)
        chrom_ws(J_st_ws)=0; %取消上述由仓库调拨装备的维护活动
% %         [~,J_nows]=find(chrom_ws==0); %找到执行完操作后未安排维护活动的装备集合
% %         [~,J_ws]=find(chrom_ws~=0); %找到安排维护活动的所有装备
        bj_decode(5:8,J_st_ws)=0;
        IT_new=IT; %储存各装备进行此局部搜索后新的理想交货期
        IT_new(J_st_ws)=I_time(J_st_ws); %恢复上述装备初始的理想交货期
        Maintain_cost=0;
        Transfer_cost=0;
        Pause_cost=0;
        for s=1:w*S %依次删除在原选择的维护人员维护的上述装备
            [~,~,pos]=intersect(J_st_ws,worker_bj{s}); %找到上述装备在各维护人员中的维护位置
            if ~isempty(pos)
                worker_bj{s}(pos)=[];
                worker_protime{1,s}(pos)=[];
                worker_protime{2,s}(pos)=[];
                for j=1:length(worker_bj{s})
                    equip=worker_bj{s}(j);
                    num_of_worker=bj_decode(5,equip);
                    num_of_method=bj_decode(6,equip);
                    main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算该装备的维护费用
                    Maintain_cost=Maintain_cost+main_cost;
                    if j==1
                        worker_protime{1,s}(1)=maintain_EL(1,equip);
                        worker_protime{2,s}(1)=worker_protime{1,s}(1)+pretime(num_of_worker,num_of_method);
                        pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                    else
                        equip_last=worker_bj{s}(j-1); %找到维护人员上此装备的上一个维护装备
                        wo_start=worker_protime{2,s}(j-1)+transfertime(equip_last,equip); %计算维护人员s中本次维护活动的最早开始时间
                        trans_cost=pr_yun*transfertime(equip_last,equip); %计算每个装备进行维护前的转移成本
                        Transfer_cost=Transfer_cost+trans_cost; %计算工人全部转移次数的总成本
                        if wo_start<=maintain_EL(1,equip)
                            worker_protime{1,s}(j)=maintain_EL(1,equip);
                            worker_protime{2,s}(j)=worker_protime{1,s}(j)+pretime(num_of_worker,num_of_method);
                            pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                        else
                            worker_protime{1,s}(j)=wo_start;
                            worker_protime{2,s}(j)=worker_protime{1,s}(j)+pretime(num_of_worker,num_of_method);
                            pause_cost=pr_pause(1,equip)*(max(0,worker_protime{1,s}(j)-maintain_EL(2,equip))+pretime(num_of_worker,num_of_method));
                        end
                    end
                    Pause_cost=Pause_cost+pause_cost; %各进行维护装备交货前的停工损失
                    bj_decode(7,equip)=worker_protime{1,s}(j);
                    bj_decode(8,equip)=worker_protime{2,s}(j);
                    IT_new(1,equip)=worker_protime{2,s}(j)+MHV(equip)*repair(num_of_method)/rate(equip);
                end
            else
                for j=1:length(worker_bj{s})
                    equip=worker_bj{s}(j);
                    num_of_worker=bj_decode(5,equip);
                    num_of_method=bj_decode(6,equip);
                    main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %计算该装备的维护费用
                    Maintain_cost=Maintain_cost+main_cost;
                    if j==1
                        pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                    else
                        equip_last=worker_bj{s}(j-1); %找到维护人员上此装备的上一个维护装备
                        wo_start=worker_protime{2,s}(j-1)+transfertime(equip_last,equip); %计算维护人员s中本次维护活动的最早开始时间
                        trans_cost=pr_yun*transfertime(equip_last,equip); %计算每个装备进行维护前的转移成本
                        Transfer_cost=Transfer_cost+trans_cost; %计算工人全部转移次数的总成本
                        if wo_start<=maintain_EL(1,equip)
                            pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                        else
                            pause_cost=pr_pause(1,equip)*(max(0,worker_protime{1,s}(j)-maintain_EL(2,equip))+pretime(num_of_worker,num_of_method));
                        end
                    end
                    Pause_cost=Pause_cost+pause_cost; %各进行维护装备交货前的停工损失
                end
            end
        end
        cun_cost_change=0;
        for j=1:length(J_st_ws) %计算取消了维护活动的工件的库存成本变化量
            job=J_st_ws(j);
            kind=Job(job);
            cun_cost_change=cun_cost_change+(IT_new(job)-IT(job))*pr_cun(1,kind);
        end
        
        miss_cost=0;
        for j=1:n %计算安排维护活动的装备的停工和机器浪费成本、工件的延迟\提前惩罚变化量
            if bj_decode(1,j)~=0
                if bj_decode(4,j)+t_fn(bj_decode(1,j),j)<=IT_new(j)
                    miss_cost=miss_cost+pr_machine(j)*(IT_new(j)-bj_decode(4,j)-t_fn(bj_decode(1,j),j));
                else
                    miss_cost=miss_cost+pr_pause(j)*(bj_decode(4,j)+t_fn(bj_decode(1,j),j)-IT_new(j));
                end
            end
        end
        chrom(2,n+1:2*n)=chrom_ws;
        objectives_change(1)=objectives_change(1)+cun_cost_change;
        objectives_change(2)=miss_cost+Pause_cost+Transfer_cost+Maintain_cost;
        R=dominate(objectives,objectives_change);
        if ~R
            Population_or(i).Chromesome=chrom;
            Population_or(i).decode=bj_decode;
            Population_or(i).worker_bj=worker_bj;
            Population_or(i).worker_protime=worker_protime;
            Population_or(i).IT=IT_new;
            Population_or(i).objectives=objectives_change;
%             Population_or=[Population_or Population_or];
        end
    end
end