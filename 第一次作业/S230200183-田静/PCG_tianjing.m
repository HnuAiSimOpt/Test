clear
clc
% 求解方程组A*x=b;
% 其中A为对称正定矩阵；b为列向量；  
A = [4 12 -16; 12 37 -43; -16 -43 98];  
b = [6; 25; -111];    
x0 = zeros(size(b));%初始解向量 
D = diag(diag(A));
P = inv(D);%预处理矩阵    
loop = 100;%设置最大迭代次数
tol = 1e-4;%设置收敛容差    
x = PCG( tol, loop,A, b, x0, P);% 调用PCG求解     
disp(x) % 求解  
function x = PCG(tol, loop,A, b, x0, P)  
    x = x0;  
    r = b - A * x; % 残差  
    z = P \ r; % 对残差进行预处理  
    p = z; % 初始搜索方向  
    rzd = r' * z; % 初始残差与预处理后残差的点积   
    for k = 1:loop  
        Ap = A * p;  
        alpha = rzd / (p' * Ap);  
        x = x + alpha * p;  
        r = r - alpha * Ap;% 检查收敛性  
        if abs(r) < tol  
             disp(x)
            break;  
        end  
        % 更新预处理后的残差  
        z = P \ r;  
        % 计算新的搜索方向  
        rzdnew = r' * z;  
        beta = rzdnew / rzd;  
        p = z + beta * p;  
        % 更新残差与预处理后残差的点积  
        rzd = rzdnew;  
    end  
end