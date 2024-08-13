import numpy as np

def diagonal_matrix(n1, n2, n3, n):
    """
    矩阵生成
    :param n1:对角线下
    :param n2:对角线
    :param n3:对角线上
    :param n:维度
    :return:生成对称矩阵
    """
    array_a = np.diag([n1] * (n - 1), -1)
    l = range(n2+1)
    l = l[1::]
    array_b = np.diag(l)
    array_c = np.diag([n3] * (n - 1), 1)
    matrix_A = array_a + array_b + array_c
    return matrix_A

def PCG(x,A,b,Max,error,P):
    r = b - np.dot(A,x) # x:初值, xA = b
    z = np.dot(np.linalg.inv(P),r) # P:预处理矩阵，对称正定
    beta = np.linalg.norm(z,2)
    if beta < error:
        print(x)
    else:
        for m in range(Max):
            c = np.dot(r.T, z)
            if m == 0:
                p = z
                cc = c
            elif m > 0:
                mju = c / cc
                p = z + np.dot(mju,p)
            q = np.dot(A,p)
            Xi = c / np.dot(p.T,q)
            x = x + np.dot(Xi,p)
            r = r - np.dot(Xi,q)
            relres = np.linalg.norm(r,2) / beta
            print(relres)
            if relres < error:
                break
            else:
                z = np.dot(np.linalg.inv(P),r)
                cc = c
        if relres < error:
            return x
        else:
            return 0


A = diagonal_matrix( -1,100,-1,100)
# A = np.random.rand(100,100)
b = np.dot(A,np.ones(100))
Max = 30
error = 1e-8
x = np.zeros(100, dtype = float)
a = range(1,101)
P = np.diag(a)
y = PCG(x,A,b,Max,error,P)
print(A)
print(b)
print(y)