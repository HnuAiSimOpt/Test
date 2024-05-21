clear
clc

%����Ԫ������m��n��
m=50;
n=20;

%��ά���μ�������

vertex=[0,0;0,1;5,1;5,0];


x0=[];
for i=1:m+1
    for j=1:n+1
        x0=[x0; (i-1)*5/m  -1*(1-(j-1)/n)];
    end
end


nodes=[];
for i=1:m
    for j=1:n
        nodes=[nodes; (n+1)*(i-1)+j (n+1)*i+j (n+1)*i+j+1 (n+1)*(i-1)+j+1;];
    end
end

% ��������
iplot=1;
if iplot==1
   figure(1)
   hold on
   axis off
   axis equal
   for ie=1:m*n
        for j=1:4+1
            j1=mod(j-1,4)+1;
            xp(j)=x0(nodes(ie,j1),1);
            yp(j)=x0(nodes(ie,j1),2);
        end
        plot(xp,yp,'-')
   end
          
end
%-------------------------------------------------------------------------
%�ڵ���
for ii=1:m %��ii�е�Ԫ
    for jj=1:n %��jj�е�Ԫ
        node((ii-1)*n+jj,1)=(ii-1)*(n+1)+jj;
        node((ii-1)*n+jj,2)=(ii-1)*(n+1)+jj+1;
        node((ii-1)*n+jj,3)=ii*(n+1)+jj+1;
        node((ii-1)*n+jj,4)=ii*(n+1)+jj;
    end
end
%-------------------------------------------------------------------------
for nd=0:n
    x(nd+1)=vertex(1,1)+nd*(vertex(2,1)-vertex(1,1))/n;   %�±�����ڵ㻮�֣�x����
    x((n+1)*m+nd+1)=vertex(4,1)+nd*(vertex(3,1)-vertex(4,1))/n;   %�ϱ�����ڵ㻮�֣�x����
    y(nd+1)=vertex(1,2)+nd*(vertex(2,2)-vertex(1,2))/n;   %�±�����ڵ㻮�֣�y����
    y((n+1)*m+nd+1)=vertex(4,2)+nd*(vertex(3,2)-vertex(4,2))/n;   %�ϱ�����ڵ㻮�֣�y����
end

%�ڲ��ڵ㸳ֵ
for ndin=1:n+1  %�ڲ���ndin�нڵ�
    for mdin=1:m-1  %�ڲ���mdin�нڵ�
        x((n+1)*mdin+ndin)=x(ndin)+(x((n+1)*m+ndin)-x(ndin))/m*mdin;   %�ڲ��ڵ������
        y((n+1)*mdin+ndin)=y(ndin)+(y((n+1)*m+ndin)-y(ndin))/m*mdin;   %�ڲ��ڵ�������
    end
end
%--------------------------------------------------------

w1=1;w2=1;%��˹����Ȩ��ϵ��
E=1;%����ģ��
v=0.3;%���ɱ�
D=E/(1-v^2)*[1 v 0;v 1 0; 0 0 (1-v)/2];%Ӧ��-Ӧ����ϵת��ʽ

%�ĸ����ֵ�ĵȲ�����
d=[-1/sqrt(3),-1/sqrt(3);
-1/sqrt(3),1/sqrt(3);
1/sqrt(3),-1/sqrt(3);
1/sqrt(3),1/sqrt(3)];

%�ı��θ��ڵ�Jacob����Ӧ����󡢸նȾ���

%�κ�����eta��ƫ����etaΪ��Ȼ���������
N_eta=zeros(4);
syms eta
for kk=1:4
    zeta=d(kk,2);
    %�κ���
    N1=1/4*(1-eta)*(1-zeta);
    N2=1/4*(1+eta)*(1-zeta);
    N3=1/4*(1+eta)*(1+zeta);
    N4=1/4*(1-eta)*(1+zeta);
    N_eta(kk,1:4)=[diff(N1,eta),diff(N2,eta),diff(N3,eta),diff(N4,eta)];
end
%�κ�����zeta��ƫ����etaΪ��Ȼ����������
N_zeta=zeros(4);
syms zeta
for kk=1:4
    eta=d(kk,1);
    %�κ���
    N1=1/4*(1-eta)*(1-zeta);
    N2=1/4*(1+eta)*(1-zeta);
    N3=1/4*(1+eta)*(1+zeta);
    N4=1/4*(1-eta)*(1+zeta);
    N_zeta(kk,1:4)=[diff(N1,zeta),diff(N2,zeta),diff(N3,zeta),diff(N4,zeta)];
end

Ke=zeros((m+1)*(n+1)*2);   %�նȾ����ʼ��

%����������Ԫ�նȾ��󲢵���
for unit=1:m*n
   
    %���㵥����Ԫ�նȾ���
    unitx_loc=[x(node(unit,1)),x(node(unit,2)),x(node(unit,3)),x(node(unit,4))]; 
    unity_loc=[y(node(unit,1)),y(node(unit,2)),y(node(unit,3)),y(node(unit,4))]; 
    unit_loc=[unitx_loc',unity_loc'];   %��unit����Ԫ���������Σ�����
    K=zeros(8,8);   %������Ԫ�նȾ����ʼ��
   for mm=1:4   %mmΪ�ڵ�ţ��ֲ���1~4��
      J=[N_eta(mm,:);N_zeta(mm,:)]*unit_loc;   %Jacob����
      Nxy=inv(J)*[N_eta(mm,:);N_zeta(mm,:)];
      B=[Nxy(1,1),0,Nxy(1,2),0,Nxy(1,3),0,Nxy(1,4),0;
      0,Nxy(2,1),0,Nxy(2,2),0,Nxy(2,3),0,Nxy(2,4);
      Nxy(2,1),Nxy(1,1),Nxy(2,2),Nxy(1,2),Nxy(2,3),Nxy(1,3),Nxy(2,4),Nxy(1,4)];   %Ӧ�����
      K=K+w1*w2*B'*D*B*det(J);   %�նȾ���
   end
   
   %��Ԫ�նȾ������
   for p=1:4
       for q=1:4
          Ke(2*node(unit,p)-1:2*node(unit,p),2*node(unit,q)-1:2*node(unit,q))=...
          Ke(2*node(unit,p)-1:2*node(unit,p),2*node(unit,q)-1:2*node(unit,q))+K(2*p-1:2*p,2*q-1:2*q);
       end
   end
end

%ʩ��������
Fe=zeros(2*(m+1)*(n+1),1);
Fe(length(Fe),1)=1;

bcdof=[];
bcval=[];
for i=1:21
        bcdof=[bcdof 1+2*(i-1) 2+2*(i-1)];
        bcval=[bcval 0 0];
end

%-----------------------------------------------------------------------
%ʩ�ӱ߽�����
 nn=length(bcdof);
 sdof=size(Ke);

 for i=1:nn
    c=bcdof(i);
    for j=1:sdof
       Ke(c,j)=0;
    end

    Ke(c,c)=1;
   Fe(c)=bcval(i);
 end

%-----------------------------------------------------------------------
%����λ��
[LL UU]=lu(Ke);

utemp=LL\Fe;

uv=UU\utemp;



%-----------------------------------------------------------------------
%����Ӧ������

stress=zeros((m+1)*(n+1),3);   %Ӧ�������ʼ��
a=1+sqrt(3)/2;b=-1/2;c=1-sqrt(3)/2;   %���ھֲ�Ӧ����������Ӧ������ת��
for unit=1:m*n

    unitx_loc=[x(node(unit,1)),x(node(unit,2)),x(node(unit,3)),x(node(unit,4))]; 
    unity_loc=[y(node(unit,1)),y(node(unit,2)),y(node(unit,3)),y(node(unit,4))]; 
    unit_loc=[unitx_loc',unity_loc'];   %��unit����Ԫ���������Σ�����
    %���㵥����Ԫ�ֲ�Ӧ������
   for mm=1:4   %mmΪ�ڵ�ţ��ֲ���1~4��
      J=[N_eta(mm,:);N_zeta(mm,:)]*unit_loc;   %Jacob����
      Nxy=inv(J)*[N_eta(mm,:);N_zeta(mm,:)];
      B=[Nxy(1,1),0,Nxy(1,2),0,Nxy(1,3),0,Nxy(1,4),0;
      0,Nxy(2,1),0,Nxy(2,2),0,Nxy(2,3),0,Nxy(2,4);
      Nxy(2,1),Nxy(1,1),Nxy(2,2),Nxy(1,2),Nxy(2,3),Nxy(1,3),Nxy(2,4),Nxy(1,4)];   %Ӧ�����
      stress_e(mm,:)=[D*B*[uv(2*node(unit,1)-1),uv(2*node(unit,1)),...
      uv(2*node(unit,2)-1),uv(2*node(unit,2)),uv(2*node(unit,3)-1),...
      uv(2*node(unit,3)),uv(2*node(unit,4)-1),uv(2*node(unit,4))]']';   %��Ԫ�ֲ�Ӧ������
      
   end
   %�ֲ�Ӧ������ת������Ӧ�����󣬲�����
   stress_whole=[a b c b;b a b c;c b a b;b c b a]*stress_e;
   for mm=1:4
       stress(node(unit,mm),:)=stress(node(unit,mm),:)+stress_whole(mm,:);   %����Ӧ���������
   end
end
stress;
%�൥Ԫ���ýڵ�Ӧ��ȡƽ��ֵ
for nod=1:(m+1)*(n+1)
    for row=0:m
    if nod>(n+1)*row+1 & nod<(n+1)*(row+1)
        stress(nod,:)=stress(nod,:)/2;
    end
    end
    for column=0:n
    if nod>column+1 & nod<(n+1)*m+column+1 & (nod-column-1)/(n+1)==fix((nod-column-1)/(n+1))
        stress(nod,:)=stress(nod,:)/2;
    end
    end
end
uv;
stress;
dispu=zeros(1,1071);%x����λ��
dispv=zeros(1,1071);%y����λ��

for i=1:1071
    dispu(i)=uv(2*i-1);
    dispv(i)=uv(2*i);
end


[X,Y,Z]=griddata(x0(:,1),x0(:,2),dispu,linspace(0,5,50)',linspace(0,-1,20),'v4');
figure(2);
pcolor(X,Y,Z);
shading interp; 
colormap(jet); %x����λ����ͼ
[X,Y,Z]=griddata(x0(:,1),x0(:,2),dispv,linspace(0,5,50)',linspace(0,-1,20),'v4');
figure(3);
pcolor(X,Y,Z);
shading interp; 
colormap(jet); %y����λ����ͼ
[X,Y,Z]=griddata(x0(:,1),x0(:,2),stress(:,1),linspace(0,5,50)',linspace(0,-1,20),'v4');
figure(4);
pcolor(X,Y,Z);
shading interp; 
colormap(jet); %x����Ӧ����ͼ
[X,Y,Z]=griddata(x0(:,1),x0(:,2),stress(:,2),linspace(0,5,50)',linspace(0,-1,20),'v4');
figure(5);
pcolor(X,Y,Z);
shading interp; 
colormap(jet); %y����Ӧ����ͼ
figure(6);
quiver(x0(:,1),x0(:,2),dispu',dispv');%����ͼ

% �������
%-------------------------------------------------------------
fid_out=fopen('result.txt','w');

fprintf(fid_out,'VARIABLES="x" "y" "u" "v" "sigax"  "sigmay" "sigmaxy"\n');


for i=1:nod
    fprintf(fid_out,'%16.6e%16.6e%16.6e%16.6e%16.6e%16.6e%16.6e\n',x0(i,1),x0(i,2),dispu(i)',dispv(i)',stress(i,1),stress(i,2),stress(i,3));
end







