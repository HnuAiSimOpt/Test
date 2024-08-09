% 定义 Ax=b 中的 A、b
A = [4 1 2; 1 5 3; 2 3 6]; % 新的对称正定矩阵
b = [1; 2; 3]; % 新的常数向量

% 初始值
x0 = [0; 0; 0]; % 初始解向量

% 设置最大迭代次数、容差
max_iter = 100;
tol = 1e-6;

% 使用 PCG 求解
x = PCG1(A, b, x0, max_iter, tol);
% 显示解向量
disp(x);

function x = PCG1(A, b, x0, max_iter, tol)
    % 初始化变量
    x = x0;
    r = b - A * x; % 初始残差
    p = r; % 初始搜索方向
    rsold = r' * r; % 用于计算beta_k

    for k = 1:max_iter
        % 如果残差足够小，则停止
        if norm(r) < tol
            break;
        end

        % 计算 alpha_k
        alpha = rsold / (p' * A * p);

        % 更新解 x
        x = x + alpha * p;

        % 计算新的残差
        r = r - alpha * A * p;

        % 检查残差范数是否小于容差
        if norm(r) < tol
            break;
        end

        % 计算 beta_k
        rsnew = r' * r;
        beta = rsnew / rsold;

        % 更新搜索方向 p
        p = r + beta * p;

        % 更新 rsold 为下一次迭代使用
        rsold = rsnew;
    end
end