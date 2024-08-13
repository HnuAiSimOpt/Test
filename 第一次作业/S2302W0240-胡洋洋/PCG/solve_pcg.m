function [x, k] = solve_pcg(A, b, M, k_max, epsilon)
n = size(A, 1);  
x = zeros(n, 1);  
k = 0;  
r = b - A * x;  %��ʼ�в� r?
M_inv = inv(M); 
p = zeros(n, 1);  %��ʼ�������������� p Ϊȫ������
rho_old = 0;  
%��ʼ����ѭ���������ǲв� r �ķ������� epsilon �� b �ķ����ĳ˻����ҵ�������С�� k_max��
while norm(r) > epsilon * norm(b) && k < k_max 
    z = M_inv * r;  %Ԥ�����в� z
    rho = r' * z;  %�в� r ��Ԥ�����в� z �ĵ��?
    k = k + 1;  
    if k == 1
        p = z;  %��һ�ε���ʱ��ֱ�ӽ� p ����Ϊ z
    else        %���򣬼��㲽�� beta��Ȼ������������� p
        beta = rho / rho_old;
        p = z + beta * p; 
    end
    w = A * p;  
    alpha = rho / (p' * w); 
    x = x + alpha * p; 
    r = r - alpha * w;  
    rho_old = rho;  
end
end