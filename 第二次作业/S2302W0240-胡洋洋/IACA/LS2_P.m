function [Population_orff]=LS2_P(Population_home,popsize,n,F,Job,t_fn,pr_cun,pr_machine,pr_pause,Weight)
% ͬһ�����ڵĹ�������һ�����򽻻��ӹ�˳��
Population_orff=Population_home;
for i=1:popsize
    Population_chu=Population_home(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    factory_bj=Population_chu.factory_bj;
    objectives=Population_chu.objectives;
    objectives_change=objectives;
    IT_new=Population_chu.IT;
    for f=1:F
        J=factory_bj{f}; %����f�ӹ��Ĺ�������
        delay_cost=zeros(1,length(J)); %��¼�˹����и��������ӳٳͷ�
        for j=1:length(J)
            job=J(j);
            delay_cost(j)=max(0,bj_decode(4,job)+t_fn(f,job)-IT_new(job))*Weight(job);
        end
        [~,posd_f]=max(delay_cost); %�ҵ��ӳٳͷ����Ĺ����ڹ����еļӹ�λ��
        [~,posd]=find(delay_cost>0); 
        Jd=J(posd); %�ҵ��˹��������е����󹤼�
        J_delay=J(posd_f(1)); %ȷ���ӳٳͷ����Ĺ���
        [~,posd_os]=find(chrom(1,1:n)==J_delay); %ȷ���ӳٳͷ����Ĺ����ڹ����ӹ������е�λ��
        kind_delay=Job(J_delay); %������󹤼�������
        Jd_same=Jd(Job(Jd)==kind_delay);
        Jd_same(Jd_same==J_delay)=[]; %ͬһ�ӹ������г�����J_delay������ҲΪkind_delay�Ĺ�������
        if ~isempty(Jd_same)
            cost_change=zeros(1,length(Jd_same)); %��¼���������ӹ�˳�򽻻���ĳɱ��仯��
            for k=1:length(Jd_same)
                J_new=Jd_same(k); %�ҵ��빤��J_delayͬһ���͵���һ����
                cost_before=delay_cost(posd_f)+max(0,IT_new(J_new)-bj_decode(4,J_new)-t_fn(f,J_new))*pr_cun(kind_delay)+max(0,bj_decode(4,J_new)+t_fn(f,J_new)-IT_new(J_new))*Weight(J_new); %����ɱ����ƣ���Ϊ�����ӹ�˳�򻥻�ǰ������ɱ����ı�
                if IT_new(J_delay)<IT_new(J_new)&&bj_decode(4,J_delay)+t_fn(f,J_delay)>bj_decode(4,J_new)+t_fn(f,J_new)&&Weight(J_delay)>Weight(J_new)
                    cost_after=max(0,IT_new(J_new)-bj_decode(4,J_delay)-t_fn(f,J_new))*pr_cun(kind_delay)+max(0,bj_decode(4,J_delay)+t_fn(f,J_new)-IT_new(J_new))*Weight(J_new)+max(0,IT_new(J_delay)-bj_decode(4,J_new)-t_fn(f,J_delay))*pr_cun(kind_delay)+max(0,bj_decode(4,J_new)+t_fn(f,J_delay)-IT_new(J_delay))*Weight(J_delay);
                    cost_change(k)=cost_after-cost_before;
                end
            end
            if ~isempty(find(cost_change<0, 1)) %������ڽ����ӹ�˳���ɱ����͵����
                [~,pos_j]=find(cost_change==min(cost_change),1); %�ҵ��ɱ���С���Ľ��������ڼ���J_same�е�λ��
                J_change=Jd_same(pos_j); %������������󹤼������ӹ�λ�õĹ���
                [~,pos_os_change]=find(chrom(1,1:n)==J_change); %�ҵ����������ڼӹ������е�λ��
                [~,pos_f_change]=find(J==J_change); %�ҵ����������Ĵ�ѡ�������еļӹ�λ��
                chrom(1,posd_os)=J_change;
                chrom(1,pos_os_change)=J_delay;
                factory_bj{f}(posd_f)=J_change;
                factory_bj{f}(pos_f_change)=J_delay;
                miss_c_before1=pr_machine(J_delay)*max(0,IT_new(J_delay)-bj_decode(4,J_delay)-t_fn(f,J_delay))+pr_pause(J_delay)*max(0,bj_decode(4,J_delay)+t_fn(f,J_delay)-IT_new(J_delay));
                miss_c_before2=pr_machine(J_change)*max(0,IT_new(J_change)-bj_decode(4,J_change)-t_fn(f,J_change))+pr_pause(J_change)*max(0,bj_decode(4,J_change)+t_fn(f,J_change)-IT_new(J_change));
                miss_c_after1=pr_machine(J_delay)*max(0,IT_new(J_delay)-bj_decode(4,J_change)-t_fn(f,J_delay))+pr_pause(J_delay)*max(0,bj_decode(4,J_change)+t_fn(f,J_delay)-IT_new(J_delay));
                miss_c_after2=pr_machine(J_change)*max(0,IT_new(J_change)-bj_decode(4,J_delay)-t_fn(f,J_change))+pr_pause(J_change)*max(0,bj_decode(4,J_delay)+t_fn(f,J_change)-IT_new(J_change));
                miss_c_change=miss_c_after1+miss_c_after2-miss_c_before1-miss_c_before2;
                starttime_change=bj_decode(3,J_change);
                endtime_change=bj_decode(4,J_change); %������������ǰ��ԭ�ӹ���ʼʱ��ͽ���ʱ��
                bj_decode(3,J_change)=bj_decode(3,J_delay);
                bj_decode(4,J_change)=bj_decode(4,J_delay);
                bj_decode(3,J_delay)=starttime_change;
                bj_decode(4,J_delay)=endtime_change;
                objectives_change(1)=objectives_change(1)+min(cost_change);
                objectives_change(2)=objectives_change(2)+miss_c_change;
            end
        end
    end
    R=dominate(objectives,objectives_change);
    if ~R&&~isequal(objectives,objectives_change)
        Population_chu.Chromesome=chrom;
        Population_chu.decode=bj_decode;
        Population_chu.factory_bj=factory_bj;
        Population_chu.objectives=objectives_change;
%         Population_orff(i)=Population_chu;
        Population_orff=[Population_orff Population_chu];
    end
end
end