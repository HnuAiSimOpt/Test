function [xMin, fMin, nIter, infoAL] = Augmented_Lagrangian(x0, mu, v0, tol, maxIter,N,Aeq,lb,ub,H,f) 
% 初始化
nIter = 0;stopCond = false;x_k = x0;infoAL.xs = x_k;infoAL.fs = [];
v_k=v0;
alpha0 = 1; 
opts.c1 = 1e-4;
opts.c2 = 0.9;
opts.rho = 0.5;
tolNewton = 1e-12;
maxIterNewton = 100;

% 循环
while (~stopCond && nIter < maxIter)
    disp(strcat('Iteration ', int2str(nIter)));
    % 为 Q 创建函数处理程序
   % G.f = @(x) 0.5*x'*H*x + f'*x + v_k.*sum(Aeq*x) + (mu/2)*sum((Aeq*x).^2)...
   % +(mu/2).*sum((max(lb-x,0)).^2) + v_k.*sum(max(lb-x,0))...
   % + (mu/2).*sum((max(x-ub,0)).^2)+ v_k.*sum(max(x-ub,0));
    G.f = @(x) 0.5*x'*H*x + f'*x + sum(v_k(1).*(Aeq*x)) + (mu/2)*sum((Aeq*x).^2)...
    +(mu/2).*sum((max(lb-x,0)).^2) + sum(v_k(2:(N+1)).*max(lb-x,0))...
    + (mu/2).*sum((max(x-ub,0)).^2)+ sum(v_k((N+2):(2*N+1)).*max(x-ub,0));
    G.df = @(x)  H*x+f + (v_k(1) + mu*Aeq*x)*Aeq' +  augmented_grad(v_k,mu,x,N,lb,ub);
    G.d2f = @(x) H + mu*(Aeq'*Aeq);
    lsFun = @(x_k, p_k, alpha0) backtracking(G, x_k, p_k, alpha0, opts); 
    x_k_1 = x_k;
    [x_k, f_k, nIterLS, infoIter] = descentLineSearch(G, 'newton', lsFun, alpha0, x_k, tolNewton, maxIterNewton);      
    v_k(1) = v_k(1) + mu*Aeq*x_k; 
    v_k(2:(N+1)) = v_k(2:(N+1)) + mu*max(lb-x_k,0);
    v_k((N+2):(2*N+1)) = v_k((N+2):(2*N+1)) + mu*max(x_k-ub,0);
    % 判断循环终止条件
    if norm(x_k - x_k_1) < tol; stopCond = true; end
    infoAL.xs = [infoAL.xs x_k];
    infoAL.fs = [infoAL.fs f_k];
    
    nIter = nIter + 1;
end
% 赋值
xMin = x_k;
fMin = G.f(x_k);