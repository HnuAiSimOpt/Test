%PCG
clc;
clear;
A0 = rand(3, 3);
A1 = A0 * A0';
A = A1 + eye(3);
b = rand(3, 1); 

bSize=size(b);
cx = zeros(bSize(1), 1); 
tol = 1e-5; 
max_i = 10000; 
r = b-A * cx;
  
p = r; 
for i = 1:max_i
    Ap = A * p;
    alpha = (r' * r) / (p' * Ap);
    cx = cx + alpha * p;
    r = r - alpha * Ap;
    beta = dot(r, r) / (p' * Ap);
    p = r + beta * p;

    if norm(r) < tol
        break;
    end
end

disp('解cx:');
disp(cx);
disp(['迭代次数: ', num2str(i)]);

