clear all;
clc;
G=hilb(40); 
b=sum(G, 2); 
x0=zeros(40, 1); % ��ʼ������ѡΪ0
kmax=1000; % ����������
eps=1e-6; % ����
    gk = G * x0 + b; % x0 �����������κ����ݶ�ֵ
    dk = -gk; % ��ʼ�½�����
    xk = x0;
    k = 0;
    while k <= kmax
        if norm(gk) < eps
            break
        end
        gk_ = gk; % ����ǰ���ݶ�ֵ
        gk = G * xk + b; % ��������ݶ�ֵ
        dk_ = dk; % ��һ��ѡȡ���½�����
        if k == 0
            dk = -gk; % ��ʼ����½�����Ϊ���ݶȷ���
        else
            beta = (gk' * gk) / (gk_' * gk_);
            dk = -gk + beta * dk_; % �����ݶȷ���������
        end
        % �������κ���������ʽ
        alpha = (gk' * gk) / (dk' * G * dk);
        xk = xk + alpha * dk; % ���µ�����
        k = k + 1;
    end
    x = xk;
    disp(x);
    disp(k);
    %S2302W0278-��֮�

