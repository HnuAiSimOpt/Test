% 定义参数
% 常数 = 硬间隔的 Inf
global poly_con gamma kappa1 kappa2 precision Cost
poly_con=2; % 多项式核函数参数
gamma=1/size(X,1);% 高斯核函数参数
kappa1=1/size(X,1);kappa2=kappa1; % Sigmoid核函数

precision=10^-5;Cost=2;