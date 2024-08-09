A = [4, 1; 1, 3];
b = [1; 2];
x0 = [2; 1];
tol = 1e-6;
max_iter = 1000;

[x, iter, history] = conjugate_gradient(A, b, x0, tol, max_iter);

figure;
plot(history(1, :), history(2, :), 'o-', 'LineWidth', 2);
hold on;
plot(x(1), x(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % Final point
title('Conjugate Gradient Method Convergence');
xlabel('x_1');
ylabel('x_2');
legend('Path', 'Optimal Solution');
grid on;
axis equal;

disp(['Solution: ', mat2str(x)]);
disp(['Iterations: ', num2str(iter)]);

function [x, k, history] = conjugate_gradient(A, b, x0, tol, max_iter)
    x = x0;
    r = A * x - b;
    p = -r;
    rs_old = r' * r;
    history = x; 
    
    for k = 1:max_iter
        Ap = A * p;
        alpha = rs_old / (p' * Ap);
        
        x = x + alpha * p;
        history = [history, x];  
        
        r = r + alpha * Ap;
        rs_new = r' * r;
        
        if sqrt(rs_new) < tol
            break;
        end
        
        p = -r + (rs_new / rs_old) * p;
        rs_old = rs_new;
    end
end


