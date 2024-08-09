import numpy as np

def gongetidufa(A, b, x0):
    r = b - np.dot(A, x0)
    p = r
    rold = np.dot(np.transpose(r), r)

    for i in range(len(b)):
        Ap = np.dot(A, p)
        alpha = rold / np.dot(np.transpose(p), Ap)
        x0 = x0 + alpha * p
        r = r - alpha * Ap
        rnew = np.dot(np.transpose(r), r)
        if np.sqrt(rnew) < 1e-10:
            break
        p = r + (rnew/rold)*p
        rold = rnew
    return x0

A = np.array([[4, 1], [1, 3]])
b = np.array([1, 2])
x0 = np.array([2, 1])

print(gongetidufa(A, b, x0))