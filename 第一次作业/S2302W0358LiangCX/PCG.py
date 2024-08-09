import numpy as np
def pcg(A, b, x0, t=1e-12, max_diedai=1000):
    #A-----------正定对称的系数矩阵
    #b-----------常数向量
    #x0----------初始解向量
    #t-----------误差限
    #max_diedai--最大迭代次数

    n= len(b)                 #由常数向量b的数据确定n阶
    x= x0                     #初始化变量
    r= b - np.dot(A, x)       #r=b-Ax,向量残差值
    z= r.copy()               #中间变量z，方便调用
    p= z.copy()               #r=p,由r赋值p
    ro= np.dot(r, z)          #rz，点积，后续取步长
    ro0= ro                   #中间变量，保存点积
    
    for i in range(max_diedai):              #由1运行到最大迭代次数停止
        if np.linalg.norm(r) < t:            #判断r是否符合误差限，是则返回初值x0，否则则进行迭代
            return x
        
        q= np.dot(A, p)                      #A pk              
        al= ro / np.dot(p, q)               #计算步长
        x= x + al * p                        #xk+1:=xk+al pk
        r= r - al* q                         #rk+1:=rk-al A pk
        ro_new = np.dot(r, z)               #rk+1 z，点积，后续取步长
        
        if np.abs(ro_new) < t:              #panduan
            return x
        
        beta= ro_new / ro0                 #重新计算步长
        p= z + beta * p
        z= r + beta * q
        ro0 = ro_new
    
    return x


A = np.array([                     #自定义3x3的对称正定矩阵A
    [4, 2, -2],
    [2, 2, -3],
    [-2, -3, 14]
])
b = np.array([10, 5, 4])           #确定常数向量b
x0 = np.zeros(3)                   #确定初始解向量x0
x = pcg(A, b, x0, t=1e-5)          #调用PCG算法
print("向量解:", x)