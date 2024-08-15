function [x, flag, relres, iter, resvec] = preconditioned_cg(A, b, tol, maxit,M)
% PRECONDITIONED_CG Solves Ax = b using the Preconditioned Conjugate Gradient method
%
% Inputs:
%   A     - Coefficient matrix (symmetric positive definite)
%   b     - Right hand side vector
%   tol   - Tolerance for the relative residual
%   maxit - Maximum number of iterations
%   M     - Preconditioner matrix (should be symmetric positive definite)
%
% Outputs:
%   x      - Solution vector
%   flag   - Convergence flag (0 if converged, 1 otherwise)
%   relres - Relative residual norm(b-Ax)/norm(b)
%   iter   - Number of iterations performed
%   resvec - Vector of residual norms at each iteration
%  A = % 系数矩阵 A
   N = 50;
   A = delsq(numgrid('S',N));
   b = ones(size(A,1),1); % 右端项向量 b
   tol = 1e-6; % 设定的容差
   maxit = 1000; % 最大迭代次数
   L = ichol(A);
   M = L*L';% 预处理矩阵 M (如 M = ichol(A))
    % Initialization
    n = length(b);
    x = zeros(n,1);
    %A = reshape(A,10,10);% Initial guess x0 = 0
    r = b - A*x;    % Initial residual r0 = b - A*x0
    z = M \ r;      % Apply preconditioner M
    p = z;          % Initial search direction p0
    resvec = zeros(maxit+1, 1);
    resvec(1) = norm(r);
    
    if resvec(1) <= tol
        flag = 0;
        relres = resvec(1) / norm(b);
        iter = 0;
        resvec = resvec(1);
        return;
    end
    
    for iter = 1:maxit
        Ap = A * p;
        alpha = (r' * z) / (p' * Ap);
        x = x + alpha * p;
        r_new = r - alpha * Ap;
        
        resvec(iter+1) = norm(r_new);
        
        if resvec(iter+1) <= tol * norm(b)
            flag = 0;
            relres = resvec(iter+1) / norm(b);
            resvec = resvec(1:iter+1);
            return;
        end
        
        z_new = M \ r_new;
        beta = (r_new' * z_new) / (r' * z);
        p = z_new + beta * p;
        
        r = r_new;
        z = z_new;
    end
    
    flag = 1; % Did not converge within maxit iterations
    relres = resvec(iter+1) / norm(b);
    resvec = resvec(1:iter+1);
end

 


