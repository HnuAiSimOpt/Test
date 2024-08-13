import numpy as np

def conjugate_gradient(A, b, x0, tol=1e-6, max_iter=None):
    if max_iter is None:
        max_iter = len(b)
    
    x = x0
    r = b - A @ x  # 初始残差
    d = r.copy()   # 初始搜索方向
    g = r.copy()   # 初始梯度

    for i in range(max_iter):
        Ad = A @ d
        alpha = r.T @ r / (d.T @ Ad)
        x = x + alpha * d  # 更新解
        r_new = r - alpha * Ad  # 更新残差
        
        if np.linalg.norm(r_new) < tol:  # 检查收敛性
            break
        
        beta = (r_new.T @ r_new) / (r.T @ r)
        d = r_new + beta * d  # 更新搜索方向
        
        r = r_new
        g = r_new  # 更新梯度
        
        # 验证关系
        for j in range(i):
            if not (np.allclose(d.T @ A @ d, 0, atol=tol) and 
                    np.allclose(g.T @ g, 0, atol=tol) and 
                    np.allclose(g.T @ d, -g.T @ g, atol=tol)):
                raise ValueError(f"Iteration {i}: Conditions not satisfied")

    return x

# 示例
A = np.array([[4, 1], [1, 3]])
b = np.array([1, 2])
x0 = np.zeros_like(b)

x = conjugate_gradient(A, b, x0)
print("Solution x:", x)