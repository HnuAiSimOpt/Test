import numpy as np
def CG(A,b):
    n = b.shape[0]
    xs = []
    rs = []
    ps = []
    alphas = []
    x0 = np.array([2,1])
    # x0 = np.random.rand(n)
    xs.append(x0)

    r0 = b - np.dot(A,x0)
    rs.append(r0)

    p0 = r0
    ps.append(p0)

    alpha0 = p0.dot(p0)/p0.dot(A).dot(p0)
    alphas.append(alpha0)
    print(rs)
    print(alphas)
    print(ps)
    for i in range(n):
        r = rs[i] - alphas[i] * A.dot(ps[i])
        rs.append(r)
        beta = np.dot(r,r)/(rs[i].dot(rs[i]))

        alpha = ps[i].dot(rs[i])/(ps[i]).dot(A).dot(ps[i])
        alphas.append(alpha)

        x = xs[i] + alpha * ps[i]
        xs.append(x)

        p = r + beta * ps[i]
        ps.append(p)

    return xs

A = np.array([[4,1],[1,3]])
b = np.array([1,2])
c1 = np.linalg.inv(A).dot(b)
print("the math sol is",c1)
c2 = CG(A,b)
print("the numerical sol is",c2)

