import numpy as np
from scipy.special import comb
from itertools import combinations
import torch, copy, math
import yaml
from scipy.stats.qmc import Sobol

class CreateInput():
    def generate_multiple_inputs(self, group, num):
        """
        将输入分成设计变量和非设计变量
        设计变量遵循随机分布，非设计变量遵循正态分布
        """
        
        # 设计变量部分
        design_variables = group[:, :5]
        lower_d, step_d, upper_d, length_d = torch.chunk(design_variables, 4, dim=0)

        # 检查步长是否为正数
        if torch.any(step_d <= 0):
            raise ValueError("Step values must be greater than zero")

        # 生成随机输入
        inputs_d = lower_d + step_d * torch.floor(torch.rand(num, lower_d.shape[1], dtype=torch.float32) * length_d)
        # 确保输入在 lower_d 和 upper_d 之间
        inputs_d = torch.clamp(inputs_d, lower_d, upper_d)

        # 正态分布部分
        normal_variables = group[:, 5:]
        lower_n, step_n, upper_n, length_n = torch.chunk(normal_variables, 4, dim=0)

        # 计算均值和标准差
        mean_n = (upper_n + lower_n) / 2
        std_n = (upper_n - lower_n) / 4  # 假设4个标准差覆盖整个范围

        # 生成正态分布随机数
        inputs_n = torch.randn(num, lower_n.shape[1], dtype=torch.float32) * std_n + mean_n
        # 确保正态分布随机数在 lower_n 和 upper_n 之间
        inputs_n = torch.clamp(inputs_n, lower_n, upper_n)

        # 合并设计变量和正态分布变量
        inputs = torch.cat((inputs_d, inputs_n), dim=1)
        return inputs

def mutate_extra(population, lower_bound, upper_bound, step, mutation_rate):
    mutation_mask = np.random.rand(*population.shape) < mutation_rate
    random_values = lower_bound + step * np.floor(np.random.rand(*population.shape) * (upper_bound - lower_bound) / step)
    population[mutation_mask] = random_values[mutation_mask]
    return population

def shuffle_genetic_parameters(pop, seed=None):
    """
    将种群中的设计变量和非设计变量打乱重组。

    参数:
    pop (np.ndarray): 包含所有变量的种群数组，每行表示一个个体，前五列为设计变量，后三列为非设计变量
    seed (int, optional): 随机数种子，用于重现结果

    返回:
    np.ndarray: 打乱重组后的种群数组
    """
    if seed is not None:
        np.random.seed(seed)
    
    # 提取设计变量和非设计变量
    design_variables = pop[:, :5]
    non_design_variables = pop[:, 5:]
    
    # 打乱设计变量
    shuffled_design_variables = np.apply_along_axis(np.random.permutation, 1, design_variables)
    
    # 使用索贝尔序列生成扰动值
    num_individuals = non_design_variables.shape[0]
    sobol_engine = Sobol(d=non_design_variables.shape[1], scramble=True, seed=seed)
    sobol_sequence = sobol_engine.random(num_individuals)
    
    # 对非设计变量进行小范围扰动
    perturbation = 0.01  # 扰动幅度，可以根据需要调整
    transformed_non_design_variables = non_design_variables * (1 + perturbation * (sobol_sequence - 0.5))
    
    # 合并设计变量和非设计变量
    combined_variables = np.hstack((shuffled_design_variables, transformed_non_design_variables))
    
    return combined_variables

# 加载配置
def load_config(config_file):
    with open(config_file, 'r') as file:
        config = yaml.safe_load(file)
    return config

# 计算目标值
def compute_objective_values(num_y, model, scaler_input, scaler_output, input_data, samples):
    try:
        input_data_scaled = torch.tensor(scaler_input.transform(input_data), dtype=torch.float32)
        output_samples = np.zeros((samples, len(input_data), num_y))

        for s in range(samples):
            output_tmp = model(input_data_scaled).detach().numpy()
            output_tmp = scaler_output.inverse_transform(output_tmp)
            output_tmp[:, 0:2] = 10 ** output_tmp[:, 0:2]
            output_samples[s] = output_tmp

        output_mean = np.mean(output_samples, axis=0)
        output_std = np.std(output_samples, axis=0)

        # 手动计算每列的最大值
        max_output_mean = [max(output_mean[:, i]) for i in range(output_mean.shape[1])]
        max_output_std = [max(output_std[:, i]) for i in range(output_std.shape[1])]
        norm_mean = output_mean / max_output_mean
        norm_std = output_std / max_output_std

        objective_values = 0.5 * norm_mean + 0.5 * norm_std
        output_combined = torch.cat([torch.tensor(output_mean, dtype=torch.float32), torch.tensor(output_std, dtype=torch.float32)], axis=1)
        output_penalty = torch.tensor(objective_values, dtype=torch.float32)

        return output_combined, output_penalty, output_samples
    except Exception as e:
        print(f"Error in compute_objective_values: {e}")
        return None, None

# 计算两组点之间的距离
def pdist(x, y):
    try:
        x0, y0 = x.shape[0], y.shape[0]
        xmy = np.dot(x, y.T)
        xm = np.sqrt(np.sum(x ** 2, axis=1)).reshape(x0, 1)
        ym = np.sqrt(np.sum(y ** 2, axis=1)).reshape(1, y0)
        xmmym = np.dot(xm, ym)
        cos = xmy / xmmym
        return cos
    except Exception as e:
        print(f"Error in pdist: {e}")
        return None

def lastselection(popfun1, popfun2, K, Z, Zmin):
    """
    选择最后一个front的解

    Parameters:
    popfun1 : ndarray
        第一部分种群的目标值
    popfun2 : ndarray
        第二部分种群的目标值
    K : int
        需要选择的个体数
    Z : ndarray
        参考点
    Zmin : ndarray
        最小的参考点
    
    Returns:
    choose : ndarray
        被选择的个体索引
    """
    popfun = copy.deepcopy(np.vstack((popfun1, popfun2))) - np.tile(Zmin, (popfun1.shape[0] + popfun2.shape[0], 1))
    N, M = popfun.shape
    N1 = popfun1.shape[0]
    N2 = popfun2.shape[0]
    NZ = Z.shape[0]

    # 正则化
    extreme = np.zeros(M)
    w = np.zeros((M, M)) + 1e-6 + np.eye(M)
    for i in range(M):
        extreme[i] = np.argmin(np.max(popfun / (np.tile(w[i, :], (N, 1))), 1))

    extreme = extreme.astype(int)
    temp = np.linalg.pinv(np.mat(popfun[extreme, :]))
    hyprtplane = np.array(np.dot(temp, np.ones((M, 1))))
    a = 1 / hyprtplane
    if np.sum(a == math.nan) != 0:
        a = np.max(popfun, 0)
    a = np.array(a).reshape(1,M)
    popfun = popfun / np.tile(a, (N, 1))

    # 计算每一个解最近的参考线的距离
    cos = pdist(popfun, Z)
    distance = np.tile(np.array(np.sqrt(np.sum(popfun ** 2, 1))).reshape(N, 1), (1, NZ)) * np.sqrt(1 - cos ** 2)
    d = np.min(distance.T, 0)
    pi = np.argmin(distance.T, 0)

    # 计算z关联的个数
    rho = np.zeros(NZ)
    for i in range(NZ):
        rho[i] = np.sum(pi[:N1] == i)

    # 选出剩余的K个
    choose = np.zeros(N2, dtype=bool)
    zchoose = np.ones(NZ, dtype=bool)
    while np.sum(choose) < K:
        temp = np.ravel(np.array(np.where(zchoose == True)))
        jmin = np.ravel(np.array(np.where(rho[temp] == np.min(rho[temp]))))
        j = temp[jmin[np.random.randint(jmin.shape[0])]]
        I = np.ravel(np.array(np.where(pi[N1:] == j)))
        I = I[choose[I] == False]
        if I.shape[0] != 0:
            if rho[j] == 0:
                s = np.argmin(d[N1 + I])
            else:
                s = np.random.randint(I.shape[0])
            choose[I[s]] = True
            rho[j] += 1
        else:
            zchoose[j] = False
    return choose

def uniformpoint(N, M):
    """
    生成均匀分布的参考点

    Parameters:
    N : int
        参考点个数
    M : int
        目标维度
    
    Returns:
    W : ndarray
        均匀分布的参考点
    N : int
        参考点的实际个数
    """
    try:
        H1 = 1
        while comb(H1 + M - 1, M - 1) <= N:
            H1 += 1
        H1 -= 1

        W = np.array(list(combinations(range(H1 + M - 1), M - 1))) - np.tile(np.arange(M - 1), (comb(H1 + M - 1, M - 1, exact=True), 1))
        W = (np.hstack((W, H1 + np.zeros((W.shape[0], 1)))) - np.hstack((np.zeros((W.shape[0], 1)), W))) / H1

        if H1 < M:
            H2 = 0
            while comb(H1 + M - 1, M - 1) + comb(H2 + M - 1, M - 1) <= N:
                H2 += 1
            H2 -= 1
            if H2 > 0:
                W2 = np.array(list(combinations(range(H2 + M - 1), M - 1))) - np.tile(np.arange(M - 1), (comb(H2 + M - 1, M - 1, exact=True), 1))
                W2 = (np.hstack((W2, H2 + np.zeros((W2.shape[0], 1)))) - np.hstack((np.zeros((W2.shape[0], 1)), W2))) / H2
                W2 = W2 / 2 + 1 / (2 * M)
                W = np.vstack((W, W2))

        W[W < 1e-6] = 1e-6
        N = W.shape[0]
        return W, N

    except Exception as e:
        print(f"Error in uniformpoint: {e}")
        return None, None

def genetic_operations(parent_population, lower_bound, upper_bound, step, mutation_rate, crossover_prob):
    
    population_size, num_variables = parent_population.shape
    offspring_population = np.empty_like(parent_population)

    # Only apply crossover and mutation to the first 5 variables (design variables)
    design_vars = parent_population[:, :5]
    non_design_vars = parent_population[:, 5:]

    # 交叉操作（简单交叉）
    for i in range(0, population_size, 2):
        parent1 = design_vars[i]
        parent2 = design_vars[i + 1] if i + 1 < population_size else design_vars[0]
        offspring1, offspring2 = simple_crossover(parent1, parent2, crossover_prob)
        offspring_population[i, :5] = offspring1
        if i + 1 < population_size:
            offspring_population[i + 1, :5] = offspring2

    # 变异操作（多项式变异）
    offspring_population[:, :5] = mutate_extra(offspring_population[:, :5], lower_bound[:, :5].numpy(), upper_bound[:, :5].numpy(), step[:, :5].numpy(), mutation_rate)
    
    #非设计变量不参与遗传操作
    offspring_population[:, 5:] = non_design_vars

    # 检查 NaN 值并进行替换
    if np.isnan(offspring_population).any():
        print("NaN detected in offspring population:")
        print(offspring_population)
        offspring_population = replace_nan_with_random(offspring_population, lower_bound, upper_bound, step)

    return offspring_population

def simple_crossover(x1, x2, pc):
    """
    简单的一点交叉操作

    :param x1: 父本1
    :param x2: 父本2
    :param pc: 交叉概率
    :return: 交叉后的两个子代
    """
    # 初始化子代为父本的拷贝
    y1 = x1.copy()
    y2 = x2.copy()
    
    if np.random.rand() < pc:  # 如果发生交叉
        r = np.random.randint(1, len(x1) + 1)  # 交叉点个数
        index = np.random.choice(np.arange(0, len(x1)), r, replace=False)  # 选取交叉点
        
        y1[index] = x2[index]  # 用父本2对应位置的值替换子代1的对应位置的值
        y2[index] = x1[index]  # 用父本1对应位置的值替换子代2的对应位置的值
    
    return y1, y2

def replace_nan_with_random(population, lower_bound, upper_bound, step):
    """Replace NaN values in the population with generated values."""
    num_individuals, num_variables = population.shape
    
    # Split lower_bound, upper_bound, and step into design variables and non-design variables
    lower_d, upper_d, step_d = lower_bound[:5], upper_bound[:5], step[:5]
    lower_n, upper_n, step_n = lower_bound[5:], upper_bound[5:], step[5:]
    
    mean_n = (upper_n + lower_n) / 2
    std_n = (upper_n - lower_n) / 4  # Assuming 4 standard deviations cover the range

    for individual in population:
        nan_indices = np.isnan(individual)

        # Generate new values for NaN positions in design variables
        if np.any(nan_indices[:5]):
            random_design_vars = lower_d + step_d * torch.floor(torch.rand(sum(nan_indices[:5])) * ((upper_d - lower_d) / step_d))
            random_design_vars = torch.clamp(random_design_vars, lower_d, upper_d).numpy()
            individual[nan_indices[:5]] = random_design_vars
        
        # Generate new values for NaN positions in non-design variables
        if np.any(nan_indices[5:]):
            random_normal_vars = torch.randn(sum(nan_indices[5:])) * std_n + mean_n
            random_normal_vars = torch.clamp(random_normal_vars, lower_n, upper_n).numpy()
            individual[nan_indices[5:]] = random_normal_vars

    return population

def envselect(mixpop, popsize, Z, Zmin, M, D, mixpopfun):
    maxfno, front, frontno = NDsort(mixpopfun, popsize)
    Next = frontno < maxfno
    Last = np.ravel(np.array(np.where(frontno == maxfno)))
    choose = lastselection(mixpopfun[Next, :], mixpopfun[Last, :], popsize - np.sum(Next), Z, Zmin)
    Next[Last[choose]] = True
    pop = copy.deepcopy(mixpop[Next, :])

    distances = crowding_distance_assignment(mixpopfun[Next])
    sorted_indices = np.argsort(distances)
    pop = pop[sorted_indices[:popsize]]
    # 更新front和frontno列表
    front[-1] = Last[choose]
    selected_indices = np.where(Next)[0]
    frontno = frontno[selected_indices]

    return pop, front, frontno

def crowding_distance_assignment(front):
    distances = np.zeros(front.shape[0])
    for i in range(front.shape[1]):
        sorted_indices = np.argsort(front[:, i])
        distances[sorted_indices[0]] = np.inf
        distances[sorted_indices[-1]] = np.inf
        for j in range(1, len(sorted_indices) - 1):
            distances[sorted_indices[j]] += (front[sorted_indices[j + 1], i] - front[sorted_indices[j - 1], i]) / (np.max(front[:, i]) - np.min(front[:, i]) + 1e-9) # 加入一个小的常数以避免除零错误
    return distances

def NDsort(mixpopfun, popsize):
    """
    对种群进行非支配排序

    Parameters:
    mixpop : ndarray
        种群的目标值矩阵
    N : int
        种群大小
    
    Returns:
    frontno : ndarray
        每个个体的非支配等级
    maxfno : int
        最大的非支配等级
    """
    nsort = popsize
    N, M = mixpopfun.shape
    Loc1 = np.lexsort(mixpopfun[:, ::-1].T)
    mixpop2 = mixpopfun[Loc1]
    Loc2 = Loc1.argsort()
    frontno = np.ones(N) * np.inf
    maxfno = 0
    front = []

    while (np.sum(frontno < np.inf) < min(nsort, N)):
        maxfno += 1
        current_front = []
        for i in range(N):
            if frontno[i] == np.inf:
                dominated = 0
                for j in range(i):
                    if frontno[j] == maxfno:
                        m = 0
                        flag = 0
                        while (m < M and mixpop2[i, m] >= mixpop2[j, m]):
                            if mixpop2[i, m] == mixpop2[j, m]:
                                flag += 1
                            m += 1
                        if m >= M and flag < M:
                            dominated = 1
                            break
                if dominated == 0:
                    frontno[i] = maxfno
                    current_front.append(Loc2[i])
        front.append(current_front)

    frontno = frontno[Loc2]
    return maxfno, front, frontno

def dominates(ind1, ind2, M):
    """
    判断个体ind1是否支配个体ind2

    Parameters:
    ind1, ind2 : ndarray
        两个个体的目标值
    M : int
        目标维度
    
    Returns:
    bool
        ind1是否支配ind2
    """
    better_in_any = False
    for m in range(M):
        if ind1[m] < ind2[m]:
            return False
        elif ind1[m] > ind2[m]:
            better_in_any = True
    return better_in_any
