function [result, x_result, num] = conjungate_gradient(f, x, x0, epsilon)
syms lambdas; 
n = length(x);
nf = cell(1, n); 
for i = 1 : n
    nf{i} = diff(f, x{i});
end
nfv = subs(nf, x, x0);
nfv_pre = nfv;
count = 0;
k = 0;
xv = x0;
d = - nfv; 
while (norm(nfv) > epsilon)
    xv = xv+lambdas*d;
    phi = subs(f, x, xv);
    nphi = diff(phi); 
    lambda = solve(nphi); 
        lambda = double(lambda);  
    xv = subs(xv, lambdas, lambda); 
    xv = double(xv);
    nfv = subs(nf, x, xv);   
    count = count + 1;
    k = k + 1; 
    alpha = sumsqr(nfv) / sumsqr(nfv_pre);
    d = -nfv + alpha * d;
    nfv_pre = nfv;
    if k >= n
        k = 0;
        d = - nfv;
    end
end 
result = double(subs(f, x, xv));
x_result = double(xv);
num = count;
end
syms x1 x2;
f = x1^2+2*x2^2-4*x1-2*x1*x2;
x = {x1 x2};
x0= [1 1];
e = 1e-1;
[result, x_result, num] = conjungate_gradient(f, x, x0, e);
