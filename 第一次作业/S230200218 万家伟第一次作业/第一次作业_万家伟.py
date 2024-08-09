import numpy as np


def pcg(A, b, x, tol=1e-6, max_iter=1000):
    
    r = b - np.dot(A, x)
    dia = np.diagonal(A)  
    h = r.copy() / dia  
    p = h.copy()  
    x_new = x.copy()
    # print(diagonal)
    # 开始迭代
    number = 0
    for i in range(max_iter):
        number += 1
        alpha = np.dot(r, h) / np.dot(p, np.dot(A, p))  
        x_new = x + alpha * p  
        r_new = r - alpha * np.dot(A, p)  
        if np.linalg.norm(r_new) < tol: 
            break
        h_new = r_new.copy() / dia  
        beta = np.dot(r_new, h_new) / np.dot(h, r)  
        h = h_new.copy()  
        p = h + beta * p  
        r = r_new.copy()  
        x = x_new.copy() 

    print("迭代次数：%d" % number)
    return x_new


# 测试
A = np.array([[4,1], [1,3]])
b = np.array([1, 2])
x  = np.array([2, 1])
print(pcg(A,b,x))