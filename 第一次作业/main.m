
%  输入方程组的相关量
A = [2,1;1,3]; % 对称正定矩阵  
b = [-0.5;2]; % 右侧向量  
x0 = [0;0]; % 初始解向量  
epsilon=1e-10; % 收敛容差  
n=(length(b))*10^3; % 最大迭代次数  
  
% 调用共轭梯度法函数求解  
x=conjugateGradient(A, b, x0, epsilon) ; 
% disp(n0); % 显示迭代次数
disp(x); % 显示最终解
