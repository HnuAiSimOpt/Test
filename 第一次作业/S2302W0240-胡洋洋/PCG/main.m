clc
clear
% 共轭梯度法
n=5;
A = hilb(n);
b = rand(n,1);
k_max = 1000;  
epsilon = 1e-6;
M = preconditioner(A);  %预处理矩阵
[x,k] = solve_pcg(A, b, M, k_max, epsilon);  %PCG程序