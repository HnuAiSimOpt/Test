% B2302S0106 ��Զ
clear all; close all; clc;
%% ������
% �����������ο�matlab�ٷ��ĵ���
A = sprand(100,100,0.8);
A = A'*A;
b = sum(A,2);
% ��⣬����ٷ�����pcg()�Ƚ�
disp("-----------MATLAB�ٷ����������--------");
x_matlab = pcg(A, b);
disp("---------------����Ϊ�ҵķ���------------");
x_my = pcg_algorithm(A, b);

%% PCG�㷨����
function x = pcg_algorithm(A, b)
    % Ԥ��׼��
    eps = 1e-5; % �������ã��ɵ�
    n = length(A);
    M = M_generate(A);
    invM = inv(M);
    x = zeros(n,1);
    r = b - A * x;
    z = invM * r;
    p = z;
    iter = 0;
    % ѭ������
    while true
        iter = iter + 1;
        z_last = z;
        r_last = r;
        alpha = (r' * z) / (p' * A * p);
        x = x + alpha * p;
        r = r - alpha * A * p;
        if sqrt(r'*r) < eps * norm(b)
            break;
        end
        z = invM * r;
        beta = (z' * r) / (z_last' * r_last);
        p = z + beta * p;
    end
    fprintf('��������Ϊ %d\n', iter);
    fprintf('��Բв�Ϊ %.10f\n', sqrt(r'*r)/norm(b));
end

%% M�������ɺ��� 
function M = M_generate(A)
    % �Խ�Ԥ�ž��󷽷�
    n = length(A);
    for i = 1 : n
        M(i,i) = A(i,i);
    end
    % ����ȫCholesky���ӷ���
%     n = length(A);
%     for k = 1:n
%         A(k,k) = sqrt(A(k,k));
%         for i = (k + 1):n
%             if A(i,k) ~= 0
%                 A(i,k) = A(i,k) / A(k,k);
%             end
%         end
%         for j = (k+1) : n
%             for i = j : n
%                 if A(i,j) ~= 0
%                     A(i,j) = A(i,j) - A(i,k) * A(j,k);
%                 end
%             end
%         end
%     end
%     M = tril(A);
end

