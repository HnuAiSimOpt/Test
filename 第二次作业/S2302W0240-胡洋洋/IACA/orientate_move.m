function [Population_move]=orientate_move(Population_home,popsize,n,w,S,t_fn,transfertime,Job,pretime,pr_cun,pr_yun,pr_machine,pr_pause,I_time,maintain_EL,Weight,MHV,repair,rate)
% 交换同一维护人员上的两个维护装备,选择两个以初始理想交货期为标准就延误的装备互换
Population_move=Population_home;
for i=1:popsize
    Population_chu=Population_move(i);
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
    trans_change=0;
    pause_change=0;
    miss_c_change=0;
    miss_s_change=0;
    for s=1:w*S
        if length(worker_bj{s})>1
            early_cost=zeros(1,length(worker_bj{s})); %记录维护人员s上各延误装备执行维护活动后的提前成本
            for j=1:length(worker_bj{s})
                job=worker_bj{s}(j);
                if bj_decode(4,job)+t_fn(bj_decode(1,job),job)>I_time(job)
                    early_cost(j)=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job));
                end
            end
            if ~isempty(early_cost>0)
                [~,pos1]=find(early_cost==max(early_cost),1); %找到维护后提前成本最大的装备在工人s维护集合中的位置
                job=worker_bj{s}(pos1); %维护后提前成本最大的装备
                kind=Job(job);
                num_of_worker=bj_decode(5,job);
                num_of_method=bj_decode(6,job);
%                 J=worker_bj{s}(worker_bj{s}~=job); %删除装备job后工人s的维护装备集合
    %             delay_cost=zeros(1,length(J)); %记录除装备job外工人s上其余装备执行维护活动后的延误成本
                for j=1:pos1-1
                    job2=worker_bj{s}(j);
                    if bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)>IT(job2)
                        kind2=Job(job2);
                        [~,pos2]=find(worker_bj{s}==job2);
                        worker_bj{s}(pos1)=job2; 
                        worker_bj{s}(pos2)=job;
                        [~,pos1_e]=find(chrom_es==job); %找到装备job在维护序列中的位置
                        chrom_es(chrom_es==job2)=job;
                        chrom_es(pos1_e)=job2;
                        if pos2==1  %如果其中一个交换装备的维护位置为工人s序列的第一个
                            starttime=maintain_EL(1,job);
                            endtime=starttime+pretime(num_of_worker,num_of_method);
                            IT_new(job)=endtime+MHV(job)*repair(num_of_method)/rate(job);
                        else
                            job_last=worker_bj{s}(pos2-1);
                            wo_start=worker_protime{2,s}(pos2-1)+transfertime(job_last,job);
                            if wo_start<=maintain_EL(1,job)
                                starttime=maintain_EL(1,job);
                            else
                                starttime=wo_start;
                            end
                            endtime=starttime+pretime(num_of_worker,num_of_method);
                            IT_new(job)=endtime+MHV(job)*repair(num_of_method)/rate(job);
                            trans_change=trans_change+pr_yun*(transfertime(job_last,job)-transfertime(job_last,job2));
                            pause_change=pause_change+pr_pause(job)*max(0,starttime-maintain_EL(2,job))-pr_pause(job2)*max(0,worker_protime{1,s}(pos2)-maintain_EL(2,job2));
                        end
                        worker_protime{1,s}(pos2)=starttime;
                        worker_protime{2,s}(pos2)=endtime;
                        miss_c_before=pr_machine(job2)*max(0,IT(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))+pr_pause(job2)*max(bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT(job2));
                        miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                        miss_s_before=pr_cun(kind2)*max(0,IT(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))+Weight(job2)*max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT(job2));
                        miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                        miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                        for kk=pos2+1:length(worker_bj{s})
                            job_now=worker_bj{s}(kk);
                            job_now_last=worker_bj{s}(kk-1);
                            kind_now=Job(job_now);
                            wo_start=worker_protime{2,s}(kk-1)+transfertime(job_now_last,job_now);
                            if wo_start<=maintain_EL(1,job_now)
                                starttime=maintain_EL(1,job_now);
                            else
                                starttime=wo_start;
                            end
                            endtime=starttime+pretime(num_of_worker,num_of_method);
                            if starttime~=worker_protime{1,s}(kk) 
                                IT_new(job_now)=endtime+MHV(job_now)*repair(num_of_method)/rate(job_now);
                            end
                            if kk==pos2+1
                                trans_change=trans_change+pr_yun*(transfertime(job,job_now)-transfertime(job2,job_now));
                            else
                                if kk==pos1
                                    trans_change=trans_change+pr_yun*(transfertime(job_now_last,job2)-transfertime(job_now_last,job));
                                else
                                    if kk==pos1+1
                                        trans_change=trans_change+pr_yun*(transfertime(job2,job_now)-transfertime(job,job_now));
                                    end
                                end
                            end
                            if kk==pos1 
                                pause_change=pause_change+pr_pause(job2)*max(0,starttime-maintain_EL(2,job2))-pr_pause(job)*max(0,worker_protime{1,s}(kk)-maintain_EL(2,job));
                                miss_s_before=pr_cun(kind)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                                miss_s_after=pr_cun(kind2)*max(0,IT_new(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))+Weight(job2)*max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT_new(job2));
                                miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                                miss_c_before=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                                miss_c_after=pr_machine(job2)*max(0,IT_new(job2)-bj_decode(4,job2)-t_fn(bj_decode(1,job2),job2))+pr_pause(job2)*max(0,bj_decode(4,job2)+t_fn(bj_decode(1,job2),job2)-IT_new(job2));
                                miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                            else
                                if starttime~=worker_protime{1,s}(kk)
                                    pause_change=pause_change+pr_pause(job_now)*(max(0,starttime-maintain_EL(2,job_now))-max(0,worker_protime{1,s}(kk)-maintain_EL(2,job_now)));
                                    miss_s_before=pr_cun(kind_now)*max(0,IT(job_now)-bj_decode(4,job_now)-t_fn(bj_decode(1,job_now),job_now))+Weight(job_now)*max(0,bj_decode(4,job_now)+t_fn(bj_decode(1,job_now),job_now)-IT(job_now));
                                    miss_s_after=pr_cun(kind_now)*max(0,IT_new(job_now)-bj_decode(4,job_now)-t_fn(bj_decode(1,job_now),job_now))+Weight(job_now)*max(0,bj_decode(4,job_now)+t_fn(bj_decode(1,job_now),job_now)-IT_new(job_now));
                                    miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                                    miss_c_before=pr_machine(job_now)*max(0,IT(job_now)-bj_decode(4,job_now)-t_fn(bj_decode(1,job_now),job_now))+pr_pause(job_now)*max(0,bj_decode(4,job_now)+t_fn(bj_decode(1,job_now),job_now)-IT(job_now));
                                    miss_c_after=pr_machine(job_now)*max(0,IT_new(job_now)-bj_decode(4,job_now)-t_fn(bj_decode(1,job_now),job_now))+pr_pause(job_now)*max(0,bj_decode(4,job_now)+t_fn(bj_decode(1,job_now),job_now)-IT_new(job_now));
                                    miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                                end
                            end
                            worker_protime{1,s}(kk)=starttime;
                            worker_protime{2,s}(kk)=endtime;
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
    R=dominate(objectives,objectives_change);
    if ~R&&~isequal(objectives,objectives_change)
        chrom(:,n+1:2*n)=[chrom_es;chrom_ws];
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.worker_bj=worker_bj;
        Population_chu.worker_protime=worker_protime;
        Population_chu.IT=IT_new;
        Population_chu.objectives=objectives_change;
        Population_move=[Population_move Population_chu];
    end
end
end