clc;
clear
%��������Ԫ����е�λ�ƾ���
uus = load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\uu.txt');      
uu=[];
[m n]=size(uus);
for i=1:m
    uu(2*i-1, 1)=uus(i, 2);
    uu(2*i,1)=uus(i,3);
end
%����matlab����õ���λ�ƾ���
uu_fem= load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\U_fem.txt');
%��������Ԫ����нڵ�Ӧ������
s_node= load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\s_node.txt');
%����matlab����õ��Ľڵ�Ӧ������
stress_node= load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\stress_node.txt');
%λ�Ƽ������������������Ĳ�ֵ
difference_u=uu_fem-uu;
uu1=uu;
%x��Ӧ�����ֽ���Ĳ�ֵ
difference_sx=stress_node-s_node(:,2:4);
stress_x=stress_node(:,1);
s_x=s_node(:,2);
%��λ��������
error_u=[];
%x��Ӧ��������
error_s=[];
%������������matlab�������ı�ֵ
e_u=[];
e_s=[];
error_u_abs_r=zeros(2*m,1);
for j=1:2*m
    error_u(j,1)=difference_u(j,1)/uu_fem(j,1);
    e_u(j,1)=uu1(j,1)/uu_fem(j,1);
    error_u_abs=abs(error_u);
   % if error_u_abs(j)==1
    %   error_u_abs_r(j)=0;
   % else
    %    error_u_ab_r(j)= error_u_abs(j);
    %end
end
for i=1:m
    error_s(i,1)=difference_sx(i,1)/stress_x(i,1);
    e_s(i,1)=s_x(i,1)/stress_x(i,1);
    error_s_abs=abs(error_s);
end
%���������������������ľ�ֵ
a=0;
for i=1:2*m
    a=a+error_u_abs(i);
end
%mean_u=mean(error_u_abs);
mean_u=a/(2*m);
mean_s=mean(error_s_abs);