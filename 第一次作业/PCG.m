function [x, rs, ps, alphas] = PCG(A, b, max_iter, tol, x0)

n = length(b);  % 获取问题的维度

% 初始化输出量
x = zeros(n, max_iter+1);  % 解向量在每一步的值
rs = zeros(n, max_iter+1);  % 残差向量在每一步的值
ps = zeros(n, max_iter+1);  % 搜索方向在每一步的值
alphas = zeros(1, max_iter+1);  % 步长在每一步的值

x(:,1) = x0;  % 设置初始解
r = b - A * x(:,1);  % 计算初始残差
p = r;  % 设置初始搜索方向

rs(:,1) = r;  % 存储初始残差
ps(:,1) = p;  % 存储初始搜索方向

for i = 1:max_iter
    alpha = (r' * r) / (p' * A * p);  % 计算步长
    x(:,i+1) = x(:,i) + alpha * p;  % 更新解
    r_new = r - alpha * A * p;  % 计算新残差
    
    if norm(r_new) < tol  % 检查收敛性
        break;
    end
    
    beta = (r_new' * r_new) / (r' * r);  % 计算beta
    p = r_new + beta * p;  % 更新搜索方向
    
    r = r_new;  % 更新残差
    
    rs(:,i+1) = r;  % 存储新残差
    ps(:,i+1) = p;  % 存储新搜索方向
    alphas(:,i) = alpha;  % 存储步长
end

% 根据实际迭代次数截取输出量
x = x(:, 1:i+1);
rs = rs(:, 1:i+1);
ps = ps(:, 1:i+1);
alphas = alphas(:, 1:i);
end