n=10;
x0=rand(n,1);%initial point
A = sprand(n,n,0.8);% 随机生成A矩阵
A = A + A'; % 确保对称性
A = A + diag(sum(abs(A),2) + 1);% 确保对角线占优，从而保证正定性
b = rand(n,1);%随机生成b
v=diag(A);
M=diag(v);%diag mat

r0=b-A*x0;
r=r0;
z0=(M^-1)*r0;
z=z0;
p0=z0;
p=p0;
tol=1e-6;%tolerance
k=0;
x=x0;
for i=0:10
    norm(r)
    if norm(r)<=tol 
        disp(['best value:',mat2str(x),'iter:',num2str(i)])
        break
    end  
        alpha=(r'*z)/(p'*A*p);
        xi=x;ri=r;pi=p;zi=z;
        x=xi+alpha*pi;
        r=ri-alpha*A*pi;
        z=(M^-1)*r;
        beta=(z'*r)/(zi'*ri);%
        p=z+beta*pi;  
end