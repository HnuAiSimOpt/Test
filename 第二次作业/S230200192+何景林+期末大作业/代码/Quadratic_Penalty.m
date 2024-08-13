function [xMin, fMin, t, nIter, infoQP] = Quadratic_Penalty(x0, mu, t, tol, maxIter,N,Aeq,lb,ub,H,f)
% 初始化
nIter = 0;stopCond = false;x_k = x0;infoQP.xs = x_k;infoQP.fs = [];
alpha0 = 1; opts.c1 = 1e-4;opts.c2 = 0.9;opts.rho = 0.5;tolNewton = 1e-12;maxIterNewton = 100;
% 循环
while (~stopCond && nIter < maxIter)
%     disp(size(Aeq))
%     disp(size(x_k))
    % 为 Q 创建函数处理程序
G.f =@(x) 0.5*x'*H*x + f'*x + (mu/2).*sum((max(lb-x,0)).^2)+ (mu/2).*sum((max(x-ub,0)).^2)+ (mu/2)*sum((Aeq*x).^2);
G.df =@(x) H*x+f + mu*((Aeq*x)*Aeq') + mu*penalty_grad(x,N,lb,ub);
G.d2f =@(x) H + mu*(Aeq'*Aeq);
      
    lsFun = @(x_k, p_k, alpha0) backtracking(G, x_k, p_k, alpha0, opts);
    x_k_1 = x_k;
    [x_k, f_k, nIterLS, infoIter] = descentLineSearch(G, 'newton', lsFun, alpha0, x_k, tolNewton, maxIterNewton);   
    % 判断循环终止条件
    if norm(x_k - x_k_1) < tol; stopCond = true; end
    mu = mu*t;
    infoQP.xs = [infoQP.xs x_k];
    infoQP.fs = [infoQP.fs f_k];
    nIter = nIter + 1;
end
% 赋值
xMin = x_k;
fMin = G.f(x_k);