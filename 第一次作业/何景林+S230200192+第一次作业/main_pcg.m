clc
clear all
%% 初始化
% 定义线性方程系数矩阵 
A =[4,12,-16;
     12,37,-43; 
     -16,-43,98]; 
b= [6;25;-111]; 
% 初值  
x0 = [0;0;0];   
% 设置预处理矩阵
B =1./A;
M =diag(diag(B));   
% 设置容许误差和最大迭代数  
precision=1e-6;  
Maxloop =100;    
%% 调用自我编写的 pcg 函数求解 
    x1=pcg2(A,b,M,x0,precision,Maxloop);
    disp('自编：');  
    disp(x1);
%% 调用matlab自带的 pcg 函数求解 
    disp('matlab自带：');
    x=pcg(A,b,precision,Maxloop,M);      
    disp(x);
%% pcg函数
function x=pcg2(A,b,M,x0,precision,Maxloop )   
    x=x0;  
    r=b-A*x;  
    z=M\r;       % 预处理容差  
    p=z;           % 搜索方向  
    old =r'*z;    % 容差的内积初值  
    i=1;
    while i < Maxloop   
        c=A*p;  
        a=old/(p'*c);     % 计算步长  
        x= x+a*p;          % 更新解  
        r=r-a*c;          % 更新容差  
        z =M\r;              % 预处理容差 
        % 判断收敛性并终止  
        new =r'*z;  
        if abs(new) < precision  
            break;  
        end  
        % 更新搜索方向  
        b =new/old;  
        p=z+b*p;  
        old=new;  
        i=i+1;
    end   
    if i==Maxloop 
        disp('达到最大迭代次数但未收敛');  
    end  
end