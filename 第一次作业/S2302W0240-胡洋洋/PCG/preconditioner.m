function M = preconditioner(A)
%Ԥ��������Ż������ٶ�
L=tril(A);
M=L*L';
end