function [Population_change]=orientate_outchange(Population_home,popsize,n,w,S,Job,pretime,transfertime,t_fn,pr_cun,pr_yun,pr_machine,pr_pause,MHV,repair,rate,maintain_EL,Weight)
% ����˵���������������ά�������ϵ���һά��װ����Ŀ���Ǳ�����Ⱥ�Ķ�����
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
        wo_min=worker(wo_num(2)); %ȷ����������ά��װ����ά������
        pos_max=randperm(length(worker_bj{wo_max}),1); 
        swap_bj1=worker_bj{wo_max}(pos_max);  %����ҵ�����һ�����˵Ľ���װ��
        pos_min=randperm(length(worker_bj{wo_min}),1);
        swap_bj2=worker_bj{wo_min}(pos_min); %���ȷ����һ���˵Ľ���װ��
        worker_bj{wo_max}(pos_max)=swap_bj2;
        worker_bj{wo_min}(pos_min)=swap_bj1; %��������ѡ�����˵�ѡ��װ��
        [~,index1]=find(chrom(1,n+1:2*n)==swap_bj1);
        [~,index2]=find(chrom(1,n+1:2*n)==swap_bj2); 
        chrom(1,n+index1)=swap_bj2;
        chrom(1,n+index2)=swap_bj1; %��ά�������н�������װ��
        kind1=Job(swap_bj1);
        kind2=Job(swap_bj2); %ȷ������װ���ı������ͱ���֮�������ǰ���ӳٳͷ��ļ���
        chrom(2,n+swap_bj1)=wo_min;
        chrom(2,n+swap_bj2)=wo_max; %��������װ����ά������ѡ��
        worker1=bj_decode(5,swap_bj1);
        method1=bj_decode(6,swap_bj1); 
        worker2=bj_decode(5,swap_bj2);
        method2=bj_decode(6,swap_bj2); 
        bj_decode(5,swap_bj1)=worker2;
        bj_decode(6,swap_bj1)=method2;
        bj_decode(5,swap_bj2)=worker1;
        bj_decode(6,swap_bj2)=method1; %���½�����Ϣ����װ����ά�����˺Ͳ���ѡ��

        %% ��������ά�����˵�ά��װ���������¼����Ŀ��ֵ
        miss_s_change=0;
        miss_c_change=0;
        pause_change=0;
        if pos_max==1
            trans_change=0;
            st=maintain_EL(1,swap_bj2);
        else
            job_last=worker_bj{wo_max}(pos_max-1); %�˽���װ��ǰһ��װ��
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
            job_last=worker_bj{wo_min}(pos_min-1); %�˽���װ��ǰһ��װ��
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

        objectives_change(2)=objectives_change(2)+miss_c_change+trans_change+pause_change; %���뱸������ܳɱ�
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