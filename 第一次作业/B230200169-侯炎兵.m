% 共轭梯度法
% 定义 Ax=b 中的 A、b
A = [8 3; 5 2];
b = [6; 4];

% 初始值
x0 = [0; 0];

% 设置最大迭代次数、容差
max_iter = 100;
tol = 1e-6;

% 使用 PCG 求解
x = PCG1(A, b, x0, max_iter, tol);

function x = PCG1(A, b, x0, max_iter, tol)
% 求解 Ax = b 的子函数

% 初始化变量
x = x0;
r = b - A * x;
p = r;
k = 0;

while k < max_iter && norm(r) > tol
    k = k + 1;

    % 计算公式中的 alpha_k
    alpha_k = r' * p / (p' * A * p);

    % 更新 x_k 和 r_k
    x = x + alpha_k * p;
    r_new = r - alpha_k * A * p;

    % 计算 beta_k
    beta_k = r_new' * r_new / (r' * r);

    % 更新 p_k 和 r_k
    p = r_new + beta_k * p;
    r = r_new;
end

end
