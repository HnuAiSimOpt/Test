function [Population_orfs]=LS1_P(Population_home,popsize,n,F,M,T,protime,t_fn,t_cn,pr_cun,pr_yun,pr_machine,pr_pause,Job,CA,store,Weight)
% ���ɹ����ӹ��Ĺ����Ͳֿ�����Ĺ����໥�����������ֿ⣬�Խ����ӳٳͷ��ɱ�
Population_orfs=Population_home;
for i=1:popsize
    Population_chu=Population_home(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    factory_bj=Population_chu.factory_bj;
    machine_start_time=Population_chu.machine_start_time;
    machine_end_time=Population_chu.machine_end_time;
    objectives=Population_chu.objectives;
    objectives_change=objectives; %���潻���������Ŀ��ֵ
    IT_new=Population_chu.IT;
    chrom_os=chrom(1,1:n); %��Ӧ���ֵĹ�������
    chrom_fcs=chrom(2,1:n); %��Ӧ���ֵĹ���\�ֿ�ѡ������
    [~,J_f]=find(chrom_fcs<=F); %�ڹ����мӹ��Ĺ�������
    delay_cost=zeros(1,length(J_f)); %�����ɹ����ӹ��Ĺ���������ͷ�
    for k=1:length(J_f)
        j=J_f(k);
        f=bj_decode(1,j); %ȷ��ѡ�������ļӹ�����
        delay_cost(k)=max(0,bj_decode(4,j)+t_fn(f,j)-IT_new(j))*Weight(j); 
    end
    if ~isempty(delay_cost>0)
        miss_c_change=0;
        flag=0;
        [~,pos]=max(delay_cost); %ȷ�������������Ĺ�������λ��
        J=J_f(pos); %������󹤼�
        fa=bj_decode(1,J); %������󹤼����ڵĹ���
        kind=Job(J); %������󹤼�������
        [~,pos_os]=find(chrom_os==J); %�ҵ�������󹤼�J�ڹ����ӹ������е�λ��
        [~,pos_fa]=find(factory_bj{fa}==J); %�ҵ�������󹤼�J�ڶ�Ӧ�����е�λ��
        [~,J_same]=find(Job==kind);
        J_same(J_same==J)=[]; %ȷ�����˹���J������ҲΪkind�Ĺ�������
        for s=1:length(CA{kind}) %�����жϸ��ֿ��Ƿ�������Ϊkind�Ĺ���ʣ��
            st=CA{kind}(s);
            [~,pos_st]=find(store{st}(1,:)==kind); %ȷ�������͹����ڸ��ֿ��еĴ���λ��
            if length(find(chrom_fcs(J_same)==st+F))<store{st}(2,pos_st)
                flag=flag+1; %���ڱ���Ƿ��Ѷ�������󹤼����й�����������ֱ�ӻ��ɲֿ����
                miss_c_change=miss_c_change-pr_machine(J)*max(0,IT_new(J)-bj_decode(4,J)-t_fn(fa,J))-pr_pause(J)*max(0,bj_decode(4,J)+t_fn(fa,J)-IT_new(J));
                chrom_fcs(J)=st+F;
                chrom(2,1:n)=chrom_fcs;
                bj_decode(1,J)=0;
                bj_decode(2,J)=st;
                bj_decode(3,J)=0;
                bj_decode(4,J)=0;
                J_cost_before=delay_cost(pos)+pr_yun*t_fn(fa,J)+pr_cun(1,kind)*T; %����J��Ӧ��ʽ����ǰ���ܳɱ�
                J_cost_after=pr_cun(1,kind)*(IT_new(J)-t_cn(st,J))+pr_yun*t_cn(st,J); %����J��Ӧ��ʽ����Ϊ�ֿ��������ܳɱ�
                J_cost_change=J_cost_after-J_cost_before; %������Ӧ��ʽ��ɱ��仯��
                factory_bj{fa}(pos_fa)=[]; %�ڹ���fa��ɾ������J
                for m=1:M
                    machine_start_time{(fa-1)*M+m}(pos_fa)=[];
                    machine_end_time{(fa-1)*M+m}(pos_fa)=[]; %������Jԭ���ڻ����ϵļӹ���ʼ������ʱ��ɾ��
                end
                if pos_fa~=length(factory_bj{fa})+1
                    for j=pos_fa:length(factory_bj{fa}) %��ԭ���ڹ���J��߼ӹ��Ĺ������½���
                        job=factory_bj{fa}(j);
                        kind_job=Job(job);
                        miss_c_before=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(fa,job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(fa,job)-IT_new(job));
                        if j==1
                            for m=1:M
                                if m==1
                                    machine_start_time{(fa-1)*M+m}(1)=0;
                                    machine_end_time{(fa-1)*M+m}(1)=protime(1,kind_job);
                                else
                                    machine_start_time{(fa-1)*M+m}(1)=machine_end_time{(fa-1)*M+m-1}(1);
                                    machine_end_time{(fa-1)*M+m}(1)=machine_start_time{(fa-1)*M+m}(1)+protime(1,kind_job);
                                end
                            end
                        else
                            for m=1:M
                                if m==1
                                    machine_start_time{(fa-1)*M+m}(j)=machine_end_time{(fa-1)*M+m}(j-1);
                                    machine_end_time{(fa-1)*M+m}(j)=machine_start_time{(fa-1)*M+m}(j)+protime(1,kind_job);
                                else
                                    machine_start_time{(fa-1)*M+m}(j)=max(machine_end_time{(fa-1)*M+m}(j-1),machine_end_time{(fa-1)*M+m-1}(j));
                                    machine_end_time{(fa-1)*M+m}(j)=machine_start_time{(fa-1)*M+m}(j)+protime(1,kind_job);
                                end
                            end
                        end
                        J_cost_before=max(0,IT_new(job)-bj_decode(4,job)-t_fn(fa,job))*pr_cun(1,kind_job)+max(0,bj_decode(4,job)+t_fn(fa,job)-IT_new(job))*Weight(job);
                        J_cost_after=max(0,IT_new(job)-machine_end_time{fa*M}(j)-t_fn(fa,job))*pr_cun(1,kind_job)+max(0,machine_end_time{fa*M}(j)+t_fn(fa,job)-IT_new(job))*Weight(job);
                        J_cost_change=J_cost_change+J_cost_after-J_cost_before;
                        bj_decode(3,job)=machine_start_time{(fa-1)*M+1}(j);
                        bj_decode(4,job)=machine_end_time{fa*M}(j);
                        miss_c_after=pr_machine(job)*max(0,IT_new(job)-bj_decode(4,job)-t_fn(fa,job))+pr_pause(job)*max(0,bj_decode(4,job)+t_fn(fa,job)-IT_new(job));
                        miss_c_change=miss_c_change+miss_c_after-miss_c_before;
                    end
                end
                objectives_change(1)=objectives_change(1)+J_cost_change;
                objectives_change(2)=objectives_change(2)+miss_c_change;
                break;
            end
        end
        if flag==0
           J_same_st=J_same(chrom_fcs(J_same)>F); %�빤��Jͬ���͵Ĺ��������ڲֿ������ʽ�Ĺ�����
           for j=1:length(J_same_st) %��������õĹ����������ж����еĹ����Ƿ�����͹���J������Ӧ��ʽ
               J_new=J_same_st(j);
               [~,pos_os_new]=find(chrom_os==J_new); %�ҵ�����J_new�ڹ����ӹ������е�λ��
               st_new=chrom_fcs(1,J_new)-F; %ѡ�н��������Ĳֿ�ѡ��
               if IT_new(J_new)>=IT_new(J)&&Weight(J)>=Weight(J_new)
                   chrom_fcs(J)=st_new+F;
                   chrom_fcs(J_new)=fa;
                   chrom_os(pos_os_new)=J;
                   chrom_os(pos_os)=J_new;
                   chrom(:,1:n)=[chrom_os;chrom_fcs];
                   factory_bj{fa}(pos_fa)=J_new;
                   bj_decode(1,J)=0;
                   bj_decode(2,J)=st_new;
                   bj_decode(1,J_new)=fa;
                   bj_decode(2,J_new)=0;
                   cost_before=pr_yun*(t_fn(fa,J)+t_cn(st_new,J_new))+pr_cun(1,kind)*(IT_new(J_new)-t_cn(st_new,J_new))+max(0,IT_new(J)-bj_decode(4,J)-t_fn(fa,J))*pr_cun(kind)+max(0,bj_decode(4,J)+t_fn(fa,J)-IT_new(J))*Weight(J); 
                   miss_c_before=pr_machine(J)*max(0,IT_new(J)-bj_decode(4,J)-t_fn(fa,J))+pr_pause(J)*max(0,bj_decode(4,J)+t_fn(fa,J)-IT_new(J));
                   bj_decode(3,J_new)=bj_decode(3,J);
                   bj_decode(4,J_new)=bj_decode(4,J);
                   miss_c_after=pr_machine(J_new)*max(0,IT_new(J_new)-bj_decode(4,J_new)-t_fn(fa,J_new))+pr_pause(J_new)*max(0,bj_decode(4,J_new)+t_fn(fa,J_new)-IT_new(J_new));
                   bj_decode(3,J)=0;
                   bj_decode(4,J)=0;
                   cost_after=pr_yun*(t_fn(fa,J_new)+t_cn(st_new,J))+pr_cun(kind)*(IT_new(J)-t_cn(st_new,J))+max(0,IT_new(J_new)-bj_decode(4,J_new)-t_fn(fa,J_new))*pr_cun(kind)+max(0,bj_decode(4,J_new)+t_fn(fa,J_new)-IT_new(J_new))*Weight(J_new);
                   cost_change=cost_after-cost_before;
                   objectives_change(1)=objectives_change(1)+cost_change;
                   objectives_change(2)=objectives_change(2)+miss_c_after-miss_c_before;
                   break;
               end
           end
        end
    end
    R=dominate(objectives,objectives_change);
    if ~R&&~isequal(objectives,objectives_change)
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.factory_bj=factory_bj;
        Population_chu.machine_start_time=machine_start_time;
        Population_chu.machine_end_time=machine_end_time;
        Population_chu.objectives=objectives_change;
%         Population_orfs(i)=Population_chu;
        Population_orfs=[Population_orfs Population_chu];
    end
end
end