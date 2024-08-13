function [Population_or2]=orientate2(Population_home,popsize,n,F,w,S,Job,pretime,t_fn,transfertime,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,I_time,maintain_EL,Weight,MHV,repair,rate)
% ����˵����ȡ��������ǰ����׼ʱװ����ά���
Population_or2=Population_home;
for i=1:popsize
%     Population_chu=Population_home(i);
    chrom=Population_or2(i).Chromesome;
    bj_decode=Population_or2(i).decode;
    worker_bj=Population_or2(i).worker_bj;
    worker_protime=Population_or2(i).worker_protime;
    IT=Population_or2(i).IT;
    IT_new=IT;
    objectives=Population_or2(i).objectives;
    objectives_change=objectives;
    chrom_ws=chrom(2,n+1:2*n);
    [~,pos1_w]=find(chrom_ws>0); %�ҵ�ִ��ȡ��ά������ǰ��ά�����װ������
    change_J=zeros(1,length(pos1_w));
    for j=1:length(pos1_w) %������ά�������������װ����ά���ȡ��
        job=pos1_w(j);
        if chrom(2,job)>F
            chrom_ws(job)=0;
            change_J(j)=job;
        else
            if bj_decode(4,job)+t_fn(bj_decode(1,job),job)<=I_time(job)
                chrom_ws(job)=0;
                change_J(j)=job;
            end
        end
    end
    change_J(change_J==0)=[]; %��Ҫȡ��ά�����װ������
    if ~isequal(chrom(2,n+1:2*n),chrom_ws)
        chrom_old=chrom(2,n+1:2*n);
    %     [~,pos2_w]=find(chrom_ws>0); %�ҵ�ִ��ȡ�������ά�����װ������
    %     J_del=setdiff(pos1_w,pos2_w); %�ҵ��˲�����ȡ��ά����Ĺ�������
        cun_change=0;
        miss_s_change=0;
        trans_change=0;
        main_change=0;
        pause_change=0;
        miss_c_change=0;
        for s=1:w*S
            if ~isempty(find(chrom_old(change_J)==s, 1))
                J=worker_bj{s};
                if ~isempty(J)
                    job=J(1);
                    kind=Job(job);
                    num_of_worker=bj_decode(5,job);
                    num_of_method=bj_decode(6,job);
                    if chrom_ws(1,job)==0 %�ж�ά����Աά�������ϵĵ�һ��װ���Ƿ�ȡ��ά���
                        IT_new(job)=I_time(job);
                        bj_decode(5:8,job)=0;
                        worker_bj{s}(1)=0;
                        worker_protime{1,s}(1)=0;
                        worker_protime{2,s}(1)=0;
                        main_change=main_change-C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method);
                        pause_change=pause_change-pr_pause(job)*pretime(num_of_worker,num_of_method);
                        if chrom(1,job)>F
                            cun_change=cun_change+pr_cun(kind)*(I_time(job)-IT(job));
                        else
                            miss_s_change=miss_s_change+pr_cun(kind)*(IT_new(job)-IT(job));
                            miss_c_change=miss_c_change+pr_machine(job)*(IT_new(job)-IT(job));
                        end
                    end
                    for j=2:length(J) %��ά����Աs�ϵڶ���ά��װ������֮���װ������ά����ȡ��������½���
                        job=J(j);
                        kind=Job(job);
                        job_last=J(j-1); %�ҵ���װ����ǰһ��ά��װ��
                        if chrom_ws(1,job)==0
                            bj_decode(5:8,job)=0;
                            worker_bj{s}(j)=0;
                            IT_new(job)=I_time(job); %�ָ���װ�������뽻����Ϊ��ʼ���뽻����
                            trans_change=trans_change-pr_yun*transfertime(job_last,job);
                            main_change=main_change-C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method);
                            pause_change=pause_change-pr_pause(job)*(max(0,worker_protime{1,s}(j)-maintain_EL(2,job))+pretime(num_of_worker,num_of_method));
                            if chrom(2,job)>F
                                cun_change=cun_change+pr_cun(kind)*(I_time(job)-IT(job));
                            else
                                miss_s_change=miss_s_change+pr_cun(kind)*(IT_new(job)-IT(job));
                                miss_c_change=miss_c_change+pr_machine(job)*(IT_new(job)-IT(job));
                            end   
                            worker_protime{1,s}(j)=0;
                            worker_protime{2,s}(j)=0;
                        else
                            [~,pos_s]=find(worker_bj{s}(1,1:j-1)~=0);
                            if ~isempty(pos_s)              
                                job_new_last=worker_bj{s}(pos_s(length(pos_s))); %�ҵ���װ��ǰ���һ��û��ȡ��ά�����װ��
                                if job_new_last~=job_last
                                    trans_change=trans_change+pr_yun*(transfertime(job_new_last,job)-transfertime(job_last,job));
                                end
                                wo_start=worker_protime{2,s}(pos_s(length(pos_s)))+transfertime(job_new_last,job); %ά����Աs�����һ��ά��װ����Ŀ���ʱ���
                                if wo_start<=maintain_EL(1,job)
                                    starttime=maintain_EL(1,job);
                                else
                                    starttime=wo_start;
                                end
                                endtime=starttime+pretime(num_of_worker,num_of_method);
                                IT_new(job)=endtime+MHV(job)*repair(num_of_method)/rate(job);
                                pause_change=pause_change+pr_pause(job)*(max(0,starttime-maintain_EL(2,job))-max(0,worker_protime{1,s}(j)-maintain_EL(2,job)));
                            else
                                trans_change=trans_change-pr_yun*transfertime(job_last,job);
                                starttime=maintain_EL(1,job);
                                endtime=starttime+pretime(num_of_worker,num_of_method);
                                IT_new(job)=endtime+MHV(job)*repair(num_of_method)/rate(job);
                                pause_change=pause_change-pr_pause(job)*max(0,worker_protime{1,s}(j)-maintain_EL(2,job));
                            end
                            bj_decode(7,job)=starttime;
                            bj_decode(8,job)=endtime;
                            worker_protime{1,s}(j)=starttime;
                            worker_protime{2,s}(j)=endtime;
                            miss_s_before=pr_cun(kind)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                            miss_s_after=pr_cun(kind)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+Weight(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                            miss_s_change=miss_s_change+miss_s_after-miss_s_before;
                            miss_c_before=pr_machine(job)*max(0,IT(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT(job));
                            miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(bj_decode(1,job),job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(bj_decode(1,job),job)-IT_new(job));
                            miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                        end
                    end
                    worker_bj{s}(worker_bj{s}==0)=[];
                    worker_protime{1,s}(worker_protime{1,s}==0)=[];
                    worker_protime{2,s}(worker_protime{2,s}==0)=[];
                end
            end
        end
        chrom(2,n+1:2*n)=chrom_ws;
        objectives_change(1)=objectives_change(1)+cun_change+miss_s_change;
        objectives_change(2)=objectives_change(2)+trans_change+pause_change+main_change+miss_c_change;
        R=dominate(objectives_change,objectives);
        if R
            Population_or2(i).Chromesome=chrom;
            Population_or2(i).decode=bj_decode;
            Population_or2(i).worker_bj=worker_bj;
            Population_or2(i).worker_protime=worker_protime;
            Population_or2(i).IT=IT_new;
            Population_or2(i).objectives=objectives_change;
    %         Population_or2=[Population_home Population_chu];
        end
    end
end
end