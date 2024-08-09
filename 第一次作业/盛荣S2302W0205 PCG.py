import numpy as np

def jacobi_prec(A):
    D = np.diag(A)
    invD = np.diag(1 / D)
    return invD

def pcg(A, b, x0, tol=1e-8, maxiter=1000):
    r = b - np.dot(A, x0)
    p = r.copy()
    r0 = np.linalg.norm(r)
    if r0 == 0:
        return x0, 0

    preconditioner = jacobi_prec(A)
    alpha, beta = 1.0, 0.0
    x = x0.copy()
    for k in range(maxiter):
        Ap = np.dot(A, p)
        alpha = r.dot(r) / p.dot(Ap)
        x += alpha * p
        r -= alpha * Ap
        new_rnorm = np.linalg.norm(r)

        if new_rnorm < tol:
            break

        beta = new_rnorm / r0
        p = preconditioner @ r + beta * p
        r0 = new_rnorm

    return x, k+1

# 假设我们有一个简单的2x2矩阵A和向量b
A = np.array([[4, 1], [1, 3]])
b = np.array([5, 2])
x0 = np.zeros_like(b)

x, num_iterations = pcg(A, b, x0)
print("Solution: ", x)
print("Number of iterations: ", num_iterations)
