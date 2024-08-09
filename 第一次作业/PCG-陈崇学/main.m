n = 5;    % 矩阵大小
e = ones(n, 1);

% 随机生成矩阵A和向量b
%A = spdiags([-e 2*e -e], -1:1, n, n); % 创建对称正定矩阵A
%b = rand(n, 1); % 创建右端项向量b

% 指定矩阵A和向量b
A = [
    11.8278, -1.1821, -0.4804, -0.3526, 0.2486;
    -1.1821, 9.2569, -0.9441, -1.3575, 0.5022;
    -0.4804, -0.9441, 8.6097, -0.1423, -1.0367;
    -0.3526, -1.3575, -0.1423, 9.7917, 0.0776;
    0.2486, 0.5022, -1.0367, 0.0776, 10.3424
];
b=[0.58;0.54;0.12;0.48;0.72];

% 使用Jacobi预处理（对角矩阵）
M = spdiags(1 ./ diag(A), 0, n, n);

% 打印矩阵 A, b, M
fprintf('矩阵 A:\n');
disp(full(A)); % 打印稀疏矩阵A
fprintf('向量 b:\n');
disp(b); % 打印向量b
fprintf('预调整矩阵 M:\n');
disp(full(M)); % 打印稀疏矩阵M

% 求解，默认最大迭代次数1000次，默认收敛阈值1e-9
[x, flag, relres, iter, resvec] = preconditioned_conjugate_gradient(A, b, M);

% 打印结果
fprintf('x 为:\n');
disp(x);
fprintf('Flag（1-未收敛，0-收敛）: %d\n', flag);
fprintf('相对残差: %e\n', relres);
fprintf('迭代次数: %d\n', iter);