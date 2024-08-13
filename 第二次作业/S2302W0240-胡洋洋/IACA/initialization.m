function [Population_st]=initialization(popsize,n,F,M,Job,CA,store,protime,t_fn,Style,I_time,w,S)
Population_st(1:popsize)=struct('Chromesome',[],'decode',[],'machine_start_time',[],'machine_end_time',[],'factory_bj',[],'worker_bj',[],'worker_protime',[],'objectives',[],'IT',[],'rank',0,'crowded_distance',0); %�����ṹ��¼��Ⱥ��Ϣ
chrom=zeros(2,2*n); %����Ⱦɫ���С
for i=1:popsize
    %% ȷ��������Ӧ���ֵ�Ⱦɫ������
    if round(rand)==0
        [chrom_fcs]=supplyproduce1(n,F,CA,store,Job);
    else
        [chrom_fcs]=supplyproduce2(n,F,Job,CA,store,I_time);
    end
    [Seed]=seedproduce(n,F,M,protime,Job,chrom_fcs,t_fn,Style,I_time);
    k=ceil(3*rand);
    chrom_os=Seed{1,k};
    chrom(1,1:n)=chrom_os;
    chrom(2,1:n)=chrom_fcs;
    %% ȷ������װ��Ԥ����ά�����ֵ�Ⱦɫ������
    w_total=w*S; %ά����Ա����
    chrom_ws=zeros(1,n); %�����װ��ά����Ĺ���ѡ��
    for j=1:n
        if chrom(2,j)>F
            chrom_ws(1,j)=0; %��֤�ɲֿ����������װ��������ά��
        else
            if rand<0.5
                chrom_ws(1,j)=0;
            else
                chrom_ws(1,j)=unidrnd(w_total);
            end
        end
    end
    chrom(2,n+1:2*n)=chrom_ws;
    [chrom_pre]=maintain(n,I_time);
    k=ceil(2*rand);
    chrom(1,n+1:2*n)=chrom_pre{1,k};
    Population_st(i).Chromesome=chrom;
end
end

function [chrom_fcs]=supplyproduce1(n,F,CA,store,Job)
chrom_fcs=zeros(1,n);
cang=store;
job=randperm(n);
for j=1:n
    kind=Job(job(j)); 
    if ~isempty(CA{kind})
        if rand>=0.5
            Ca=zeros(1,length(CA{kind})); 
            for k=1:length(CA{kind})
                [~,pos]=find(cang{CA{kind}(k)}(1,:)==kind);
                if cang{CA{kind}(k)}(2,pos)~=0
                    Ca(k)=CA{kind}(k);
                end
            end
            Ca(Ca==0)=[];
            if ~isempty(Ca)
                ca=Ca(randperm(length(Ca),1)); %Ϊ�������ѡ����ʵĲֿ�
                chrom_fcs(1,job(j))=F+ca;
                [~,col]=find(cang{ca}(1,:)==kind);
                cang{ca}(2,col)=cang{ca}(2,col)-1; %ȥ���ֿ����ѱ�ѡ��Ӧ�ı���
            else
                chrom_fcs(1,job(j))=unidrnd(F);
            end
        else
            chrom_fcs(1,job(j))=unidrnd(F);
        end
    else
        chrom_fcs(1,job(j))=unidrnd(F);
    end
end
end

function [chrom_fcs]=supplyproduce2(n,F,Job,CA,store,I_time)
chrom_fcs=zeros(1,n); %����������Ĺ����Ͳֿ�ѡ��
[~,job]=sort(I_time); %�������������뽻���ڵķǵݼ�˳������
cang=store;
for j=1:n
    kind=Job(job(j)); 
    if ~isempty(CA{kind})
        if rand>=0.5
            Ca=zeros(1,length(CA{kind})); 
            for k=1:length(CA{kind})
                [~,pos]=find(cang{CA{kind}(k)}(1,:)==kind);
                if cang{CA{kind}(k)}(2,pos)~=0
                    Ca(k)=CA{kind}(k);
                end
            end
            Ca(Ca==0)=[];
            if ~isempty(Ca)
                ca=Ca(randperm(length(Ca),1)); %Ϊ�������ѡ����ʵĲֿ�
                chrom_fcs(1,job(j))=F+ca;
                [~,col]=find(cang{ca}(1,:)==kind);
                cang{ca}(2,col)=cang{ca}(2,col)-1; %ȥ���ֿ����ѱ�ѡ��Ӧ�ı���
            else
                chrom_fcs(1,job(j))=unidrnd(F);
            end
        else
            chrom_fcs(1,job(j))=unidrnd(F);
        end
    else
        chrom_fcs(1,job(j))=unidrnd(F);
    end
end
end
function [chrom_pre]=maintain(n,I_time)
chrom_pre=cell(1,2); %�������ָ�����װ��ά�������
chrom_pre{1,1}=randperm(n);
[~,job]=sort(I_time);
chrom_pre{1,2}=job;
end
