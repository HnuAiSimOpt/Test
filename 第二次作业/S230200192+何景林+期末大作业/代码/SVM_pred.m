%SVM 预测
function Y_new = SVM_pred(X_new, X, Y,kernel,alpha,beta0)
% X 矩阵是 N*p
% X _ new 是 M * p 的新数据，alpha 是 N * 1的向量，beta0是标量

M = size(X_new,1);

switch kernel
    case 'linear'
        Ker=Ker_Linear(X,X_new);
    case 'ploynomial'
        Ker=Ker_Polynomial(X,X_new);
    case 'RBF'
        Ker=Ker_RBF(X,X_new);
    case 'Sigmoid'
        Ker=Ker_Sigmoid(X,X_new);
end

Y_new = sum(diag(alpha.*Y)*Ker,1)'+beta0*ones(M,1);

return