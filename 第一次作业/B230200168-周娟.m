% �������Խ�Ԫ��Ϊn�ĶԳ���
n = 5;  % �趨����ά��
A = zeros(n, n);  % ���ɾ�����A
b = zeros(n, 1);  % �����������b

% ������A������b
for i = 1:n
    A(i, i) = n;  % �����A�ĶԽ�Ԫ��Ϊ5
    b(i) = rand();  % �������0~1�ĸ�������Ϊ������
    for j = i+1:n
        A(i, j) = rand();  % �������0~1�ĸ�������Ϊ����A�ĵ�i��j��Ԫ��
        A(j, i) = A(i, j);  % ���ɾ���A�ĶԳ�Ԫ��
    end
end

% ����JacobiԤ�������,��ΪA�ĶԽǵ������
Minv = zeros(n, n);  % ���ɾ�����Ԥ�������
for i = 1:n
    Minv(i, i) = 1 / A(i, i);
end

% PCG�㷨���5ά������
x = zeros(n, 1);  % ����������Ŵ����
d = zeros(n, 1);  % ����������ŷ���
r = b - A * x;  % ����������Ųв�
z = Minv * r;
d = z;  % �������,��ֵ�����游����仯
Tmax = 1000;  % ����������

while true
    for t = 1:Tmax
        Ad = A * d;
        rz_old = r' * z;
        if abs(rz_old) < 1e-10
            break;
        end
        alpha = rz_old / (d' * Ad);
        x = x + alpha * d;
        r = r - alpha * Ad;
        z = Minv * r;
        beta = (r' * z) / rz_old;
        d = z + beta * d;
        % �����������2����
        error = abs(A * x - b);
        norm2 = norm(error, 2);
    end
    if mean(norm2) < exp(-6)  % error���2�����ľ�ֵС��10^-6
        disp('���:');
        disp(error);  % ��ӡ���
        disp('����Ҫ��ĵ�������:');
        disp(t);  % �������Ҫ��ĵ�������
        break;
    end
    break;
end