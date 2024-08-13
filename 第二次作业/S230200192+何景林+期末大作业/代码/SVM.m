%SVM
function [alpha,Ker,beta0]=SVM(X,Y,kernel)
% X 矩阵是 N*p, Y 矩阵是 N*1,{-1,1}
% 常数 = 硬间隔的 Inf
global  precision Cost

switch kernel
    case 'linear'
        Ker=Ker_Linear(X,X);
    case 'ploynomial'
        Ker=Ker_Polynomial(X,X);
    case 'RBF'
        Ker=Ker_RBF(X,X);
    case 'Sigmoid'
        Ker=Ker_Sigmoid(X,X);
end

N= size(X,1);
% disp(size(diag(Y)))
% disp(size(Ker))
H= diag(Y)*Ker*diag(Y);
f= - ones(N,1);
Aeq=Y';
lb = zeros(N,1);
ub = repmat(Cost,N,1);
alpha0=0.01*ones(N,1);

%% Quadratic_PenalIy
% mu = 1; t = 2; tol = 10^(-14); maxIter = 1000;
% [alpha, fMin, t,nIter, infoAL_QP_bar] = Quadratic_Penalty(alpha0, mu, t, tol, maxIter,N,Aeq,lb,ub,H,f);

%% Augmented_Lagrangian
% mu = 10; nu= ones(2*N+1,1); tol = 10^(-16); maxIter = 1000;
% [alpha, fMin, nIter, infoAL_QP_bar] = Augmented_Lagrangian(alpha0, mu, nu, tol, maxIter,N,Aeq,lb,ub,H,f);

%% quadratic_programming
% A=[];
% b=[];
% beq=0;
% alpha=quadprog(H,f,A,b,Aeq,beq, lb, ub);

%% interiorPoint_Barrier
F.f =@(x) 0.5*x'*H*x + f'*x;
F.df =@(x) H*x+f; 
F.d2f =@(x) H;
phi.f = @(x) sum(log(x)) - sum(log( Cost * ones(size(x)) - x));
phi.df = @(x) -1 * (ones(size(x))./x + ones(size(x))./ (x - Cost * ones(size(x))));
phi.d2f = @(x)  diag(ones(size(x)) ./ (x.^2) ) + ( diag(ones(size(x)) ./ (x- Cost * ones(size(x)).^2)));

mu=1; t = 2; tol = 10^(-10); maxIter = 1000;
[alpha, fMin, t, nIter, infoAL_QP_bar] = interiorPoint_Barrier(F, phi, alpha0, t, mu, tol, maxIter);

%% figure
xs_history2 = infoAL_QP_bar.xs;
% disp(size(xs_history2))

dx = zeros(1,size(xs_history2,2));
for i = 1:size(xs_history2,2)
    dx(i) = norm(xs_history2(:,i)-xs_history2(:,end));
end

dx2 = zeros(1,size(xs_history2,2)-2);
for i = 1:(size(xs_history2,2)-2)
    dx2(i) = dx(i+1)/dx(i);
end
% 收敛速率绘图
figure
plot(1:size(xs_history2,2)-2, dx2, 'linewidth', 2)
xlabel('Iteration'); ylabel('Rate of Convergence')
set(gca,'FontSize',15)
% title('Method: Quadratic Penalty')
% title('Method: Augmented Lagrangian')
title('Method: IteriorPoint Barrier')
%% 

serial_num=(1:size(X,1))';
serial_sv=serial_num(alpha>precision&alpha<Cost);

temp_beta0=0;
for i=1:size(serial_sv,1)
    temp_beta0=temp_beta0+Y(serial_sv(i));
    temp_beta0=temp_beta0-sum(alpha(serial_sv(i))*...
        Y(serial_sv(i))*Ker(serial_sv,serial_sv(i)));
end
beta0=temp_beta0/size(serial_sv,1);

return