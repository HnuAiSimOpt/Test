% 生成主对角元素为n的对称阵
n = 5;  % 设定矩阵维度
A = zeros(n, n);  % 生成矩阵存放A
b = zeros(n, 1);  % 生成向量存放b

% 填充矩阵A和向量b
for i = 1:n
    A(i, i) = n;  % 设矩阵A的对角元素为5
    b(i) = rand();  % 随机生成0~1的浮点数作为常数项
    for j = i+1:n
        A(i, j) = rand();  % 随机生成0~1的浮点数作为矩阵A的第i行j列元素
        A(j, i) = A(i, j);  % 生成矩阵A的对称元素
    end
end

% 计算Jacobi预处理矩阵,即为A的对角的逆矩阵
Minv = zeros(n, n);  % 生成矩阵存放预处理矩阵
for i = 1:n
    Minv(i, i) = 1 / A(i, i);
end

% PCG算法求解5维二次型
x = zeros(n, 1);  % 生成向量存放待求解
d = zeros(n, 1);  % 生成向量存放方向
r = b - A * x;  % 生成向量存放残差
z = Minv * r;
d = z;  % 深拷贝方向,其值不会随父对象变化
Tmax = 1000;  % 最大迭代次数

while true
    for t = 1:Tmax
        Ad = A * d;
        rz_old = r' * z;
        if abs(rz_old) < 1e-10
            break;
        end
        alpha = rz_old / (d' * Ad);
        x = x + alpha * d;
        r = r - alpha * Ad;
        z = Minv * r;
        beta = (r' * z) / rz_old;
        d = z + beta * d;
        % 计算迭代误差及其2范数
        error = abs(A * x - b);
        norm2 = norm(error, 2);
    end
    if mean(norm2) < exp(-6)  % error误差2范数的均值小于10^-6
        disp('误差:');
        disp(error);  % 打印误差
        disp('满足要求的迭代次数:');
        disp(t);  % 输出满足要求的迭代次数
        break;
    end
    break;
end