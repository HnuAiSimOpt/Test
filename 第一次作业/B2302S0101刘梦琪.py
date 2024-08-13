import numpy as np

def pcg(A, b, M=None, tol=1e-8, max_iter=None):

    n = len(b)
    if max_iter is None:
        max_iter = n

    # 初始化
    x = np.zeros(n)
    r = b - A.dot(x)

    if M is None:
        z = r
    else:
        z = np.linalg.solve(M, r)

    p = z
    rs_old = np.dot(r, z)

    for i in range(max_iter):
        Ap = A.dot(p)
        alpha = rs_old / np.dot(p, Ap)
        x += alpha * p
        r -= alpha * Ap

        if np.linalg.norm(r) < tol:
            return x, 0  # 成功收敛

        if M is None:
            z = r
        else:
            z = np.linalg.solve(M, r)

        rs_new = np.dot(r, z)
        p = z + (rs_new / rs_old) * p
        rs_old = rs_new

    return x, 1  # 未达到收敛

# 示例用法
if __name__ == "__main__":
    # 创建一个对称正定矩阵 A 和向量 b
    A = np.array([[4, 1], [1, 3]])
    b = np.array([1, 2])

    # 调用 PCG 算法
    x, info = pcg(A, b, tol=1e-8)

    print("Solution x:", x)
    print("Info:", "Converged" if info == 0 else "Not Converged")
