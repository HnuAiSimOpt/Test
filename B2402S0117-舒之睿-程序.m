clc;clear all    
em=load('elements.txt');    %��Ԫ��ż��������ڵ����
nd_x_y=load('nodes2.txt');   %�ڵ�����
BC_nd=load('bound_consition.txt');%����ABAQUS�����õı߽������ڵ��ŵ���
F_nd=load('force.txt'); %���ص�Ԫ�Ľڵ���
ele_nd=4;%ÿ����Ԫ�ڵ���
nd_free=2;%ÿ���ڵ����ɶ���
em_free=8;%ÿ����Ԫ���ɶ���
em_num=size(em);%��Ԫ����
em_num=em_num(1);
nd_num=size(nd_x_y);%�ڵ�����
nd_num=nd_num(1);
total_free=nd_free*nd_num;%�����ɶ���
E=2.1e5;%���ϵĵ���ģ��
u=0.3;%���ϵĲ��ɱ�
F_x=500; %��x����ļ�����
F_y=0;   %��y����ļ�����
F_xy=sparse(total_free,1); %��������ĳ�ʼ��
K_s=zeros(total_free,total_free);%����նȾ���ĳ�ʼ��
total_dispace=sparse(total_free,1);%����λ�Ƶĳ�ʼ��
em_dispace=sparse(em_free,1);%��Ԫλ�Ƶĳ�ʼ��
Stre=zeros(em_num(1),4,3);%Ӧ������ĳ�ʼ��
Stra=zeros(em_num(1),4,3);%Ӧ�����ĳ�ʼ��
B=sparse(3,8);%Ӧ�����B����
D=sparse(3,3);%���Ծ���D����
Gauss_point=[-1/sqrt(3) 1/sqrt(3)];%��ֵ��˹����ʱ2��2����Ӧ�Ļ��ֵ�ֵ     
Guass_weight=[1 1];%��ֵ��˹����ʱ��Ӧ�ļ�Ȩϵ��
D=E/(1-u^2).*[1 u 0; %���Ծ���D����ı��
               u 1 0;
               0 0 (1-u)/2];
for i_1=1:em_num 
%��ȡ����Ԫ4���ڵ�����
    for j_1=1:ele_nd
        em_nd(j_1)=em(i_1,j_1+1); %��ȡ��i_1����Ԫ�ĵ�j_1���ڵ�
        coor_x(j_1)=nd_x_y(em_nd(j_1),2);%��ȡ��j_1�ڵ��x����ֵ
        coor_y(j_1)=nd_x_y(em_nd(j_1),3);%��ȡ��j_1�ڵ��y����ֵ
    end
K_e=sparse(em_free,em_free); %��ʼ����Ԫ�նȾ���
Jacob=zeros(2,2);%��ʼ���ſ˱Ⱦ���

 for i_2=1:2                              
        Guass_x=Gauss_point(i_2);                  
        Weight_x=Guass_weight(i_2);                  
        for j_2=1:2
            Guass_y=Gauss_point(j_2);              
            Weight_y=Guass_weight(j_2);               
 %���κ����������
 N(1)=(1/4)*(1-Guass_x)*(1-Guass_y);
 N(2)=(1/4)*(1+Guass_x)*(1-Guass_y);
 N(3)=(1/4)*(1+Guass_x)*(1+Guass_y);
 N(4)=(1/4)*(1-Guass_x)*(1+Guass_y);
%�κ����ֱ��x��y��ƫ��
 d_x(1)=-(1/4)*(1-Guass_y);
 d_x(2)=(1/4)*(1-Guass_y);
 d_x(3)=(1/4)*(1+Guass_y);
 d_x(4)=-(1/4)*(1+Guass_y);

 d_y(1)=-(1/4)*(1-Guass_x);
 d_y(2)=-(1/4)*(1+Guass_x);
 d_y(3)=(1/4)*(1+Guass_x);
 d_y(4)=(1/4)*(1-Guass_x);    
            Jacob(1,1)=d_x(1)*coor_x(1)+d_x(2)*coor_x(2)+d_x(3)*coor_x(3)+d_x(4)*coor_x(4);
            Jacob(1,2)=d_x(1)*coor_y(1)+d_x(2)*coor_y(2)+d_x(3)*coor_y(3)+d_x(4)*coor_y(4);
            Jacob(2,1)=d_y(1)*coor_x(1)+d_y(2)*coor_x(2)+d_y(3)*coor_x(3)+d_y(4)*coor_x(4);
            Jacob(2,2)=d_y(1)*coor_y(1)+d_y(2)*coor_y(2)+d_y(3)*coor_y(3)+d_y(4)*coor_y(4);
            Det_Jacob=det(Jacob);                  
            Jacob_ni=[Jacob(2,2) -Jacob(1,2);-Jacob(2,1) Jacob(1,1)]/Det_Jacob; 
            N_d=Jacob_ni*[d_x(1) d_x(2) d_x(3) d_x(4);d_y(1) d_y(2) d_y(3) d_y(4)]; 
            %��B���������⡣
             for i_3=1:ele_nd
        B(1,2*i_3-1)=N_d(1,i_3);
        B(1,2*i_3)=0;
        B(2,2*i_3-1)=0;
        B(2,2*i_3)=N_d(2,i_3);
        B(3,2*i_3-1)=N_d(2,i_3);
        B(3,2*i_3)=N_d(1,i_3); 
 end
  %�Ե�Ԫ�ĸնȾ���������                                      
   K_e=K_e+B'*D*B*Weight_x*Weight_y*Det_Jacob;                                
            
        end
 end
   t_c=1;
     for i_4=1:ele_nd
         U_t(t_c)=2*em_nd(i_4)-1;
         U_t(t_c+1)=2*em_nd(i_4);
          t_c=t_c+2;
     end    
      for i_5=1:em_free            
          for j_5=1:em_free
            %����Ԫ�ն���װ������նȾ���
            K_s(U_t(i_5),U_t(j_5))=K_s(U_t(i_5),U_t(j_5))+K_e(i_5,j_5);
            
         end
      end
end
%�������ص�Lģ��
for i_6=1:length(F_nd)
    F_xy(2*F_nd(i_6)-1)=F_x;          
    F_xy(2*F_nd(i_6))=F_y;  
end
%�Ա߽�������������
for i_7=1:length(BC_nd)
    t_c=BC_nd(i_7);
    for j_7=1:size(K_s,2)
       K_s(2*t_c-1,j_7)=0;
       K_s(2*t_c,j_7)=0;
       K_s(j_7,2*t_c-1)=0;
       K_s(j_7,2*t_c)=0;
    end
 F_xy(2*t_c-1)=0;
 F_xy(2*t_c)=0;
 K_s(2*t_c-1,2*t_c-1)=1;
 K_s(2*t_c,2*t_c)=1;
end
 K_s_inv=inv(K_s);
%��λ��ֵ�������
 total_dispace=K_s_inv*F_xy;
%��Ӧ��Ӧ��ֵ���м���
t_a=1+(sqrt(3))/2;
t_b=-1/2;
t_c=1-(sqrt(3))/2;
%��ת��������б�ʾ
trans_matrix=[t_a t_b t_c t_b
           t_b t_a t_b t_c ;
           t_c t_b t_a t_b ;
           t_b t_c t_b t_a ;];     
for i_8=1:em_num                                
    for j_8=1:ele_nd
        em_nd(j_8)=em(i_8,j_8+1);%�Ե�i_8����Ԫ�ĵ�j_8���ڵ������ȡ
        coor_x(j_8)=nd_x_y(em_nd(j_8),2);%�Ե�j_8�ڵ��x����ֵ������ȡ
        coor_y(j_8)=nd_x_y(em_nd(j_8),3);%�Ե�j_8�ڵ��y����ֵ������ȡ
    end
    K_e=sparse(em_free,em_free);			      
    t_t=0;
    G_stre=zeros(3,4);                        
    G_stra=zeros(3,4);
    for i_9=1:2                 
        for j_9=1:2
            u=[total_dispace(2*em_nd(1)-1);total_dispace(2*em_nd(1));total_dispace(2*em_nd(2)-1);total_dispace(2*em_nd(2));total_dispace(2*em_nd(3)-1);total_dispace(2*em_nd(3));total_dispace(2*em_nd(4)-1);total_dispace(2*em_nd(4))];       
            ele_stra=B*u;                          
            ele_stre=D*ele_stra;                             
            t_t=t_t+1;                               
            G_stre(:,t_t)=ele_stre;                 
            G_stra(:,t_t)=ele_stra;
        end
    end
%����˹������ڵ����ת��
   for i_11=1:3
        for j_11=1:4
           for n=1:4
                Stre(i_8,j_11,i_11)= Stre(i_8,j_11,i_11)+trans_matrix(j_11,n)*G_stre(i_11,n);
                Stra(i_8,j_11,i_11)=Stra(i_8,j_11,i_11)+trans_matrix(j_11,n)*G_stra(i_11,n);
            end
        end
   end
end
n_nd_0=cell(nd_num,1);
n_nd_1 = cell(nd_num,1);
n_nd_nigh=zeros(1,nd_num);
for i_12=1:em_num
    for j_12=1:4
        n_nd_nigh(em(i_12,j_12))=n_nd_nigh(em(i_12,j_12))+1;
        n_nd_0{em(i_12,j_12)}(n_nd_nigh(em(i_12,j_12)))=i_12;
        n_nd_1{em(i_12,j_12)}(n_nd_nigh(em(i_12,j_12)))=j_12;
    end
end

stre_total_nd=zeros(3,nd_num);
stra_total_nd=zeros(3,nd_num);
for i_13=1:nd_num
    el_num= n_nd_nigh(i_13);
    for j_13=1:el_num
        el_n= n_nd_0{i_13}(j_13);
        nd_n=n_nd_1{i_13}(j_13);
        for t_t=1:3
            stre_total_nd(t_t,i_13)=stre_total_nd(t_t,i_13)+Stre(el_n,nd_n,t_t);
            stra_total_nd(t_t,i_13)=stra_total_nd(t_t,i_13)+Stra(el_n,nd_n,t_t);
        end
    end
    stre_total_nd(:,i_13)=stre_total_nd(:,i_13)/el_num;
    stra_total_nd(:,i_13)=stra_total_nd(:,i_13)/el_num;
end
%����Lģ�����������ı���ͼ�������б���ǰ����κ����Ա�
for i_14=1:em_num           
        for j_14=1:4  
            x_direc_bef(j_14)=nd_x_y(em(i_14,j_14+1),2);
            y_direc_bef(j_14)=nd_x_y(em(i_14,j_14+1),3);
            x_direc_aft(j_14)=x_direc_bef(j_14)+total_dispace(2*em(i_14,j_14+1)-1);
            y_direc_aft(j_14)=y_direc_bef(j_14)+total_dispace(2*em(i_14,j_14+1));
        end
        figure(1)
plot(x_direc_bef,y_direc_bef,'-r.')
hold on
plot(x_direc_aft,y_direc_aft,'-b.')
end
 legend('����ǰ','���κ�');
%��Lģ����x��y�����λ�ơ�Ӧ����Ӧ��ͼ�ֱ����
%��x�����λ��ͼ���л���
xy=-1;
dispace_plot(em_num,total_dispace,em,nd_x_y,xy,nd_num);
%��y�����λ��ͼ���л���
xy=1;
dispace_plot(em_num,total_dispace,em,nd_x_y,xy,nd_num);
%��x�����Ӧ��ͼ���л���
xy=-2;t=-1;
stre_stra_plot(em_num,stra_total_nd,stre_total_nd,em,nd_x_y,xy,t,total_dispace,nd_num)
%��y�����Ӧ��ͼ���л���
xy=-0.5;t=-1;
stre_stra_plot(em_num,stra_total_nd,stre_total_nd,em,nd_x_y,xy,t,total_dispace,nd_num)
%��x�����Ӧ��ͼ���л���
xy=0.5;t=1;
stre_stra_plot(em_num,stra_total_nd,stre_total_nd,em,nd_x_y,xy,t,total_dispace,nd_num)
%��y�����Ӧ��ͼ����
xy=2;t=1;
stre_stra_plot(em_num,stra_total_nd,stre_total_nd,em,nd_x_y,xy,t,total_dispace,nd_num)

