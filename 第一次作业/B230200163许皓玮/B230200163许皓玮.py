import numpy as np

def conjugate_grad(A, b, maxiter = 5):
    n = A.shape[0]
    x = np.zeros(n)
    r = b - A @ x
    q = r.copy()
    r_old = np.inner(r, r)
    for it in range(maxiter):
        alpha = r_old / np.inner(q, A @ q)
        x += alpha * q
        r -= alpha * A @ q
        r_new = np.inner(r, r)
        if np.sqrt(r_new) < 1e-10:
            break
        beta = r_new / r_old
        q = r + beta * q
        r_old = r_new.copy()
    return x

A = np.array([[4, 1], [1, 3]])
b = np.array([1, 2])
x = conjugate_grad(A, b)
print(x)