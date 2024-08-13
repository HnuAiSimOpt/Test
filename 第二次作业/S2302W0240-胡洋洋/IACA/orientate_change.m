function [Population_change]=orientate_change(Population_home,popsize,n,w,t_fn,S,Job,pr_yun,pr_cun,C_pre,pr_machine,pr_pause,pretime,transfertime,maintain_EL,MHV,repair,rate,Weight)
% ��ĳά����Ա�ϵ���ǰװ���������һά����Աִ��
Population_change=Population_home;
for i=1:popsize
    Population_chu=Population_change(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    worker_bj=Population_chu.worker_bj;
    worker_protime=Population_chu.worker_protime;
    IT=Population_chu.IT;
    IT_new=IT;
    objectives=Population_chu.objectives;
    objectives_change=objectives;
    for s=1:w*S
        [~,pos]=find(isempty(worker_bj)); %�ҵ�ά������Ϊ�յĹ��˼���
        if ~isempty(pos)
            if length(worker_bj{s})>1
                job=worker_bj{s}(length(worker_bj{s})); %��ά����Աװ��ά�����е����һ��װ��
                kind=Job(job);
                f=bj_decode(1,job); %��װ���ļӹ�����
                if bj_decode(4,job)+t_fn(f,job)<IT(job)
                    job_last=worker_bj{s}(length(worker_bj{s})-1); %��ά����Աά�������еĵ����ڶ���װ��
                    trans_cost=pr_yun*transfertime(job_last,job); %װ��job�Ĺ���ת�Ƴɱ�
                    num_of_worker=bj_decode(5,job);
                    num_of_method=bj_decode(6,job);
                    main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %ά���ɱ�
                    pause_cost=pr_pause(job)*max(0,bj_decode(8,job)-maintain_EL(2,job)); %�м�ȴ�ά����ͣ���ɱ�
                    miss_cost=pr_machine(job)*(IT(job)-bj_decode(4,job)-t_fn(f,job));
                    cost_before=trans_cost+main_cost+pause_cost+miss_cost;
                    wo=pos(unidrnd(length(pos))); %���ȷ��һ������
                    if mod(wo,w)==0
                        num_of_worker=w; %ѡ���ά�������µ�ά����Ա���
                        num_of_method=worker/w; %ȷ��ѡ���ά������
                    else
                        num_of_worker=mod(worker,w); 
                        num_of_method=(worker-num_of_worker)/w+1;
                    end
                    starttime=maintain_EL(1,job);
                    endtime=starttime+pretime(num_of_worker,num_of_method);
                    IT_new(job)=endtime+MHV(job)*repair(method)/rate(job);
                    main_cost_after=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method);
                    miss_cost_after=pre_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(f,job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(f,job)-IT_new(job));
                    cost_after=main_cost_after+miss_cost_after;
                    if cost_after<cost_before
                        worker_bj{s}(length(worker_bj{s}))=[];
                        worker_protime{1,s}(length(worker_protime{1,s}))=[];
                        worker_protime{2,s}(length(worker_protime{2,s}))=[];
                        chrom(2,n+job)=wo;
                        worker_bj{wo}(1)=job;
                        worker_bj{1,wo}(1)=starttime;
                        worker_bj{2,wo}(2)=endtime;
                        bj_decode(5,job)=num_of_worker;
                        bj_decode(6,job)=num_of_method;
                        bj_decode(7,job)=starttime;
                        bj_decode(8,job)=endtime;
                        miss_s_before=pr_cun(kind)*(IT(job)-bj_decode(4,job)-t_fn(f,job));
                        miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(f,job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(f,job)-IT_new(job));
                        objectives_change(1)=objectives_change(1)+miss_s_after-miss_s_before;
                        objectives_change(2)=objectives_change(2)+cost_after-cost_before;
                    end
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
        Population_change=[Population_change Population_chu];
    end
end
end