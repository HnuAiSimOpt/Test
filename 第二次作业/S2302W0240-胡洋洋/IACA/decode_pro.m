function [Population_decode]=decode_pro(popsize,F,C,n,M,Style,T,store,Job,pr_cun,pr_yun,pr_pause,pr_machine,protime,t_fn,t_cn,Weight,Population_home)
Population_decode=Population_home; 
for i=1:popsize
    IT=Population_decode(i).IT;
    Ch=Population_decode(i).Chromesome;
    bj_decode=Population_decode(i).decode;
    objectives=Population_decode(i).objectives;
    J_pro=Ch(1,1:n); %��������
    supply=Ch(2,1:n); %��Ӧ��ʽѡ��
    bj_decode_new=zeros(4,n); %���������ֽ�������ĸ������¼��㹩Ӧ���ֹ�����Ϣ
    start_time=cell(1,F*M); %��¼��̨�����ϵļӹ���ʼʱ��ͼӹ�����ʱ��
    end_time=cell(1,F*M);
    factory_bj=cell(1,F); %��¼�������ļӹ�������
    %% �������������и�������ʱ����Լ�Ŀ��ֵ
    for j=1:n %�������б����ӹ���������������ʱ���ų�
        job=J_pro(j); %��ǰ������
        kind=Job(job); %��ǰ����������
        if supply(1,job)<=F
            fa=supply(1,job); %ȷ���ñ���ѡ��ļӹ�����
            bj_decode_new(1,job)=fa; %����ñ����ļӹ�����
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
            bj_decode_new(2,job)=supply(job)-F; %����ñ����ĵ����ֿ���
        end
        bj_decode_new(3,job)=starttime;
        bj_decode_new(4,job)=endtime;
    end
    %% ���㹩Ӧ�����ܳɱ������+����+��ǰ/�ӳٳͷ���
    Time_of_arrive=zeros(1,n); %���������ı����ʹ�ʱ��
    Cun_cost=0;
    Yun_cost=0;
    Miss_cost=0;
    cangku=store;
    for j=1:n
        kind=Job(j);
        if bj_decode_new(1,j)~=0
            gong=bj_decode_new(1,j);
            Time_of_arrive(j)=bj_decode_new(4,j)+t_fn(gong,j);
            yun_cost=t_cn(gong,j)*pr_yun; %���㱸�����Թ����ӹ�ʱ������ɱ�
        else
            cang=bj_decode_new(2,j);
            [~,pos_kind]=find(cangku{cang}(1,:)==kind);
            cangku{cang}(2,pos_kind)=cangku{cang}(2,pos_kind)-1;
            if t_cn(cang,j)<IT(1,j) %�ж���ʱ�̴Ӳֿ����ʱ������ά���󳡵��ʱ���Ƿ����ڹ涨�Ľ���ʱ��
                Time_of_arrive(j)=IT(1,j);
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
        miss_cost=pr_cun(1,kind)*max(0,IT(1,j)-Time_of_arrive(j))+Weight(1,j)*max(0,Time_of_arrive(j)-IT(1,j)); %����ĳ�������ǰ�����ڳɱ�
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