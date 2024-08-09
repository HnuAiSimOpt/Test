function [x] = PCG(n,A,b)
x=ones(n,1);
number=0;
r=zeros(n,1);
percon=zeros(n,1);
p=zeros(n,1);
d=zeros(n,1);
u=zeros(n,1);
xnew=zeros(n,1);
for i=1:1:n
    r(i)=b(i);
    for j=1:1:n
        r(i)=r(i)-A(i,j)*x(j);
    end
end
for i=1:1:n
    percon(i)=1/A(i,i);
    d(i)=percon(i)*r(i);
    p(i)=d(i);
end
while 1
    number=number+1;
    for i=1:1:n
        u(i)=0;
        for j=1:1:n
            u(i)=u(i)+A(i,j)*p(j);
        end
    end
    rkdk=0;
    ptap=0;
    for i=1:1:n
        rkdk=rkdk+r(i)*d(i);
        ptap=ptap+p(i)*u(i);
    end
    alp=rkdk/ptap;
    for i=1:1:n
        xnew(i)=x(i)+alp*p(i);
        r(i)=r(i)-alp*u(i);
        d(i)=percon(i)*r(i);
    end
    rk1dk1=0;
    for i=1:1:n
        rk1dk1=rk1dk1+r(i)*d(i);
    end
    bet=rk1dk1/rkdk;
    for i=1:1:n
        p(i)=d(i)+bet*p(i);
    end
    tol=0;
    for i=1:1:n
        tmp=abs(xnew(i)-x(i))/abs(xnew(i));
        tol=max(tol,tmp);
    end
    if tol<1e-6||number>100
        break;
    end
    for i=1:1:n
        x(i)=xnew(i);
    end
end
end