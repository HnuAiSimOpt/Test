function [x, k] = solve_pcg(A, b, M, k_max, epsilon)
n = size(A, 1);  
x = zeros(n, 1);  
k = 0;  
r = b - A * x;  %初始残差 r?
M_inv = inv(M); 
p = zeros(n, 1);  %初始化搜索方向向量 p 为全零向量
rho_old = 0;  
%开始迭代循环，条件是残差 r 的范数大于 epsilon 与 b 的范数的乘积，且迭代次数小于 k_max。
while norm(r) > epsilon * norm(b) && k < k_max 
    z = M_inv * r;  %预条件残差 z
    rho = r' * z;  %残差 r 和预条件残差 z 的点积?
    k = k + 1;  
    if k == 1
        p = z;  %第一次迭代时，直接将 p 设置为 z
    else        %否则，计算步长 beta，然后更新搜索方向 p
        beta = rho / rho_old;
        p = z + beta * p; 
    end
    w = A * p;  
    alpha = rho / (p' * w); 
    x = x + alpha * p; 
    r = r - alpha * w;  
    rho_old = rho;  
end
end