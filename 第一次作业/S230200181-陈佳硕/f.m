%Ä¿±êº¯Êý
function y=f(x)
if(length(x)==1)
    global xk;
    global pk;
    x=xk+x*pk;
end
y=100*(x(2)-x(1)^2)^2+(1-x(1))^2;