%*************************************************************
% 作者：陈崇学
% 描述：PCG算法
% 参考文档：
% https://blog.genkun.me/post/cg-pcg-implementation/
% https://flat2010.github.io/2018/10/26/共轭梯度法通俗讲义/
% 算法伪代码参考：https://www.cnblogs.com/lansebandaoti/p/10401758.html
%*************************************************************
function [x ,flag, relres, iter, resvect] = preconditioned_conjugate_gradient(A, b, M, tol, maxiter)
    % 判断提供参数
    if nargin < 5
        maxiter = 1000; % 如果未提供收敛阈值，默认最大迭代次数
    end
    if nargin < 4
        tol = 1e-9; % 如果未提供收敛阈值，默认收敛阈值
    end
    if nargin < 3
        M = eye(size(A)); % 如果未提供预处理矩阵，使用单位矩阵
    end

    n = length(b);
    x = zeros(n, 1);  % 初始解向量
    r = b - A * x;    
    z = M \ r;
    p = z;
    resvect = norm(r); % 初始化残差向量
    relres = resvect / norm(b); %相对残差
    iter = 0;
    flag = 1; % 初始化迭代信息

    while relres > tol && iter < maxiter
        iter = iter + 1;
        Ap = A * p;
        alpha = (r' * z) / (p' * Ap);
        x = x + alpha * p;
        r_new = r - alpha * Ap;
        resvect = [resvect; norm(r_new)];
        relres = resvect(end) / norm(b);

        if relres < tol
            flag = 0; % 成功收敛
            break;
        end

        z_new = M \ r_new;
        beta = (r_new' * z_new) / (r' * z);
        p = z_new + beta * p;
        r = r_new;
        z = z_new;
    end

    if iter == maxiter && relres > tol
        flag = 1; % 最大迭代次数内未收敛
    end
end