function [x] = pcg(a,b,c,k)
num=length(b);
numk=0;
x=zeros(num,1);
d=zeros(num,1);
p=zeros(num,1);
xnew=zeros(num,1);
r=b-a*x;
dia=zeros(num,1);
for i=1:1:num
    dia(i)=a(i,i);
    d(i)=dia(i)*r(i);
    p(i)=d(i);
end
while 1
    numk=numk+1;
    u=a*p;
    rd=transpose(r)*d;
    pu=transpose(p)*u;
    alpha=rd/pu;
    for i=1:1:num
        xnew(i)=x(i)+alpha*p(i);
        r(i)=r(i)-alpha*u(i);
        d(i)=dia(i)*r(i);
    end
    rd1=transpose(r)*d;
    beta=rd1/rd;
    p=d+beta*p;
    tol=0;
    for i=1:1:num
        tmp=abs(xnew(i)-x(i))/abs(xnew(i));
        tol=max(tol,tmp);
    end
    if tol<c||numk>k
        break;
    end
    x=xnew;
end
end