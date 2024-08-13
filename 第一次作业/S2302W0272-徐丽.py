import numpy as np
from scipy.sparse.linalg import spsolve

def pcg(A, b, M, x0, tol=1e-10, max_iter=None): 
    n = len(b) 
    if max_iter is None: 
        max_iter = n 
    x = x0 
    r = b - np.dot(A, x) 
    z = spsolve(M, r)  # Preconditioning step 
    p = z 
    rs_old = np.dot(r, z) 
    for i in range(max_iter):
        Ap = np.dot(A, p) 
        alpha = rs_old / np.dot(p, Ap) 
        x = x + alpha * p 
        r = r - alpha * Ap 
        z = spsolve(M, r) # Preconditioning step 
        rs_new = np.dot(r, z) 
        if np.sqrt(rs_new) < tol: 
            break 
    beta = rs_new / rs_old 
    p = z + beta * p 
    rs_old = rs_new 
    return x 
# Example usage: 
A = np.array([[4, 1], [1, 3]]) 
b = np.array([1, 2]) 
M = np.diag([4, 3]) # Preconditioner (diagonal matrix approximation of A) 
x0 = np.array([0, 0]) # Initial guess 
solution = pcg(A, b, M, x0) 
print("Numerical solution:", solution)

