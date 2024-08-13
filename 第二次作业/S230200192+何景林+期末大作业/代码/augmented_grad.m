function temp_fi_grad= augmented_grad(nu,mu,x,N,lb,ub)

  
temp_fi_grad1=zeros(N,1);
temp_fi_grad2=zeros(N,1);
%lb-x <=0
for i=1:N
    if (lb(i)-x(i))<=0
        temp_fi_grad1(i)= (nu(i+1)+mu*(lb(i)-x(i)))*(0);
    else
        temp_fi_grad1(i)= (nu(i+1)+mu*(lb(i)-x(i)))*(-1);
    end
end
    
%x-ub <=0
for i=1:N
    if (x(i)-ub(i))<=0
        temp_fi_grad2(i)= (nu(N+i+1)+mu*(x(i)-ub(i)))*(0);
    else
        temp_fi_grad2(i)= (nu(N+i+1)+mu*(x(i)-ub(i)))*(1);
    end
end
temp_fi_grad = temp_fi_grad2+temp_fi_grad1;
end
