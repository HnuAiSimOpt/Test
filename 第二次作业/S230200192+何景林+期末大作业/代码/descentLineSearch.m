function [xMin, fMin, nIter, info] = descentLineSearch(F, descent, ls, alpha0, x0, tol, maxIter)
stopType = 'step';

% 初始化
nIter = 0;
x_k = x0;
info.xs = x0;
info.alphas = alpha0;
stopCond = false; 

% 循环直到收敛或最大迭代次数
while (~stopCond && nIter <= maxIter)
     
   if descent == "steepest"
       dx_k = F.df(x_k); 
        p_k = -dx_k;
       [alpha1, ~] = ls(x_k, p_k, alpha0);
        x_k_1=x_k;
        x_k=x_k_1 + alpha1*p_k;
        nIter = nIter +1;
        info.xs = [info.xs x_k];
        info.alphas = [info.alphas alpha1];

   end
   if descent == "newton"
        dx_k = F.df(x_k);
        Hx_k = F.d2f(x_k);
        p_k = -inv(Hx_k)* dx_k;
       [alpha1, ~] = ls(x_k, p_k, alpha0);
        x_k_1=x_k;
        x_k=x_k_1 + alpha1*p_k;
        nIter = nIter +1;
        info.xs = [info.xs x_k];
        info.alphas = [info.alphas alpha1];
   end

    switch stopType
      case 'step' 
      
        normStep = norm(x_k - x_k_1)/norm(x_k_1);
        stopCond = (normStep < tol);
      case 'grad'
        stopCond = (norm(F.df(x_k), 'inf') < tol*(1 + tol*abs(F.f(x_k))));
    end
    
end

% 赋值
xMin = x_k;
fMin = F.f(x_k); 

end


