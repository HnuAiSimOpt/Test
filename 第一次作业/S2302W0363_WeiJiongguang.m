clear;
clc;
n=10;
A=sprandn(n,n,0.2)+eye(n)*n;%使用sprandn函数生成一个随机稀疏矩阵A,将对角线元素设置为n
b=randn(n, 1); %生成一个n行1列的随机向量b
disp('A矩阵：');
disp(A);
disp('b矩阵：');
disp(b);
P=diag(diag(A));% 定义一个预处理矩阵,该矩阵是对角阵，对角线元素为A的对角线元素
i_m=200; %最大迭代次数
% 使用预处理共轭梯度法（PCG）求解稀疏矩阵方程
x=zeros(length(b), 1);% 初始化
r=b-A*x;%计算初始残差
z=P\r;%进行预处理
p=z;%设置为初始搜索方向
r_k=dot(r,z);%计算矩阵的内积
rs=zeros(i_m, 1);
for i=1:200
    Ap=A*p; %计算矩阵向量乘积
    al=r_k/dot(p,Ap);%计算步长
    x=x+al*p; %更新解向量 
    r=r-al*Ap; %计算残差 
    rs(i)=norm(r); %计算矩阵的范数
    if norm(r)<1e-7  %如果残差小于阈值，则认为收敛，设置相关变量并跳出循环
       chancha=norm(r)/norm(b);
       f=0;
       break;
    end
    z_k=P\r; %使用预处理矩阵对当前残差进行预处理，得到新的下降方向
    r_k1 =dot(r,z_k); %计算新的残差和新下降方向
    be=r_k1/r_k; 
    p=z_k+be*p;%沿着这个方向，更新
    r_k=r_k1;
end
if i==i_m  %最后判断迭代是否达到最大次数
    f=1;
    chancha=norm(r)/norm(b);
end
rs(i+1:i_m)=[];
disp(['迭代收敛次数 ', num2str(i)]);
disp(['相对残差: ', num2str(chancha)]);
figure;
semilogy(rs, '-o');%绘制以对数形式显示Y轴的图像
xlabel ('迭代次数');
ylabel('误差');