function fun = fun(x)
    % 确保输入向量有足够的元素
    if length(x) < 5
        error('Input vector x must have exactly 5 elements.');
    end

    % 提取变量
    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    x5 = x(5);

    % 计算目标函数值
    fun = 9.449 * x2 - 1.832 * x1 + 11.69 * x3 + 10.636 * x4 + ...
          6.679 * x5 - 1.232 * x1 * x2 - 1.329 * x1 * x4 + ...
          1.106 * x2 * x3 - 0.914 * x1 * x5 - 1.313 * x2 * x5 - ...
          3.759 * x3 * x4 - 1.1978 * x3 * x5 + 1.225 * x1^2 - ...
          2.366 * x2^2 - 1.353 * x3^2 - 0.906 * x4^2 + 16.596;
end