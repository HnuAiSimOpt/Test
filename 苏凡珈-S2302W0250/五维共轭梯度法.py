import numpy as np
import matplotlib.pyplot as plt

# 生成数据
n = 100
m = 10
X = np.random.rand(n, m)
y = np.random.rand(n, 1)

# 初始化参数
theta = np.random.rand(m, 1)

# 定义梯度函数
def gradient(theta, X, y):
    n = X.shape[0]
    diff = np.dot(X, theta) - y
    return np.dot(X.T, diff) / n

# 定义目标函数
def cost(theta, X, y):
    n = X.shape[0]
    diff = np.dot(X, theta) - y
    return np.sum(diff ** 2) / (2 * n)

# 五维共轭梯度法求解
max_iter = 100
tol = 1e-6
alpha = 0.01
r = -gradient(theta, X, y)
p = r
for i in range(max_iter):
    alpha = np.dot(r.T, r) / np.dot(p.T, np.dot(X.T, np.dot(X, p)))
    theta_new = theta + alpha * p
    r_new = r + alpha * np.dot(X.T, np.dot(X, p))
    beta = np.dot(r_new.T, r_new) / np.dot(r.T, r)
    p_new = r_new + beta * p
    if np.linalg.norm(theta_new - theta) < tol:
        break
    theta = theta_new
    r = r_new
    p = p_new

print("Final theta:", theta)
#绘制拟合曲线
x_plot = np.linspace(0, 1, n)
y_plot = np.dot(X, theta)
plt.scatter(x_plot, y)
plt.plot(x_plot, y_plot, color='r')
plt.title('Linear Regression with Conjugate Gradient Method')
plt.xlabel('X')
plt.ylabel('Y')
plt.show()