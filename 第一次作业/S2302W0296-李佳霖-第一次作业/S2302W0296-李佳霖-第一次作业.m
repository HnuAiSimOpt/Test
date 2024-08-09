function [x, flag, relres, iter, resvec] = PCG (A, B, x0, tol, loop)%工程优化作业
    A = [4 1 1 1; 1 3 0 1; 1 0 2 1; 1 1 1 4];  % 定义矩阵 A 和向量 B
    B = [1; 2; 3; 4];
    x0 = zeros(size(B));
    tol = 1e-6;
    loop = 1000;
    r = B - A*x0;    % 初始化残差 r 和搜索方向 p
    p = r;
    rsold = r' * r;
    for iter = 1:loop   % PCG 迭代
        Ap = A * p;     % 计算 A*p 和更新解向量 x
        alpha = rsold / (p' * Ap);
        x = x0 + alpha * p;
        r = r - alpha * Ap;   % 更新残差和计算新残差的范数
        rsnew = r' * r;
        resvec(iter) = sqrt(rsnew);   % 记录每次迭代后的残差范数
        if sqrt(rsnew) < tol          % 判断残差范数是否满足容许误差
            flag = 0; % 收敛
            break;
        end
        beta = rsnew / rsold;    % 计算下一个搜索方向的系数 beta
        p = r + beta * p;
        rsold = rsnew;
        x0 = x;
    end
    if iter == loop          % 判断迭代是否收敛
        flag = 1;             % 未收敛
    end
end



