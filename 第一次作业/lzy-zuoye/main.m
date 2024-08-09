clear;
clc;

% 定义系数矩阵A和右侧向量b
n = input('请输入矩阵A的维度: ');
A = rand(n);
A = A + A';  % 确保A是对称矩阵
A = A + n*eye(n);  % 确保A是正定矩阵
b = rand(n, 1);

disp('矩阵A:');
disp(A);
disp('右侧向量b:');
disp(b);

disp('矩阵A的特征值:');
disp(eig(A));
disp('矩阵A的条件数:');
disp(cond(A));

max_iter = 1000;
tol = 1e-6;
x0 = zeros(n, 1); 

tic;
c1 = A \ b;
toc;
disp('精确解:');
disp(c1);

tic;
[c2, rs, ps, alphas] = PCG(A, b, max_iter, tol, x0);
toc;
disp('数值解:');
disp(c2(:,end));

disp('残差范数:');
disp(norm(rs(:,end)));