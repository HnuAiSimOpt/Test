function [Population_decode]=decode(popsize,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,IT,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    Ch=Population_decode(i).Chromesome;
    J_pro=Ch(1,1:n); %��������
    supply=Ch(2,1:n); %��Ӧ��ʽѡ��
    J_maintain=Ch(1,n+1:2*n); %װ��ά������
    workerselect=Ch(2,n+1:2*n); %װ��ά����Աѡ��
    bj_decode=zeros(8,n); %����Ϊ����������б������乤�����ֿ⡢�ӹ���ʼʱ�䡢�ӹ�����ʱ�䡢ά����Աѡ��ά������ѡ��װ��ά����ʼʱ�䡢װ��ά������ʱ��
    start_time=cell(1,F*M); %��¼��̨�����ϵļӹ���ʼʱ��ͼӹ�����ʱ��
    end_time=cell(1,F*M);
    main_t=cell(2,w*S); %��¼����ά����Ա��ÿ��ά����Ŀ�ʼʱ��ͽ���ʱ��
    factory_bj=cell(1,F); %��¼�������ļӹ�������
    worker_bj=cell(1,w*S); %��¼��ά�����˵�ά��װ����
    %% �������������и�������ʱ����Լ�Ŀ��ֵ
    for j=1:n %�������б����ӹ���������������ʱ���ų�
        job=J_pro(j); %��ǰ������
        kind=Job(job); %��ǰ����������
        if supply(1,job)<=F
            fa=supply(1,job); %ȷ���ñ���ѡ��ļӹ�����
            bj_decode(1,job)=fa; %����ñ����ļӹ�����
            if isempty(factory_bj{fa}) %�жϸù����Ƿ����б����ӹ������û��
                for k=1:M
                    if k==1
                        start_time{(fa-1)*M+k}(1)=0; %�ù�����һ̨�����ϵ�һ�������ļӹ���ʼʱ��
                    else
                        start_time{(fa-1)*M+k}(1)=end_time{(fa-1)*M+k-1}(1);
                    end
                    end_time{(fa-1)*M+k}(1)=start_time{(fa-1)*M+k}(1)+protime(k,kind); %����ù�����ѡ����������ˮ�߸�̨�����Ŀ�ʼʱ��ͽ���ʱ��
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
            bj_decode(2,job)=supply(job)-F; %����ñ����ĵ����ֿ���
        end
        bj_decode(3,job)=starttime;
        bj_decode(4,job)=endtime;
    end
    %% �����װ��ά����ļƻ���Ŀ��ֵ
    IT_new=IT; %�������ά���������뽻����
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
        end
    end
    %% ���㹩Ӧ�����ܳɱ������+����+��ǰ/�ӳٳͷ���
    Time_of_arrive=zeros(1,n); %���������ı����ʹ�ʱ��
    Cun_cost=0;
    Yun_cost=0;
    Miss_cost=0;
    cangku=store;
    for j=1:n
        kind=Job(j);
        if bj_decode(1,j)~=0
            gong=bj_decode(1,j);
            Time_of_arrive(j)=bj_decode(4,j)+t_fn(gong,j);
            yun_cost=t_cn(gong,j)*pr_yun; %���㱸�����Թ����ӹ�ʱ������ɱ�
        else
            cang=bj_decode(2,j);
            [~,pos_kind]=find(cangku{cang}(1,:)==kind);
            cangku{cang}(2,pos_kind)=cangku{cang}(2,pos_kind)-1;
            if t_cn(cang,j)<IT_new(1,j) %�ж���ʱ�̴Ӳֿ����ʱ������ά���󳡵��ʱ���Ƿ����ڹ涨�Ľ���ʱ��
                Time_of_arrive(j)=IT_new(1,j);
                cun_time=Time_of_arrive(j)-t_cn(cang,j);
                cun_cost=pr_cun(1,kind)*cun_time; %�ñ����Ŀ��ɱ�
            else
                Time_of_arrive(j)=t_cn(cang,j);
                cun_cost=0;
            end
            yun_cost=t_cn(cang,j)*pr_yun; %���㱸�����Բֿ����ʱ������ɱ�
            Cun_cost=Cun_cost+cun_cost;
        end
        Yun_cost=Yun_cost+yun_cost; %�����ܳɱ�
        miss_cost=pr_cun(1,kind)*max(0,IT_new(1,j)-Time_of_arrive(j))+Weight(1,j)*max(0,Time_of_arrive(j)-IT_new(1,j)); %����ĳ�������ǰ�����ڳɱ�
        Miss_cost=Miss_cost+miss_cost; %������������ǰ�����ڳɱ���
    end
    for j=1:Style
        num=0;
        for k=1:C
            if ~isempty(cangku{k})
                [~,pos]=find(cangku{k}(1,:)==j);
                if ~isempty(pos)
                    num=num+cangku{k}(2,pos); %��������ͱ��������вֿ��е���ʣ������
                end
            end
        end
        Cun_cost=Cun_cost+pr_cun(1,j)*num*T; %������ϸ�����ʣ�౸���Ŀ��ɱ�����ܿ��ɱ�
    end
    COST_supply=Yun_cost+Cun_cost+Miss_cost; %��Ӧ���ܳɱ������䡢������ǰ/���ڳɱ�֮�ͣ� 
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