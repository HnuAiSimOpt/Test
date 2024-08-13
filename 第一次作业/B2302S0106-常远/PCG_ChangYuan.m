% B2302S0106 常远
clear all; close all; clc;
%% 主函数
% 生成算例（参考matlab官方文档）
A = sprand(100,100,0.8);
A = A'*A;
b = sum(A,2);
% 求解，并与官方函数pcg()比较
disp("-----------MATLAB官方函数求解结果--------");
x_matlab = pcg(A, b);
disp("---------------以下为我的方法------------");
x_my = pcg_algorithm(A, b);

%% PCG算法函数
function x = pcg_algorithm(A, b)
    % 预先准备
    eps = 1e-5; % 精度设置，可调
    n = length(A);
    M = M_generate(A);
    invM = inv(M);
    x = zeros(n,1);
    r = b - A * x;
    z = invM * r;
    p = z;
    iter = 0;
    % 循环迭代
    while true
        iter = iter + 1;
        z_last = z;
        r_last = r;
        alpha = (r' * z) / (p' * A * p);
        x = x + alpha * p;
        r = r - alpha * A * p;
        if sqrt(r'*r) < eps * norm(b)
            break;
        end
        z = invM * r;
        beta = (z' * r) / (z_last' * r_last);
        p = z + beta * p;
    end
    fprintf('迭代次数为 %d\n', iter);
    fprintf('相对残差为 %.10f\n', sqrt(r'*r)/norm(b));
end

%% M矩阵生成函数 
function M = M_generate(A)
    % 对角预优矩阵方法
    n = length(A);
    for i = 1 : n
        M(i,i) = A(i,i);
    end
    % 不完全Cholesky因子方法
%     n = length(A);
%     for k = 1:n
%         A(k,k) = sqrt(A(k,k));
%         for i = (k + 1):n
%             if A(i,k) ~= 0
%                 A(i,k) = A(i,k) / A(k,k);
%             end
%         end
%         for j = (k+1) : n
%             for i = j : n
%                 if A(i,j) ~= 0
%                     A(i,j) = A(i,j) - A(i,k) * A(j,k);
%                 end
%             end
%         end
%     end
%     M = tril(A);
end

