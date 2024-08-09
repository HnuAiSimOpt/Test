function g=shuzhiweifenfa(x)
for i = 1:length(x)
    m=zeros(1,length(x));
    m(i)=(10^-6)/2;
    g(i)=f(x+m)-f(x-m);
end
g=g/10^-6;