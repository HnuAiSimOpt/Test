clear all;
first_time=cputime;
format short e % �趨�������
fprintf=fopen('input.txt ','rt'); % �����������ļ��������������
nelement=fscanf(fprintf,'%d',1);% ��Ԫ����
npiont=fscanf(fprintf,'%d',1);% ������
nbccondit=fscanf(fprintf,'%d',1) % ��Լ���߽����
nforce=fscanf(fprintf,'%d',1);% �����ظ���
young=fscanf(fprintf,'%e',1);% ����ģ��
poission=fscanf(fprintf,'%f',1);% ���ɱ�
thickness=fscanf(fprintf,'%f',1);% ���
nodes=fscanf(fprintf,'%d',[3,nelement])';% ��Ԫ�������飨��Ԫ���ţ�
ncoordinates=fscanf(fprintf,'%f',[2,npiont])'; % �����������
force=fscanf(fprintf,'%f',[3,nforce])'; % ��������飨��������� , x ���� ,y ����
fc=fopen('constraint.txt ','rt');
constraint=fscanf(fc,'%d',[3,nbccondit])'; % Լ����Ϣ��Լ���㣬 x Լ���� y Լ����%��Լ��Ϊ 1����Լ��Ϊ 0
kk=zeros(2*npiont,2*npiont); % �����ض���С����նȾ����� 0
for i=1:nelement
    D= [1 poission 0; 
 poission 1 0; 
 0 0 (1-poission)/2]*young/(1-poission^2) %���ɵ��Ծ��� D
A=det([1 ncoordinates(nodes(i,1),1) ncoordinates(nodes(i,1),2); 
 1 ncoordinates(nodes(i,2),1) ncoordinates(nodes(i,2),2); 
 1 ncoordinates(nodes(i,3),1) ncoordinates(nodes(i,3),2)])/2 %���㵱ǰ��Ԫ�����A
for j=0:2 
b(j+1)=ncoordinates(nodes(i,(rem((j+1),3))+1) ,2)-ncoordinates(nodes(i,(rem((j+2),3))+1),2); 
c(j+1)=-ncoordinates(nodes(i,(rem((j+1),3))+1),1)+ncoordinates(nodes(i,(rem((j+2),3))+1),1);
end 
 B=[b(1) 0 b(2) 0 b(3) 0;
 0 c(1) 0 c(2) 0 c(3);
 c(1) b(1) c(2) b(2) c(3) b(3)]/(2*A); %����Ӧ����� B
B1( :,:,i)=B;
S=D*B;%��Ӧ������S
nk=B'*S*thickness*A; % ��ⵥԪ�նȾ���
 a=nodes(i,:); % ��ʱ����,������¼��ǰ��Ԫ�Ľڵ���
 for j=1:3 
 for k=1:3 
 kk((a(j)*2-1):a(j)*2,(a(k)*2-1):a(k)*2)=kk((a(j)*2-1):a(j)*2,(a(k)*2-1):a(k)*2)+nk(j*2-1:j*2,k*2-1:k*2); 
 % ���ݽڵ��Ŷ�Ӧ��ϵ����Ԫ�նȷֿ���ӵ��ܸնȾ�����
 end 
 end 
 end
%***************************************************************************** 
%��Լ����Ϣ��������նȾ��󣨶Խ�Ԫ�ظ�һ����
 for i=1:nbccondit
 if constraint(i,2)==1 
 kk(:,(constraint(i,1)*2-1))=0; % һ��Ϊ��
 kk((constraint(i,1)*2-1),:)=0; % һ��Ϊ��
 kk((constraint(i,1)*2-1),(constraint(i,1)*2-1))=1; % �Խ�Ԫ��Ϊ 1 
 end
if constraint(i,3)==1 
 kk( :,constraint(i,1)*2)=0; % һ��Ϊ��
 kk(constraint(i,1)*2,:)=0; % һ��Ϊ��
 kk(constraint(i,1)*2 ,constraint(i,1)*2)=1; % �Խ�Ԫ��Ϊ 1 
 end 
 end 
%*****************************************************************************
%���ɺ�������
 loadvector(1:2*npiont)=0; % ���������������
 for i=1:nforce 
 loadvector((force(i,1)*2-1):force(i,1)*2)=force(i,2:3); 
 end
 %***************************************************************************** 
%�������
 displancement=kk\loadvector' % ����ڵ�λ������
 edisplancement(1:6)=0; % ��ǰ��Ԫ�ڵ�λ������
 for i=1:nelement
 for j=1:3 
 edisplancement(j*2-1:j*2)=displancement(nodes(i,j)*2-1:nodes(i,j)*2); 
 % ȡ����ǰ��Ԫ�Ľڵ�λ������
 end 
 i ;
 stress=D*B1(:, :, i)*edisplancement'; % ������
 stress1(i,:)=[stress'];
 stress_x(i)=stress1(i,1);
 stress_y(i)=stress1(i,2);
 stress_xy(i)=stress1(i,3);
 sigma1(i)=0.5*(stress_x(i)+stress_y(i))+sqrt((stress_xy(i))^2+(0.5*(stress_x(i)-stress_y(i)))^2);
 sigma2(i)=0.5*(stress_x(i)+stress_y(i))-sqrt((stress_xy(i))^2+(0.5*(stress_x(i)-stress_y(i)))^2);
 stress_vonmises(i)=sqrt(0.5*((sigma1(i)-sigma2(i))^2+(sigma1(i)-0)^2+(0-sigma2(i))^2));
 dlmwrite('stress_vonmises.txt',stress_vonmises);
 dlmwrite('stress.txt',stress1);
 dlmwrite('displancement.txt',displancement);
 end
set(0,'defaultfigurecolor','w')
%��vonmissӦ����ͼ
s1=max(stress_vonmises);%������Ӧ��
s2=min(stress_vonmises);%�����СӦ��
a=(s1-s2)/9;%��Ӧ���ֳ�9��
stress_range=zeros(1,10);
stress_range(1)=s1;%stress_range(1)Ϊ���Ӧ��
for i=2:10
    stress_range(i)=stress_range(i-1)-a;
end
range=stress_range;
figure(1);
color=jet(9);%���ʺ�ɫ�ֳ�9��
for i=1:size(nodes)
    ElementCoodinate=[ncoordinates(nodes(i,1),:)
                      ncoordinates(nodes(i,2),:)
                      ncoordinates(nodes(i,3),:)];
    x=ElementCoodinate(:,1);
    y=ElementCoodinate(:,2);
    s=stress_vonmises(i);
    %��Ӧ����С����ɫ��Ӧ
    if (range(1)>=s)&&(s>range(2))
        ColorSpec=color(9,:);
    elseif (range(2)>=s)&&(s>range(3))
        ColorSpec=color(8,:);
    elseif (range(3)>=s)&&(s>range(4))
        ColorSpec=color(7,:);
    elseif (range(4)>=s)&&(s>range(5))
        ColorSpec=color(6,:);
    elseif (range(5)>=s)&&(s>range(6))
        ColorSpec=color(5,:);
    elseif (range(6)>=s)&&(s>range(7))
        ColorSpec=color(4,:);
    elseif (range(7)>=s)&&(s>range(8))
        ColorSpec=color(3,:);
    elseif (range(8)>=s)&&(s>range(9))
        ColorSpec=color(2,:);
    else 
        ColorSpec=color(1,:);
    end
    fill(x,y,ColorSpec);%������ԪӦ����Ӧ����ɫ
    hold on          
end 
% ��Ӧ����ͼ��ǩ
range=sort(range);
colormap(color);
c=colorbar;
c.TickLabels=(range);
c.Ticks=[0,1/9,2/9,3/9,4/9,5/9,6/9,7/9,8/9,9/9];
axis equal;
title('vonmissӦ����ͼ');

%��sigmayӦ����ͼ
s1=max(stress_y);%������Ӧ��
s2=min(stress_y);%�����СӦ��
a=(s1-s2)/9;%��Ӧ���ֳ�9��
stress_range=zeros(1,10);
stress_range(1)=s1;%stress_range(1)Ϊ���Ӧ��
for i=2:10
    stress_range(i)=stress_range(i-1)-a;
end
range=stress_range;
figure(2);
color=jet(9);%���ʺ�ɫ�ֳ�9��
for i=1:size(nodes)
    ElementCoodinate=[ncoordinates(nodes(i,1),:)
                      ncoordinates(nodes(i,2),:)
                      ncoordinates(nodes(i,3),:)];
    x=ElementCoodinate(:,1);
    y=ElementCoodinate(:,2);
    s=stress_y(i);
    %��Ӧ����С����ɫ��Ӧ
    if (range(1)>=s)&&(s>range(2))
        ColorSpec=color(9,:);
    elseif (range(2)>=s)&&(s>range(3))
        ColorSpec=color(8,:);
    elseif (range(3)>=s)&&(s>range(4))
        ColorSpec=color(7,:);
    elseif (range(4)>=s)&&(s>range(5))
        ColorSpec=color(6,:);
    elseif (range(5)>=s)&&(s>range(6))
        ColorSpec=color(5,:);
    elseif (range(6)>=s)&&(s>range(7))
        ColorSpec=color(4,:);
    elseif (range(7)>=s)&&(s>range(8))
        ColorSpec=color(3,:);
    elseif (range(8)>=s)&&(s>range(9))
        ColorSpec=color(2,:);
    else 
        ColorSpec=color(1,:);
    end
    fill(x,y,ColorSpec);%������ԪӦ����Ӧ����ɫ
    hold on          
end 
% ��Ӧ����ͼ��ǩ
range=sort(range);
colormap(color);
c=colorbar;
c.TickLabels=(range);
c.Ticks=[0,1/9,2/9,3/9,4/9,5/9,6/9,7/9,8/9,9/9];
axis equal;
title('sigma_yӦ����ͼ');

%��sigmaxӦ����ͼ
s1=max(stress_x);%������Ӧ��
s2=min(stress_x);%�����СӦ��
a=(s1-s2)/9;%��Ӧ���ֳ�9��
stress_range=zeros(1,10);
stress_range(1)=s1;%stress_range(1)Ϊ���Ӧ��
for i=2:10
    stress_range(i)=stress_range(i-1)-a;
end
range=stress_range;
figure(3);
color=jet(9);%���ʺ�ɫ�ֳ�9��
for i=1:size(nodes)
    ElementCoodinate=[ncoordinates(nodes(i,1),:)
                      ncoordinates(nodes(i,2),:)
                      ncoordinates(nodes(i,3),:)];
    x=ElementCoodinate(:,1);
    y=ElementCoodinate(:,2);
    s=stress_x(i);
    %��Ӧ����С����ɫ��Ӧ
    if (range(1)>=s)&&(s>range(2))
        ColorSpec=color(9,:);
    elseif (range(2)>=s)&&(s>range(3))
        ColorSpec=color(8,:);
    elseif (range(3)>=s)&&(s>range(4))
        ColorSpec=color(7,:);
    elseif (range(4)>=s)&&(s>range(5))
        ColorSpec=color(6,:);
    elseif (range(5)>=s)&&(s>range(6))
        ColorSpec=color(5,:);
    elseif (range(6)>=s)&&(s>range(7))
        ColorSpec=color(4,:);
    elseif (range(7)>=s)&&(s>range(8))
        ColorSpec=color(3,:);
    elseif (range(8)>=s)&&(s>range(9))
        ColorSpec=color(2,:);
    else 
        ColorSpec=color(1,:);
    end
    fill(x,y,ColorSpec);%������ԪӦ����Ӧ����ɫ
    hold on          
end 
% ��Ӧ����ͼ��ǩ
range=sort(range);
colormap(color);
c=colorbar;
c.TickLabels=(range);
c.Ticks=[0,1/9,2/9,3/9,4/9,5/9,6/9,7/9,8/9,9/9];
axis equal;
title('sigma_xӦ����ͼ');

%��sigmaxyӦ����ͼ
s1=max(stress_xy);%������Ӧ��
s2=min(stress_xy);%�����СӦ��
a=(s1-s2)/9;%��Ӧ���ֳ�9��
stress_range=zeros(1,10);
stress_range(1)=s1;%stress_range(1)Ϊ���Ӧ��
for i=2:10
    stress_range(i)=stress_range(i-1)-a;
end
range=stress_range;
figure(4);
color=jet(9);%���ʺ�ɫ�ֳ�9��
for i=1:size(nodes)
    ElementCoodinate=[ncoordinates(nodes(i,1),:)
                      ncoordinates(nodes(i,2),:)
                      ncoordinates(nodes(i,3),:)];
    x=ElementCoodinate(:,1);
    y=ElementCoodinate(:,2);
    s=stress_xy(i);
    %��Ӧ����С����ɫ��Ӧ
    if (range(1)>=s)&&(s>range(2))
        ColorSpec=color(9,:);
    elseif (range(2)>=s)&&(s>range(3))
        ColorSpec=color(8,:);
    elseif (range(3)>=s)&&(s>range(4))
        ColorSpec=color(7,:);
    elseif (range(4)>=s)&&(s>range(5))
        ColorSpec=color(6,:);
    elseif (range(5)>=s)&&(s>range(6))
        ColorSpec=color(5,:);
    elseif (range(6)>=s)&&(s>range(7))
        ColorSpec=color(4,:);
    elseif (range(7)>=s)&&(s>range(8))
        ColorSpec=color(3,:);
    elseif (range(8)>=s)&&(s>range(9))
        ColorSpec=color(2,:);
    else 
        ColorSpec=color(1,:);
    end
    fill(x,y,ColorSpec);%������ԪӦ����Ӧ����ɫ
    hold on          
end 
% ��Ӧ����ͼ��ǩ
range=sort(range);
colormap(color);
c=colorbar;
c.TickLabels=(range);
c.Ticks=[0,1/9,2/9,3/9,4/9,5/9,6/9,7/9,8/9,9/9];
axis equal;
title('sigmaxyӦ����ͼ');

fclose(fc); % �ر������ļ�
fclose(fprintf); % �ر������ļ�


