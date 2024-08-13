% 定义系统矩阵A和向量b
% 这里假设A是对称正定的稀疏矩阵
A = [4 5 1 8;1 5 0 9;1 5 2 8;1 8 9 4];
b = [2;4;6;8];

% 定义预条件矩阵M
% 这里使用对角矩阵的倒数作为简单的预条件
M = diag(1 ./ diag(A));

% 使用PCG求解Ax=b
tol = 1e-6; % 设定容忍度
maxit = 100; % 最大迭代次数

% 调用pcg函数
[x, flag, relres, iter] = pcg(A, b, tol, maxit, M);

% 输出结果
disp('Solution x:');
disp(x);
disp('Convergence flag:');
disp(flag);
disp('Relative residual:');
disp(relres);
disp('Number of iterations:');
disp(iter);
