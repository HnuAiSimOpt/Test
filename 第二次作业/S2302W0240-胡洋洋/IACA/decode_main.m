function [Population_decode]=decode_main(popsize,n,w,S,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    Ch=Population_decode(i).Chromesome;
    bj_decode=Population_decode(i).decode;
    objectives=Population_decode(i).objectives;
    IT=Population_decode(i).IT;
    J_maintain=Ch(1,n+1:2*n); %װ��ά������
    workerselect=Ch(2,n+1:2*n); %װ��ά����Աѡ��
    main_t=cell(2,w*S); %��¼����ά����Ա��ÿ��ά����Ŀ�ʼʱ��ͽ���ʱ��
    worker_bj=cell(1,w*S); %��¼��ά�����˵�ά��װ����
    %% �����װ��ά����ļƻ���Ŀ��ֵ
    IT_new=I_time; %�������ά���������뽻����
    Maintain_cost=0; %��ά������
    Transfer_cost=0; %��ά����Աת�Ƴɱ�
    Pause_cost=0; %�ܵ�װ��ͣ����ʧ
    for j=1:n
        equip=J_maintain(1,j); 
        worker=workerselect(equip); %ȷ����ǰװ���Լ���ѡ���ά����Ա
        if worker~=0
            if mod(worker,w)==0
                num_of_worker=w; %ѡ���ά�������µ�ά����Ա���
                num_of_method=worker/w; %ȷ��ѡ���ά������
            else
                num_of_worker=mod(worker,w); 
                num_of_method=(worker-num_of_worker)/w+1;
            end
            bj_decode(5,equip)=num_of_worker;
            bj_decode(6,equip)=num_of_method;
            main_cost=C_pre(num_of_worker,num_of_method)*pretime(num_of_worker,num_of_method); %�����װ����ά������
            Maintain_cost=Maintain_cost+main_cost;
            if isempty(worker_bj{worker})
                main_t{1,worker}(1)=maintain_EL(1,equip);
                main_t{2,worker}(1)=main_t{1,worker}(1)+pretime(num_of_worker,num_of_method); %�����װ��ά����Ŀ�ʼ�ͽ���ʱ��
                pause_cost=pr_pause(1,equip)*pretime(num_of_worker,num_of_method);
            else
                equip_last=worker_bj{worker}(length(worker_bj{worker})); %�ҵ���ǰװ����ѡ���˴�ǰά�������һ��װ��
                wo_start=main_t{2,worker}(length(main_t{2,worker}))+transfertime(equip_last,equip); %����ѡ�����˱���ά��������翪ʼʱ��
                trans_cost=pr_yun*transfertime(equip_last,equip); %����ÿ��װ������ά��ǰ��ת�Ƴɱ�
                Transfer_cost=Transfer_cost+trans_cost; %���㹤��ȫ��ת�ƴ������ܳɱ�
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
            Pause_cost=Pause_cost+pause_cost; %������ά��װ������ǰ��ͣ����ʧ
            bj_decode(7,equip)=main_t{1,worker}(length(main_t{1,worker}));
            bj_decode(8,equip)=main_t{2,worker}(length(main_t{2,worker}));
            worker_bj{worker}=[worker_bj{worker} equip];
            IT_new(1,equip)=main_t{2,worker}(length(main_t{2,worker}))+MHV(equip)*repair(num_of_method)/rate(equip);
        else
            bj_decode(5:8,equip)=0;
        end
    end
    %% ���㹩Ӧ�����ܳɱ������+����+��ǰ/�ӳٳͷ���
    Time_of_arrive=zeros(1,n); %���������ı����ʹ�ʱ��
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
                if t_cn(cang,j)<IT_new(1,j) %�ж���ʱ�̴Ӳֿ����ʱ������ά���󳡵��ʱ���Ƿ����ڹ涨�Ľ���ʱ��
                    cun_change=cun_change+pr_cun(kind)*(IT_new(j)-IT(j));
                end
            end
        end
    end

    %% �����װ�����������Ӧ��װ���˷Ѻ�ͣ����ʧ
    Machine_cost=0; %�ܵ�װ�������˷�
    for j=1:n
        if Time_of_arrive(j)>IT_new(j)
            Pause_cost=Pause_cost+pr_pause(1,j)*(Time_of_arrive(j)-IT_new(j));
        else
            Machine_cost=Machine_cost+pr_machine(1,j)*(IT_new(j)-Time_of_arrive(j));
        end
    end
    COST_customer=Maintain_cost+Transfer_cost+Pause_cost+Machine_cost; %���󷽵��ܳɱ�
    objectives(1)=objectives(1)+cun_change+miss_s_change;
    objectives(2)=COST_customer;
    Population_decode(i).decode=bj_decode;
    Population_decode(i).worker_bj=worker_bj;
    Population_decode(i).worker_protime=main_t;
    Population_decode(i).objectives=objectives;
    Population_decode(i).IT=IT_new;
end