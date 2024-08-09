clear all;
clc;
G=hilb(40); 
b=sum(G, 2); 
x0=zeros(40, 1); % 初始点我们选为0
kmax=1000; % 最大迭代次数
eps=1e-6; % 精度
    gk = G * x0 + b; % x0 处的正定二次函数梯度值
    dk = -gk; % 初始下降方向
    xk = x0;
    k = 0;
    while k <= kmax
        if norm(gk) < eps
            break
        end
        gk_ = gk; % 迭代前的梯度值
        gk = G * xk + b; % 迭代后的梯度值
        dk_ = dk; % 上一次选取的下降方向
        if k == 0
            dk = -gk; % 初始点的下降方向为负梯度方向
        else
            beta = (gk' * gk) / (gk_' * gk_);
            dk = -gk + beta * dk_; % 共轭梯度法迭代方向
        end
        % 正定二次函数步长公式
        alpha = (gk' * gk) / (dk' * G * dk);
        xk = xk + alpha * dk; % 更新迭代点
        k = k + 1;
    end
    x = xk;
    disp(x);
    disp(k);
    %S2302W0278-舒之睿

