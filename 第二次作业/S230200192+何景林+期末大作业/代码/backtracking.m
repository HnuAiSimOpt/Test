
function [alpha, info] = backtracking(F, x_k, p, alpha0, opts)

alpha=alpha0;
a=[];
while F.f(x_k+alpha*p) > F.f(x_k)+opts.c1*alpha *(F.df(x_k)'*p)
    alpha = opts.rho*alpha;
    a=[a,alpha];
end
info.alphas=a;

end

















