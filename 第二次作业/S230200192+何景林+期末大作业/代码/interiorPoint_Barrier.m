function [xMin, fMin, t, nIter, infoBarrier] = interiorPoint_Barrier(F, phi, x0, t, mu, tol, maxIter)
% 初始化
nIter = 0;
stopCond = false;
x_k = x0;
infoBarrier.xs = x_k;
infoBarrier.fs = F.f(x_k);
infoBarrier.inIter = 0;
infoBarrier.dGap = 1/t;

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
    G.f = @(x) t*F.f(x) + phi.f(x);
    G.df = @(x) t*F.df(x) + phi.df(x);
    G.d2f = @(x) t*F.d2f(x) + phi.d2f(x);
    
    % 行搜索函数
    %lsFun = @(x_k, p_k, alpha0) lineSearch(G, x_k, p_k, alpha0, opts);
    lsFun = @(x_k, p_k, alpha0) backtracking(G, x_k, p_k, alpha0, opts);
    [x_k, f_k, nIterLS, infoIter] = descentLineSearch(G, 'newton', lsFun, alpha0, x_k, tolNewton, maxIterNewton);   
    
    if 1/t < tol; stopCond = true; end
   
    t = mu*t;

    infoBarrier.xs = [infoBarrier.xs x_k];
    infoBarrier.fs = [infoBarrier.fs f_k];
    infoBarrier.inIter = [infoBarrier.inIter nIterLS];
    infoBarrier.dGap = [infoBarrier.dGap 1/t];
    
    nIter = nIter + 1;
end

% 赋值
xMin = x_k;
fMin = F.f(x_k);

