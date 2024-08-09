import numpy as np

#设置待优化函数Ax=b
A = np.array([[4, 1], [1, 3]])
b = np.array([1, 2])
x0 = np.array([2, 1])

#设置参数
tolerance = 1e-5
maxiter = 500

def PCG(A, b):

    M = np.diag(np.diag(A))
    M_inv = np.linalg.inv(M)

    x = x0
    r = b - A @ x
    z = M_inv @ r
    p = z.copy()
    rs_old = np.dot(r, z)

    for i in range(maxiter):
        Ap = A @ p
        alpha = rs_old / np.dot(p, Ap)
        x = x + alpha * p
        r = r - alpha * Ap
        z = M_inv @ r
        rs_new = np.dot(r, z)

        if np.sqrt(rs_new) < tolerance:
            break

        p = z + (rs_new / rs_old) * p
        rs_old = rs_new

    return x

x = PCG(A, b)
print("PCG RESULT:", x)
