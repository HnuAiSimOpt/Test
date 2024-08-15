function y = rastriginsfcn(x)
    % Rastrigin's function
    A = 10;
    n = numel(x);
    y = A * n + sum(x.^2 - A * cos(2 * pi * x));
end