%�����ݶȷ�ʾ��
%���Ŀ�꺯����min y=100*(x2-x2)^2+(1-x1^2)
clc;clear;
e=0.001;%����
x=[-1,1];%��ʼ��
global xk
global pk
%step 1
g0=shuzhiweifenfa(x);
pk=-g0;
%û�õ�k��ֻ�洢��ǰ������ֵ��
xk=x;
while 1
    %step 2
    %һά������ak
    %������������֮ǰ���루matlab��Լ�����Ż���һ���㷨��
    [a,b,c]=jintuifa(0,0.1);
    a=huangjinfenge(a,c,10^-4);
    %step 3
    xk=xk+a*pk;
    g1=shuzhiweifenfa(xk);
    %step 4
    %�����õ���ƽ���Ϳ�����
    if sqrt(sum(g1.^2))<=e
        break;
    end
    %step 5
    b=(g1*g1')/(g0*g0');
    pk=-g1+b*pk;
    %step 6
    %û�õ�k��ֻ�洢��ǰ������ֵ��
    g0=g1;
end
fprintf('x*=%f\t%f\n',xk(1),xk(2));
fprintf('f(x)=%f\n',f(xk));