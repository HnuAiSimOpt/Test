% this file is to solve the system of equations by CG methed

function output=conjugateGradient(A, b, x0, epsilon)  
    % A: 对称正定矩阵  
    % b: 右侧向量  
    % x0: 初始解向量  
    % epsilon,跳出循环的条件  
    % n: 自己设置的一个最大迭代次数   %n=(length(b))*10^3 
  
    % 初始化数值  
    n0=0; %用来计算迭代次数的  ，可以取大一点
    x=x0; % 初始解  
    r=b-A*x0 ; % 初始残差  
    p=r; % 初始搜索方向（共轭方向，也即是迭代搜索方向）  
    r_last=r'*r;  % 初始残差平方  
  
    % 共轭梯度法主循环  
   while 1
        n0=n0+1;
        alpha=r_last/(p'*A*p);    %步长
        x=x+alpha*p ;             % 更新解  
        r=r-alpha*A*p ;           % 更新残差  
        r_now=r'*r  ;             %更新残差平方

        %%%%%%计算下一步的搜索方向
        belta=r_now/r_last ;
        p=r+belta*p;              %下一步的搜索方向
        r_last=r_now;             %更新残差
        
        % 判断收敛条件  
        if r_last < epsilon   
            disp('迭代结束');  
            break ;  
        end  
   end
   output=x ; 
end
