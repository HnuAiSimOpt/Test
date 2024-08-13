function x = my_pcg(A, b, tol, maxit)
    % 初始化
    n = length(b);
    x = zeros(n, 1);
    r = b - A * x;
    p = r;
    k = 0;

    while norm(r) > tol && k < maxit
        Ap = A * p;
        alpha = (r' * r) / (p' * Ap);
        x = x + alpha * p;
        r_new = r - alpha * Ap;
        beta = (r_new' * r_new) / (r' * r);
        p = r_new + beta * p;
        r = r_new;
        k = k + 1;
    end

    disp(['迭代次数：', num2str(k)]);
end

% 示例用法
% A = ...; % 系数矩阵
% b = ...; % 右端项
% tolerance = 1e-6;
% max_iterations = 100;
% x_solution = my_pcg(A, b, tolerance, max_iterations);
% disp('解向量 x:');
% disp(x_solution);
