import numpy as np
import random
import math
import matplotlib.pyplot as plt
from scipy.stats import qmc


def random_point(car_num, radius):
    for i in range(1, car_num + 1):
        theta = random.random() * 2 * np.pi
        r = random.uniform(10, 30)
        x = math.cos(theta) * (r ** 0.5)
        y = math.sin(theta) * (r ** 0.5)
        plt.plot(x, y, '*', color="blue")


def sd():  # 求解域撒点
    # 拟蒙特卡洛
    sampler = qmc.Halton(d=2, scramble=True)
    random = sampler.random
    xy = np.array(random(5000)) * 40 - 20
    r = xy[:, 0] ** 2 + xy[:, 1] ** 2
    r = r >= 25
    xy = xy[r, :]
    return xy


def sdb():  # 外力边界撒点
    sampler = qmc.Halton(d=1, scramble=True)
    random = sampler.random
    y = np.array(random(200)) * 40. - 20.
    x = np.ones_like(y) * 20.
    xy = np.concatenate([x, y], axis=1)
    return xy


def main():
    xy = sd()
    plt.plot(xy[:, 0], xy[:, 1], 'o', markersize=1, color="black")
    xyb = sdb()
    plt.plot(xyb[:, 0], xyb[:, 1], 'o', markersize=4, color="red")
    plt.xticks(ticks=[-20, -10, 0, 10, 20], fontsize=22)
    plt.yticks(ticks=[-20, -10, 0, 10, 20], fontsize=22)
    plt.show()


if __name__ == "__main__":
    main()

