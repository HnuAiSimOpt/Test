function x = pcg2(A, b, M, x0, tol, maxit)  
    % A: 系数矩阵  
    % b: 右侧向量  
    % M: 预处理矩阵（通常为对称正定矩阵）  
    % x0: 初始解向量  
    % tol: 收敛容差  
    % maxit: 最大迭代次数  
  
    % 初始化  
    x = x0;  
    r = b - A * x;  
    z = M \ r; % 预处理残差  
    p = z; % 搜索方向  
    rsold = r' * z; % 初始残差的内积  
  
    % 迭代过程  
    for k = 1:maxit  
        Ap = A * p;  
        alpha = rsold / (p' * Ap); % 计算步长  
        x = x + alpha * p; % 更新解  
        r = r - alpha * Ap; % 更新残差  
        z = M \ r; % 预处理残差  
  
        % 检查收敛性  
        rsnew = r' * z;  
        if abs(rsnew) < tol  
            break;  
        end  
  
        % 更新搜索方向  
        beta = rsnew / rsold;  
        p = z + beta * p;  
        rsold = rsnew;  
    end  
  
    % 如果达到最大迭代次数而未收敛，则发出警告  
    if k == maxit  
        warning('pcg:MaxIterations', '达到最大迭代次数而未收敛。');  
    end  
end