clc
clear all
% 定义系数矩阵 A 和右侧向量 b   
A = [4 12 -16; 12 37 -43; -16 -43 98]; % 这是一个对称正定矩阵的例子  
b = [6; 25; -111]; 
% 初始猜测  
x0 = [0; 0 ; 0];  
  
% 设置预处理矩阵 M（这里简单地使用A的对角元素的倒数） 
D = 1 ./ A;
M = diag(diag(D));   
  
% 设置容忍度和最大迭代次数  
tol = 1e-6;  
maxiter = 100;  
  
% 调用 PCG 函数求解 
    %自我编写的pcg
    x1 = pcg2(A, b, M, x0, tol, maxiter);
    % 显示结果
    disp('Solution:');  
    disp(x1);
    %matlab自带的pcg
    x = pcg(A, b, tol, maxiter,M);  
    % 显示结果  
    disp(x);