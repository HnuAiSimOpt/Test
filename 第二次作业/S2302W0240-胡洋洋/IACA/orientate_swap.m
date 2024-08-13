function [Population_swap,IT]=orientate_swap(Population_home,popsize,n,F,w,S,Job,t_fn,MHV,rate,repair,pretime,transfertime,pr_yun,pr_cun,pr_machine,pr_pause,maintain_EL,I_time,Weight)
% 针对每一维护人员上进行维护活动后提前最大的装备，将其与一不进行维护活动的装备交换
Population_swap=Population_home;
for i=1:popsize
    Population_chu=Population_home(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    worker_bj=Population_chu.worker_bj;
    worker_protime=Population_chu.worker_protime;
    IT=Population_chu.IT;
    IT_new=IT;
    objectives=Population_chu.objectives;
    objectives_change=objectives;
    chrom_es=chrom(1,n+1:2*n); %装备维护顺序序列
    chrom_ws=chrom(2,n+1:2*n); %维护活动选择序列
    [~,J_nows]=find(chrom_ws==0); %不进行维护活动的装备集合
    J=J_nows(chrom(2,J_nows)<=F); %在不进行维护活动的装备集中取出由工厂生产供应的工件集
    trans_change=0;
%     main_change=0;
    miss_s_change=0;
    miss_c_change=0;
    pause_change=0;
    for s=1:w*S
        if ~isempty(worker_bj{s})
            time_early=zeros(1,length(worker_bj{s})); %储存维护人员s上各装备的提前送达时间
            for j=1:length(worker_bj{s})
                equip=worker_bj{s}(j);
    %             if chrom(2,equip)<=F %如果此装备的备件由工厂生产供应
                time_early(j)=IT_new(equip)-bj_decode(4,equip)-t_fn(bj_decode(1,equip),equip); %计算装备维护后的提前送达时间长度
            end
            if ~isempty(find(time_early>0, 1))
                [~,pos1]=find(time_early==max(time_early),1);
                job=worker_bj{s}(pos1); %确定维护后提前送达时间最大的装备
                kind=Job(job);
                num_of_worker=bj_decode(5,job);
                num_of_method=bj_decode(6,job);
                J_same=J(Job(J)==kind); %找到集合J中与job类型相同的装备集合
                for j=1:length(J_same)
                    job2=J_same(j); %确定另一交换装备
                    if I_time(job2)<I_time(job)&&bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)>bj_decode(4,job)+t_fn(bj_decode(1,job),job)&&pr_machine(job2)<=pr_machine(job)&&pr_pause(job2)<=pr_pause(job)
                        J(J==job2)=job; %更新不进行维护活动且为工厂加工供应的装备集合
                        chrom_ws(job)=0;
                        chrom_ws(job2)=s;
                        [~,col]=find(chrom_es==job);
                        chrom_es(chrom_es==job2)=job;
                        chrom_es(col)=job2; %交换两装备的维护顺序
                        bj_decode(5:8,job)=0;
                        bj_decode(5,job2)=num_of_worker;
                        bj_decode(6,job2)=num_of_method;
                        [~,col]=find(worker_bj{s}==job);
                        worker_bj{s}(col)=job2;
                        miss_s_before1=max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))*pr_cun(kind);
                        miss_s_before2=max(0,I_time(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))*pr_cun(kind)+max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-I_time(job2))*Weight(job2);
                        miss_s_before=miss_s_before1+miss_s_before2;
                        miss_c_before1=max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))*pr_machine(job);
                        miss_c_before2=max(0,I_time(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))*pr_machine(job2)+max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-I_time(job2))*pr_pause(job2); 
                        miss_c_before=miss_c_before1+miss_c_before2;
                        if col~=length(worker_bj{s}) %如果选择的交换装备不是序列中的最后一个维护装备
                            job_next=worker_bj{s}(col+1); %找到此交换装备的后一个维护装备
                            trans_change=trans_change+pr_yun*(transfertime(job2,job_next)-transfertime(job,job_next));
                        end
                        if col==1
                            endtime=worker_protime{2,s}(1)+maintain_EL(1,job2)-worker_protime{1,s}(1);
                            starttime=maintain_EL(1,job2);
                            IT_new(job2)=endtime+MHV(job)*repair(num_of_method)/rate(job2);
                            pause_change=pause_change+pretime(num_of_worker,num_of_method)*(pr_pause(job2)-pr_pause(job));
                        else
                            job2_last=worker_bj{s}(col-1); %装备job2的前一个维护装备
                            wo_start=worker_protime{2,s}(col-1)+transfertime(job2_last,job2);
                            trans_change=trans_change+pr_yun*(transfertime(job2_last,job2)-transfertime(job2_last,job)); %两个装备维护活动交换前后工人转移成本变化
                            if wo_start<=maintain_EL(1,job2)
                                starttime=maintain_EL(1,job);
                            else
                                starttime=wo_start;
                            end
                            endtime=starttime+pretime(num_of_worker,num_of_method);
                            IT_new(job2)=endtime+MHV(job)*repair(num_of_method)/rate(job2);
                            pause_change=pause_change+pr_pause(job2)*(max(0,starttime-maintain_EL(2,job2))-max(0,worker_protime{1,s}(col)-maintain_EL(2,job)))+pretime(num_of_worker,num_of_method)*(pr_pause(job2)-pr_pause(job));
                        end
                        worker_protime{1,s}(col)=starttime;
                        worker_protime{2,s}(col)=endtime;
                        bj_decode(7,job2)=starttime;
                        bj_decode(8,job2)=endtime;
    %                     main_change=main_change+(C_pre(job2)-C_pre(job))*pretime(num_of_worker,num_of_method); %两个装备维护活动交换前后维护成本变化量
                        miss_s_after1=max(0,I_time(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))*pr_cun(kind)+max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-I_time(job))*Weight(job);
                        miss_s_after2=max(0,IT_new(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))*pr_cun(kind)+max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT_new(job2))*Weight(job2);
                        miss_s_after=miss_s_after1+miss_s_after2;
                        miss_c_after1=max(0,I_time(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))*pr_machine(job)+max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-I_time(job))*pr_pause(job);
                        miss_c_after2=max(0,IT_new(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))*pr_machine(job2)+max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT_new(job2))*pr_pause(job2);
                        miss_c_after=miss_c_after1+miss_c_after2;
                        miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                        for kk=col+1:length(worker_bj{s})
                            job=worker_bj{s}(kk);
                            kind=Job(job);
                            job_last=worker_bj{s}(kk-1); %本次考虑装备的前一个维护装备
                            wo_start=worker_protime{2,s}(kk-1)+transfertime(job_last,job);
                            if wo_start<=maintain_EL(1,job)
                                starttime=maintain_EL(1,job);
                            else
                                starttime=wo_start;
                            end
                            if starttime~=worker_protime{1,s}(kk)
                                endtime=starttime+pretime(num_of_worker,num_of_method);
                                IT_new(job)=endtime+MHV(job)*repair(num_of_method)/rate(job2);
                                miss_s_before=pr_cun(kind)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                                miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                                miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                                pause_change=pause_change+pr_pause(job)*(max(0,starttime-maintain_EL(2,job))-max(0,worker_protime{1,s}(kk)-maintain_EL(2,job)));
                                miss_c_before=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                                miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                                miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                                worker_protime{1,s}(kk)=starttime;
                                worker_protime{2,s}(kk)=endtime;
                                bj_decode(7,job2)=starttime;
                                bj_decode(8,job2)=endtime;
                            end
                        end
                        break;
                    end
                end
            end
        end
    end
    c_change=trans_change+miss_c_change+pause_change;
    objectives_change(1)=objectives_change(1)+miss_s_change;
    objectives_change(2)=objectives_change(2)+c_change;
    R=dominate(objectives_change,objectives);
    if R
        chrom(:,n+1:2*n)=[chrom_es;chrom_ws];
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.worker_bj=worker_bj;
        Population_chu.worker_protime=worker_protime;
        Population_chu.IT=IT_new;
        Population_chu.objectives=objectives_change;
%         Population_swap(i)=Population_chu;
        Population_swap=[Population_swap Population_chu];
        IT=IT_new;
    end
end
end