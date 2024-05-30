% 初始化参数
x = zeros(5, 1); % 初始解向量
A = [5 2 1 1 0; 2 3 1 0 1; 1 1 4 0 0; 1 0 0 2 0; 0 1 0 0 3]; % 对称正定矩阵
b = [1; 2; 3; 4; 5]; % 五维列向量
r = b - A*x; % 初始残差向量
p = r; % 初始搜索方向
max_iter = 100; % 最大迭代次数
tolerance = 1e-6; % 收敛准则（残差的阈值）

% 存储参数和目标函数值的历史记录
x_history = x; 
f_value_history = x'*A*x + b'*x;

for k = 1:max_iter
    Ap = A*p;
    alpha = (r'*r) / (p'*Ap); % 计算步长
    x = x + alpha*p; % 更新解向量
    
    % 记录参数和目标函数值
    x_history = [x_history, x];
    f_value = x'*A*x + b'*x;
    f_value_history = [f_value_history, f_value];
    
    r_new = r - alpha*Ap; % 计算新的残差向量
    
    if norm(r_new) < tolerance % 检查收敛准则
        break;
    end
    
    beta = (r_new'*r_new) / (r'*r); % 计算共轭梯度法的参数 beta
    p = r_new + beta*p; % 更新搜索方向
    r = r_new; % 更新残差向量
end

% 目标函数和梯度函数
f = @(x) x'*A*x + b'*x; % 目标函数
grad_f = @(x) A*x + b; % 梯度函数

% 绘制参数更新和目标函数值的图形
figure;
subplot(2, 1, 1);
plot(0:length(f_value_history)-1, f_value_history, '-o');
xlabel('Iteration');
ylabel('f(x)');
title('Objective Function Value');

subplot(2, 1, 2);
plot3(x_history(1,:), x_history(2,:), f_value_history, '-o');
xlabel('x1');
ylabel('x2');
zlabel('f(x)');
title('Parameter Update');

% 输出最终的解向量和函数值
x
f_value = f(x)