function [Population_orfs]=LS1_P(Population_home,popsize,n,F,M,T,protime,t_fn,t_cn,pr_cun,pr_yun,pr_machine,pr_pause,Job,CA,store,Weight)
% 将由工厂加工的工件和仓库调拨的工件相互交货工厂、仓库，以降低延迟惩罚成本
Population_orfs=Population_home;
for i=1:popsize
    Population_chu=Population_home(i);
    chrom=Population_chu.Chromesome;
    bj_decode=Population_chu.decode;
    factory_bj=Population_chu.factory_bj;
    machine_start_time=Population_chu.machine_start_time;
    machine_end_time=Population_chu.machine_end_time;
    objectives=Population_chu.objectives;
    objectives_change=objectives; %储存交换操作后的目标值
    IT_new=Population_chu.IT;
    chrom_os=chrom(1,1:n); %供应部分的工件排列
    chrom_fcs=chrom(2,1:n); %供应部分的工厂\仓库选择序列
    [~,J_f]=find(chrom_fcs<=F); %在工厂中加工的工件集合
    delay_cost=zeros(1,length(J_f)); %储存由工厂加工的工件的延误惩罚
    for k=1:length(J_f)
        j=J_f(k);
        f=bj_decode(1,j); %确定选定工件的加工工厂
        delay_cost(k)=max(0,bj_decode(4,j)+t_fn(f,j)-IT_new(j))*Weight(j); 
    end
    if ~isempty(delay_cost>0)
        miss_c_change=0;
        flag=0;
        [~,pos]=max(delay_cost); %确定具有最大延误的工件索引位置
        J=J_f(pos); %最大延误工件
        fa=bj_decode(1,J); %最大延误工件所在的工厂
        kind=Job(J); %最大延误工件的类型
        [~,pos_os]=find(chrom_os==J); %找到最大延误工件J在工件加工序列中的位置
        [~,pos_fa]=find(factory_bj{fa}==J); %找到最大延误工件J在对应工厂中的位置
        [~,J_same]=find(Job==kind);
        J_same(J_same==J)=[]; %确定除了工件J外类型也为kind的工件集合
        for s=1:length(CA{kind}) %依次判断各仓库是否还有类型为kind的工件剩余
            st=CA{kind}(s);
            [~,pos_st]=find(store{st}(1,:)==kind); %确定此类型工件在各仓库中的储存位置
            if length(find(chrom_fcs(J_same)==st+F))<store{st}(2,pos_st)
                flag=flag+1; %用于标记是否已对最大延误工件进行过将工厂生产直接换成仓库调拨
                miss_c_change=miss_c_change-pr_machine(J)*max(0,IT_new(J)-bj_decode(4,J)-t_fn(fa,J))-pr_pause(J)*max(0,bj_decode(4,J)+t_fn(fa,J)-IT_new(J));
                chrom_fcs(J)=st+F;
                chrom(2,1:n)=chrom_fcs;
                bj_decode(1,J)=0;
                bj_decode(2,J)=st;
                bj_decode(3,J)=0;
                bj_decode(4,J)=0;
                J_cost_before=delay_cost(pos)+pr_yun*t_fn(fa,J)+pr_cun(1,kind)*T; %工件J供应方式更换前的总成本
                J_cost_after=pr_cun(1,kind)*(IT_new(J)-t_cn(st,J))+pr_yun*t_cn(st,J); %工件J供应方式更换为仓库调拨后的总成本
                J_cost_change=J_cost_after-J_cost_before; %更换供应方式后成本变化量
                factory_bj{fa}(pos_fa)=[]; %在工厂fa中删除工件J
                for m=1:M
                    machine_start_time{(fa-1)*M+m}(pos_fa)=[];
                    machine_end_time{(fa-1)*M+m}(pos_fa)=[]; %将工件J原来在机器上的加工开始、结束时间删除
                end
                if pos_fa~=length(factory_bj{fa})+1
                    for j=pos_fa:length(factory_bj{fa}) %对原来在工件J后边加工的工件重新解码
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
           J_same_st=J_same(chrom_fcs(J_same)>F); %与工件J同类型的工件中属于仓库调拨方式的工件集
           for j=1:length(J_same_st) %对上述求得的工件集依次判断其中的工件是否满足和工件J交换供应方式
               J_new=J_same_st(j);
               [~,pos_os_new]=find(chrom_os==J_new); %找到工件J_new在工件加工序列中的位置
               st_new=chrom_fcs(1,J_new)-F; %选中交换工件的仓库选择
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