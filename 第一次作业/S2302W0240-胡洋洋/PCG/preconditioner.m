function M = preconditioner(A)
%预处理矩阵，优化收敛速度
L=tril(A);
M=L*L';
end