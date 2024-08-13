dbstop if error
clear;
clc;
cur_path=cd;
%% input parameter
aim=2;
popsize=25;
Pc=0.9;
Pm=0.1;
Mep=15; %��Ӣ��Ⱥ����������
maxgen=100; %�趨����������
SearchSize=25; %���������ĸ�����
%% load instance
n_num=[100 300 500];
F_num=[3 5];
M_num=[5 8];
Style_num=[5 15];
S_num=[3 4];
w_num=[3 4];
for n_index=1:3
    n=n_num(n_index); %��������
    Time=0.5*n;
    for F_index=1:length(F_num) %��������ˮƽ
        F=F_num(F_index); %��������
        for M_index=1:length(M_num) %��������ˮƽ
            M=M_num(M_index); %��������
            for Style_index=1:length(Style_num) %��������ˮƽ
                Style=Style_num(Style_index); %����������
                for S_index=1:length(S_num)
                    S=S_num(S_index);
                    for w_index=1:length(w_num)
                        w=w_num(w_index);
                        filename=strcat('data_',num2str(n),'x',num2str(F),'x',num2str(M),'x',num2str(Style),'x',num2str(S),'x',num2str(w));
                        cd('D:\hyy\�����Ż���ҵ\����')
                        load(filename)
                        cd (cur_path);
                        PF_pop_total = [];
                        for count=1:5
                            tic;
                            EP=[];
                            AA=[];
                            %% ��ʼ����Ⱥ
                            [Population_st]=initialization(popsize,n,F,M,Job,CA,store,protime,t_fn,Style,I_time,w,S);
                            %% ��Ⱥ���뼰����ѭ��
                            decode_size=popsize;
                            for MG=1:maxgen
                                if decode_size~=0
                                    Population_st0=Population_st(popsize-decode_size+1:popsize);
                                    [Population_st0]=decode(decode_size,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,Population_st0); %�����³�ʼ���ĸ������
                                    Population_st(popsize-decode_size+1:popsize)=Population_st0;
                                end
                                %% ��Ⱥ����
                                [crossPopulation,cross_size]=cross_pro(Population_st,popsize,n,F,Job,store,Pc);
                                %% ��Ⱥ�������
                                [mutationPopulation]=mutation_pro(crossPopulation,cross_size,n,Job,Style,Pm);
                                %% ��Ⱥ�ϲ�
                                [Population_decode0]=decode(cross_size,F,C,n,M,w,S,Style,T,store,Job,pr_cun,pr_yun,C_pre,pr_pause,pr_machine,protime,pretime,transfertime,t_fn,t_cn,Weight,MHV,rate,repair,maintain_EL,I_time,mutationPopulation);
                                Population_decode=[Population_st Population_decode0];
                                pop=popsize+cross_size;
                                %% ��Ⱥ�����֧������
                                [Population_nds]=nondominant_sort(Population_decode,pop,aim);
                                pop_num=length(Population_nds([Population_nds.rank]==1));
                                if pop_num<SearchSize %�����Ⱥ��ǰ�ظ�����������������ģ������������ģ��С���оֲ����������ǰ�ظ���������������ģ������ǰ�ظ�������оֲ�����
                                    pop_num=SearchSize;
                                end
                                %% �ֲ���������Ӧ���֣�
                                [pop_ls]=LS1_P(Population_nds,pop_num,n,F,M,T,protime,t_fn,t_cn,pr_cun,pr_yun,pr_machine,pr_pause,Job,CA,store,Weight);
                                [pop_ls]=LS2_P(pop_ls,pop_num,n,F,Job,t_fn,pr_cun,pr_machine,pr_pause,Weight);
                                [pop_ls]=LS3_P(pop_ls,pop_num,n,F,Job,Style,t_cn,pr_yun,pr_cun);
                                %% �Թ�Ӧ�����ѽ��оֲ������õ��ĸ����֧������
                                [Population_nds]=nondominant_sort(pop_ls,length(pop_ls),aim);
                                pop=length(Population_nds([Population_nds.rank]==1));
                                if pop<SearchSize %�����Ⱥ��ǰ�ظ�����������������ģ������������ģ��С���оֲ����������ǰ�ظ���������������ģ������ǰ�ظ�������оֲ�����
                                    pop=SearchSize;
                                end
                                %% �ֲ�������ά�����֣�
                                [Population_or]=orientate0(Population_nds,pop,n,F,w,S,Job,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,pretime,t_fn,transfertime,maintain_EL,I_time,MHV,repair,rate);
                                [Population_or2]=orientate2(Population_or,pop,n,F,w,S,Job,pretime,t_fn,transfertime,pr_cun,pr_yun,pr_pause,pr_machine,C_pre,I_time,maintain_EL,Weight,MHV,repair,rate);
                                [Population_cancel]=orientate_cancel(Population_or2,pop,n,F,w,S,Job,pretime,t_fn,t_cn,transfertime,pr_cun,pr_machine,pr_pause,pr_yun,C_pre,I_time,maintain_EL,Weight);
                                [Population_change]=orientate_change(Population_cancel,pop,n,w,t_fn,S,Job,pr_yun,pr_cun,C_pre,pr_machine,pr_pause,pretime,transfertime,maintain_EL,MHV,repair,rate,Weight);
                                [Population_move]=orientate_move(Population_change,pop,n,w,S,t_fn,transfertime,Job,pretime,pr_cun,pr_yun,pr_machine,pr_pause,I_time,maintain_EL,Weight,MHV,repair,rate);
                                [Population_swap,IT]=orientate_swap(Population_move,pop,n,F,w,S,Job,t_fn,MHV,rate,repair,pretime,transfertime,pr_yun,pr_cun,pr_machine,pr_pause,maintain_EL,I_time,Weight);
                                %% �Խ�����ֲ������ĸ����֧������
                                [Population_last]=nondominant_sort(Population_swap,length(Population_swap),aim);
                                %% ����ӵ�����벢ѡ�����
                                [Population_ch]=selectPopulate(Population_last,popsize,aim);
                                %% ����Ⱥ����ȥ�غ��ٳ�ʼ������
                                [Population_st,child_size]=elimination_initialize(Population_ch,popsize,n,Job,F,M,CA,store,Style,protime,t_fn,I_time,w,S,aim);
                                decode_size=child_size;
                                EEP=[EP Population_ch([Population_ch.rank]==1)]; %%����أ����ڴ���ÿ�ε�����ľ�Ӣ����
                                [EP]=nondominant_sort(EEP,length(EEP),aim);
                                [EP]=elimination(EP,length(EP),aim);
                                EP=EP([EP.rank]==1); %�����������ǰ�ظ���
                                newobj=(reshape([EP.objectives],aim,numel(EP)))';
                                AA=[AA;mean(newobj,1)]
                            end
                            PF_pop_total=[PF_pop_total,EP];
                        end
                        %% ������
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