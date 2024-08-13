function [Population_or]=orientate0(Population_home,popsize,n,F,w,S,Job,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,pretime,t_fn,transfertime,maintain_EL,I_time,MHV,repair,rate)
% ȡ�������ɲֿ����������ά������ȼ�С�˹�Ӧ���Ŀ��ɱ����ֽ��������󷽵�ά���ɱ���ͣ����ʧ
Population_or=Population_home;
for i=1:popsize
%     Population_chu=Population_or0(i);
    chrom=Population_or(i).Chromesome;
    chrom_ws=chrom(2,n+1:2*n); %��װ����ά����Աѡ��
    worker_bj=Population_or(i).worker_bj;
    bj_decode=Population_or(i).decode;
    worker_protime=Population_or(i).worker_protime;
    IT=Population_or(i).IT;
    objectives=Population_or(i).objectives;
    objectives_change=objectives;
    [~,J_st]=find(chrom(2,1:n)>F); %�ҵ�ѡ��ֿ�����Ĺ�����װ��������
    [~,pos_st_ws]=find(chrom_ws(J_st)~=0);
    J_st_ws=J_st(pos_st_ws); %ȷ���ֿ������Ȼ����ά�����װ������
    if ~isempty(J_st_ws)
        chrom_ws(J_st_ws)=0; %ȡ�������ɲֿ����װ����ά���
% %         [~,J_nows]=find(chrom_ws==0); %�ҵ�ִ���������δ����ά�����װ������
% %         [~,J_ws]=find(chrom_ws~=0); %�ҵ�����ά���������װ��
        bj_decode(5:8,J_st_ws)=0;
        IT_new=IT; %�����װ�����д˾ֲ��������µ����뽻����
        IT_new(J_st_ws)=I_time(J_st_ws); %�ָ�����װ����ʼ�����뽻����
        Maintain_cost=0;
        Transfer_cost=0;
        Pause_cost=0;
        for s=1:w*S %����ɾ����ԭѡ���ά����Աά��������װ��
            [~,~,pos]=intersect(J_st_ws,worker_bj{s}); %�ҵ�����װ���ڸ�ά����Ա�е�ά��λ��
            if ~isempty(pos)
                worker_bj{s}(pos)=[];
                worker_protime{1,s}(pos)=[];
                worker_protime{2,s}(pos)=[];
                for j=1:length(worker_bj{s})
                    equip=worker_bj{s}(j);
                    num_of_worker=bj_decode(5,equip);
                    num_of_method=bj_decode(6,equip);
                    main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %�����װ����ά������
                    Maintain_cost=Maintain_cost+main_cost;
                    if j==1
                        worker_protime{1,s}(1)=maintain_EL(1,equip);
                        worker_protime{2,s}(1)=worker_protime{1,s}(1)+pretime(num_of_worker,num_of_method);
                        pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                    else
                        equip_last=worker_bj{s}(j-1); %�ҵ�ά����Ա�ϴ�װ������һ��ά��װ��
                        wo_start=worker_protime{2,s}(j-1)+transfertime(equip_last,equip); %����ά����Աs�б���ά��������翪ʼʱ��
                        trans_cost=pr_yun*transfertime(equip_last,equip); %����ÿ��װ������ά��ǰ��ת�Ƴɱ�
                        Transfer_cost=Transfer_cost+trans_cost; %���㹤��ȫ��ת�ƴ������ܳɱ�
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
                    Pause_cost=Pause_cost+pause_cost; %������ά��װ������ǰ��ͣ����ʧ
                    bj_decode(7,equip)=worker_protime{1,s}(j);
                    bj_decode(8,equip)=worker_protime{2,s}(j);
                    IT_new(1,equip)=worker_protime{2,s}(j)+MHV(equip)*repair(num_of_method)/rate(equip);
                end
            else
                for j=1:length(worker_bj{s})
                    equip=worker_bj{s}(j);
                    num_of_worker=bj_decode(5,equip);
                    num_of_method=bj_decode(6,equip);
                    main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %�����װ����ά������
                    Maintain_cost=Maintain_cost+main_cost;
                    if j==1
                        pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                    else
                        equip_last=worker_bj{s}(j-1); %�ҵ�ά����Ա�ϴ�װ������һ��ά��װ��
                        wo_start=worker_protime{2,s}(j-1)+transfertime(equip_last,equip); %����ά����Աs�б���ά��������翪ʼʱ��
                        trans_cost=pr_yun*transfertime(equip_last,equip); %����ÿ��װ������ά��ǰ��ת�Ƴɱ�
                        Transfer_cost=Transfer_cost+trans_cost; %���㹤��ȫ��ת�ƴ������ܳɱ�
                        if wo_start<=maintain_EL(1,equip)
                            pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
                        else
                            pause_cost=pr_pause(1,equip)*(max(0,worker_protime{1,s}(j)-maintain_EL(2,equip))+pretime(num_of_worker,num_of_method));
                        end
                    end
                    Pause_cost=Pause_cost+pause_cost; %������ά��װ������ǰ��ͣ����ʧ
                end
            end
        end
        cun_cost_change=0;
        for j=1:length(J_st_ws) %����ȡ����ά����Ĺ����Ŀ��ɱ��仯��
            job=J_st_ws(j);
            kind=Job(job);
            cun_cost_change=cun_cost_change+(IT_new(job)-IT(job))*pr_cun(1,kind);
        end
        
        miss_cost=0;
        for j=1:n %���㰲��ά�����װ����ͣ���ͻ����˷ѳɱ����������ӳ�\��ǰ�ͷ��仯��
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