clear
n1 = 7;
A = toeplitz([2.5,-1,zeros(1,n1-3),1]);
b = [1; zeros(n1-1,1)];
x = A \ b; %求解Ax=B作为参考解
%初始化
x0 = zeros(n1,1);
r0 = b - A*x0;
k = 0; %迭代次数
epn = norm(r0,inf); %初始残差范数
maxI = 1000;  %最大迭代次数
Tol = 1e-6; %收敛容差
M = eye(size(A)); %预处理

tic; %开始计时

while k < maxI && epn > Tol
        P0 = M\r0;
        alp = (r0.'*P0)/(P0.'*A*P0); %步长
        x1 = x0 + alp*P0; %更新解
        r1 = r0 - alp*A*P0; %更新残差
        epn = norm(r1,inf); %当前残差范数
        if epn < Tol
            break;
        end
        bet = (r1.'*P0)./(r0.'*A*P0);
        P1 = r1 + bet*M\r0;
        x0 = x1; k = k + 1;  r0 = r1;
end
toc;
x
fprintf('\n itr stoped at step %d and Tol = %8.4e\n',k,Tol)