import numpy as np


def cg(a, b, tol=1e-10, max_i=1000):
    n = b.shape[0]
    x = np.zeros_like(b)
    r = b - np.dot(a, x)
    p = r.copy()
    rs_norm = [np.linalg.norm(r)]

    for i in range(max_i):
        ap = np.dot(a, p)
        alpha = np.dot(r, r) / np.dot(p, ap)
        x = x + alpha * p
        r_new = r - alpha * ap

        if np.linalg.norm(r_new) < tol:
            print(f"在第 {i + 1} 次迭代收敛")
            return x

        beta = np.dot(r_new, r_new) / np.dot(r, r)
        p_new = r_new + beta * p
        r = r_new
        p = p_new
        rs_norm.append(np.linalg.norm(r))

    print(f"第 {max_iter} 次迭代后仍未收敛")
    return x


a = np.array([[4, 1], [1, 3]])
b = np.array([1, 2])

x_cg = cg(a, b)
print("解为", x_cg)

x_exact = np.linalg.solve(a, b)
print("理论解为", x_exact)
