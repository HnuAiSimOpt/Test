"""
PCG 程序

S230200200
王 子 聪
"""

import numpy as np

def PCG(x,A,b,number,eps,P):
    """
    x为初值
    A为系数矩阵
    b为常数向量
    number为最大迭代次数
    eps为误差
    p为已知的一个对称正定的矩阵

    最终返回x的数值解
    """
    f_dot = b - np.dot(A,x)
    p_inv = np.linalg.inv(P)
    z = np.dot(p_inv, f_dot)
    f_get = np.linalg.norm(z,2)

    if f_get < eps:
        print(x)

    else:
        for m in range(number):
            rho = np.dot(f_dot.T, z)

            if m == 0:
                p = z
            elif m > 0:
                mju = rho / rho0
                p = z + np.dot(mju, p)

            q = np.dot(A,p)
            Xi = rho / np.dot(p.T,q)
            x = x + np.dot(Xi,p)
            f_dot = f_dot - np.dot(Xi,q)
            relres = np.linalg.norm(f_dot,2) / f_get

            if relres < eps:
                break
            else:
                z = np.dot(np.linalg.inv(P),f_dot)
                rho0 = rho

        if relres < eps:
            return x
        else:
            raise TypeError
