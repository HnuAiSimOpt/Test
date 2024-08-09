%*************************************************************
% ���ߣ��³�ѧ
% ������PCG�㷨
% �ο��ĵ���
% https://blog.genkun.me/post/cg-pcg-implementation/
% https://flat2010.github.io/2018/10/26/�����ݶȷ�ͨ�׽���/
% �㷨α����ο���https://www.cnblogs.com/lansebandaoti/p/10401758.html
%*************************************************************
function [x ,flag, relres, iter, resvect] = preconditioned_conjugate_gradient(A, b, M, tol, maxiter)
    % �ж��ṩ����
    if nargin < 5
        maxiter = 1000; % ���δ�ṩ������ֵ��Ĭ������������
    end
    if nargin < 4
        tol = 1e-9; % ���δ�ṩ������ֵ��Ĭ��������ֵ
    end
    if nargin < 3
        M = eye(size(A)); % ���δ�ṩԤ�������ʹ�õ�λ����
    end

    n = length(b);
    x = zeros(n, 1);  % ��ʼ������
    r = b - A * x;    
    z = M \ r;
    p = z;
    resvect = norm(r); % ��ʼ���в�����
    relres = resvect / norm(b); %��Բв�
    iter = 0;
    flag = 1; % ��ʼ��������Ϣ

    while relres > tol && iter < maxiter
        iter = iter + 1;
        Ap = A * p;
        alpha = (r' * z) / (p' * Ap);
        x = x + alpha * p;
        r_new = r - alpha * Ap;
        resvect = [resvect; norm(r_new)];
        relres = resvect(end) / norm(b);

        if relres < tol
            flag = 0; % �ɹ�����
            break;
        end

        z_new = M \ r_new;
        beta = (r_new' * z_new) / (r' * z);
        p = z_new + beta * p;
        r = r_new;
        z = z_new;
    end

    if iter == maxiter && relres > tol
        flag = 1; % ������������δ����
    end
end