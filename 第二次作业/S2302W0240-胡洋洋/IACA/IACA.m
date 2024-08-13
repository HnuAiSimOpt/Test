dbstop if error
clear;
clc;
cur_path=cd;
%% input parameter
aim=2;
popsize=25;
Pc=0.9;
Pm=0.1;
Mep=15; %精英种群个体数容量
maxgen=100; %设定最大迭代次数
SearchSize=25; %邻域搜索的个体数
%% load instance
n_num=[100 300 500];
F_num=[3 5];
M_num=[5 8];
Style_num=[5 15];
S_num=[3 4];
w_num=[3 4];
for n_index=1:3
    n=n_num(n_index); %备件数量
    Time=0.5*n;
    for F_index=1:length(F_num) %工厂数量水平
        F=F_num(F_index); %工厂数量
        for M_index=1:length(M_num) %机器数量水平
            M=M_num(M_index); %机器数量
            for Style_index=1:length(Style_num) %备件类型水平
                Style=Style_num(Style_index); %备件类型数
                for S_index=1:length(S_num)
                    S=S_num(S_index);
                    for w_index=1:length(w_num)
                        w=w_num(w_index);
                        filename=strcat('data_',num2str(n),'x',num2str(F),'x',num2str(M),'x',num2str(Style),'x',num2str(S),'x',num2str(w));
                        cd('D:\hyy\工程优化作业\算例')
                        load(filename)
                        cd (cur_path);
                        PF_pop_total = [];
                        for count=1:5
                            tic;
                            EP=[];
                            AA=[];
                            %% 初始化种群
                            [Population_st]=initialization(popsize,n,F,M,Job,CA,store,protime,t_fn,Style,I_time,w,S);
                            %% 种群解码及迭代循环
                            decode_size=popsize;
                            for MG=1:maxgen
                                if decode_size~=0
                                    Population_st0=Population_st(popsize-decode_size+1:popsize);
                                    [Population_st0]=decode(decode_size,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,Population_st0); %对重新初始化的个体解码
                                    Population_st(popsize-decode_size+1:popsize)=Population_st0;
                                end
                                %% 种群交叉
                                [crossPopulation,cross_size]=cross_pro(Population_st,popsize,n,F,Job,store,Pc);
                                %% 种群变异操作
                                [mutationPopulation]=mutation_pro(crossPopulation,cross_size,n,Job,Style,Pm);
                                %% 种群合并
                                [Population_decode0]=decode(cross_size,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,mutationPopulation);
                                Population_decode=[Population_st Population_decode0];
                                pop=popsize+cross_size;
                                %% 种群个体非支配排序
                                [Population_nds]=nondominant_sort(Population_decode,pop,aim);
                                pop_num=length(Population_nds([Population_nds.rank]==1));
                                if pop_num<SearchSize %如果种群的前沿个体数不超过搜索规模，则以搜索规模大小进行局部搜索；如果前沿个体数超过搜索规模则所有前沿个体均进行局部搜索
                                    pop_num=SearchSize;
                                end
                                %% 局部搜索（供应部分）
                                [pop_ls]=LS1_P(Population_nds,pop_num,n,F,M,T,protime,t_fn,t_cn,pr_cun,pr_yun,pr_machine,pr_pause,Job,CA,store,Weight);
                                [pop_ls]=LS2_P(pop_ls,pop_num,n,F,Job,t_fn,pr_cun,pr_machine,pr_pause,Weight);
                                [pop_ls]=LS3_P(pop_ls,pop_num,n,F,Job,Style,t_cn,pr_yun,pr_cun);
                                %% 对供应部分已进行局部搜索得到的个体非支配排序
                                [Population_nds]=nondominant_sort(pop_ls,length(pop_ls),aim);
                                pop=length(Population_nds([Population_nds.rank]==1));
                                if pop<SearchSize %如果种群的前沿个体数不超过搜索规模，则以搜索规模大小进行局部搜索；如果前沿个体数超过搜索规模则所有前沿个体均进行局部搜索
                                    pop=SearchSize;
                                end
                                %% 局部搜索（维护部分）
                                [Population_or]=orientate0(Population_nds,pop,n,F,w,S,Job,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,pretime,t_fn,transfertime,maintain_EL,I_time,MHV,repair,rate);
                                [Population_or2]=orientate2(Population_or,pop,n,F,w,S,Job,pretime,t_fn,transfertime,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,I_time,maintain_EL,Weight,MHV,repair,rate);
                                [Population_cancel]=orientate_cancel(Population_or2,pop,n,F,w,S,Job,pretime,t_fn,t_cn,transfertime,pr_cun,pr_machine,pr_pause,pr_yun,C_pre,I_time,maintain_EL,Weight);
                                [Population_change]=orientate_change(Population_cancel,pop,n,w,t_fn,S,Job,pr_yun,pr_cun,C_pre,pr_machine,pr_pause,pretime,transfertime,maintain_EL,MHV,repair,rate,Weight);
                                [Population_move]=orientate_move(Population_change,pop,n,w,S,t_fn,transfertime,Job,pretime,pr_cun,pr_yun,pr_machine,pr_pause,I_time,maintain_EL,Weight,MHV,repair,rate);
                                [Population_swap,IT]=orientate_swap(Population_move,pop,n,F,w,S,Job,t_fn,MHV,rate,repair,pretime,transfertime,pr_yun,pr_cun,pr_machine,pr_pause,maintain_EL,I_time,Weight);
                                %% 对进行完局部搜索的个体非支配排序
                                [Population_last]=nondominant_sort(Population_swap,length(Population_swap),aim);
                                %% 计算拥挤距离并选择个体
                                [Population_ch]=selectPopulate(Population_last,popsize,aim);
                                %% 对种群进行去重和再初始化操作
                                [Population_st,child_size]=elimination_initialize(Population_ch,popsize,n,Job,F,M,CA,store,Style,protime,t_fn,I_time,w,S,aim);
                                decode_size=child_size;
                                EEP=[EP Population_ch([Population_ch.rank]==1)]; %%基因池，用于储存每次迭代后的精英个体
                                [EP]=nondominant_sort(EEP,length(EEP),aim);
                                [EP]=elimination(EP,length(EP),aim);
                                EP=EP([EP.rank]==1); %迭代结束后的前沿个体
                                newobj=(reshape([EP.objectives],aim,numel(EP)))';
                                AA=[AA;mean(newobj,1)]
                            end
                            PF_pop_total=[PF_pop_total,EP];
                        end
                        %% 保存结果
                        obj_set=(reshape([PF_pop_total.objectives],aim,numel(PF_pop_total)))';
                        [~,remain_set]=unique(obj_set,'rows');
                        pop_remain=PF_pop_total(remain_set);
                        Population = nondominant_sort(pop_remain,length(pop_remain),aim);
                        pop_final=Population([Population.rank]==1);
                        filename=strcat('IACA_',num2str(n),'x',num2str(F),'x',num2str(M),'x',num2str(Style),'x',num2str(S),'x',num2str(w));
                        save(filename,'pop_final');
                    end
                end
            end
        end
    end
end