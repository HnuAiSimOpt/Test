clc
clear
% �����ݶȷ�
n=5;
A = hilb(n);
b = rand(n,1);
k_max = 1000;  
epsilon = 1e-6;
M = preconditioner(A);  %Ԥ�������
[x,k] = solve_pcg(A, b, M, k_max, epsilon);  %PCG����