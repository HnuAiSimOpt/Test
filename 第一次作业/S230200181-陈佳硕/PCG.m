%共轭梯度法示例
%求解目标函数：min y=100*(x2-x2)^2+(1-x1^2)
clc;clear;
e=0.001;%精度
x=[-1,1];%初始点
global xk
global pk
%step 1
g0=shuzhiweifenfa(x);
pk=-g0;
%没用到k，只存储当前迭代的值。
xk=x;
while 1
    %step 2
    %一维搜索求ak
    %这两个函数见之前代码（matlab无约束最优化的一般算法）
    [a,b,c]=jintuifa(0,0.1);
    a=huangjinfenge(a,c,10^-4);
    %step 3
    xk=xk+a*pk;
    g1=shuzhiweifenfa(xk);
    %step 4
    %范数用的是平方和开根号
    if sqrt(sum(g1.^2))<=e
        break;
    end
    %step 5
    b=(g1*g1')/(g0*g0');
    pk=-g1+b*pk;
    %step 6
    %没用到k，只存储当前迭代的值。
    g0=g1;
end
fprintf('x*=%f\t%f\n',xk(1),xk(2));
fprintf('f(x)=%f\n',f(xk));