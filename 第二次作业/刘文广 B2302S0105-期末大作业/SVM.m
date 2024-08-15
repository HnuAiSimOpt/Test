clear;
clc;
rng(1);  
n = 50;  
% 生成数据点
x1 = randn(n, 2) + [1, 1];
x2 = randn(n, 2) + [-1, -1];
y1 = ones(n, 1);
y2 = -ones(n, 1);
X = [x1; x2];
Y = [y1; y2];

% 添加偏置项
X = [X, ones(size(X, 1), 1)];  

% 参数设置
m = size(X, 1);  % 数据点数量
n = size(X, 2);  % 特征数量（包括偏置项）
C = 1;  % 惩罚参数

% 定义目标函数
H = (Y * Y') .* (X * X');
f = -ones(m, 1);

% 定义约束
A = [];
b = [];
Aeq = Y';
beq = 0;
lb = zeros(m, 1);
ub = C * ones(m, 1);

% 求解
opts.maxIter = 1000;
opts.tol = 1e-6;
alpha = zeros(m, 1);  
alpha = custom_quadprog(H, f, A, b, Aeq, beq, lb, ub, alpha, opts);

% 计算支持向量
sv_indices = alpha > 1e-5;
sv = X(sv_indices, :);
sv_labels = Y(sv_indices);

% 计算权重和偏置
w = (alpha .* Y)' * X;
b = mean(sv_labels - (sv * w'));

figure;
gscatter(X(:,1), X(:,2), Y, 'rb', 'xo');
hold on;
x1Range = linspace(min(X(:,1)) - 1, max(X(:,1)) + 1, 100);
x2Range = linspace(min(X(:,2)) - 1, max(X(:,2)) + 1, 100);
[x1Grid, x2Grid] = meshgrid(x1Range, x2Range);
XGrid = [x1Grid(:), x2Grid(:), ones(numel(x1Grid), 1)];
Z = XGrid * w' + b;
Z = reshape(Z, size(x1Grid));
contour(x1Grid, x2Grid, Z, [0 0], 'k', 'LineWidth', 2);
xlabel('x');
ylabel('y');
title(' SVM 线性分类');
legend('A', 'B', '超平面');
grid on;

function alpha = custom_quadprog(H, f, A, b, Aeq, beq, lb, ub, alpha0, opts)
    alpha = alpha0; 
    maxIter = opts.maxIter;
    tol = opts.tol;   
    for iter = 1:maxIter
        % 计算目标函数和梯度
        grad = H * alpha + f;
        % 更新 alpha
        alpha = alpha - 0.01 * grad; 
        % 投影到约束集
        alpha = max(lb, min(ub, alpha));
        if norm(grad) < tol
            break;
        end
    end
end
