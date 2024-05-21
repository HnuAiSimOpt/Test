clc;
clear

%����ڵ�����
x0 = load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\x0.txt');
%����abaqus�����õ��Ľڵ�Ӧ������
uus = load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\uu.txt');
%����matlab����õ��Ľڵ�Ӧ������
yingli = load('C:\Users\alein\Desktop\S200200239_FEM\code\xiao_mesh\txt\stress_node.txt');
x=x0(:,2);
x=x';
y=x0(:,3);
y=y';
[m n]=size(uus);
u=uus(:,2);
v=uus(:,3);
z=[];
for i=1:m
    z=[z sqrt(u(i)*u(i)+v(i)*v(i))];
end

%%��λ��
%��ֵ
[X,Y,Z]=griddata(x,y,z,linspace(min(x),max(x))',linspace(min(y),max(y)),'cubic')
%��ͼ���ȸ���ͼ����ȥ����ɫ�ȸ���
figure,contourf(X,Y,Z,'LineStyle','none')   
%���ֹ⻬Ч��
shading flat;
hold on;
colorbar;
title('��λ����ͼ');
%��ά����
figure,mesh(X,Y,Z)
colorbar;
title('��λ����ά��ͼ');

%%x��Ӧ��
%��ֵ
[X,Y,Z1]=griddata(x,y,yingli(:,1),linspace(min(x),max(x))',linspace(min(y),max(y)),'cubic');
%��ͼ���ȸ���ͼ����ȥ����ɫ�ȸ���
figure,contourf(X,Y,Z1,'LineStyle','none') 
%���ֹ⻬Ч��
shading flat;
hold on;
colorbar;
title('x��Ӧ����ͼ');
%��ά����
figure,mesh(X,Y,Z1)
colorbar;
title('x��Ӧ����ά��ͼ');

%%y��Ӧ��
%��ֵ
[X,Y,Z2]=griddata(x,y,yingli(:,2),linspace(min(x),max(x))',linspace(min(y),max(y)),'cubic');
%��ͼ���ȸ���ͼ����ȥ����ɫ�ȸ���
figure,contourf(X,Y,Z2,'LineStyle','none')   
%���ֹ⻬Ч��
shading flat;
hold on;
colorbar;
title('y��Ӧ����ͼ');
%��ά����
figure,mesh(X,Y,Z2)
colorbar;
title('y��Ӧ����ά��ͼ');

%%��Ӧ��
%��ֵ
[X,Y,Z3]=griddata(x,y,yingli(:,3),linspace(min(x),max(x))',linspace(min(y),max(y)),'cubic');
%��ͼ���ȸ���ͼ����ȥ����ɫ�ȸ���
figure,contourf(X,Y,Z3,'LineStyle','none')   
%���ֹ⻬Ч��
shading flat;
hold on;
colorbar;
title('��Ӧ����ͼ');
%��ά����
figure,mesh(X,Y,Z3)
colorbar;
title('��Ӧ����ά��ͼ');