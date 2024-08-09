import numpy as np
from scipy.stats.qmc import Sobol

def shuffle_genetic_parameters(pop, seed=None):
    """
    将种群中的设计变量和非设计变量打乱重组，并对非设计变量进行小范围扰动。

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
    
    # 使用索贝尔序列生成随机数
    num_individuals = non_design_variables.shape[0]
    sobol_engine = Sobol(d=non_design_variables.shape[1], scramble=True, seed=seed)
    sobol_sequence = sobol_engine.random(num_individuals)
    
    # 转化非设计变量
    transformed_non_design_variables = non_design_variables + sobol_sequence
    
    # 合并设计变量和非设计变量
    combined_variables = np.hstack((shuffled_design_variables, transformed_non_design_variables))
    
    return combined_variables

# 示例用法
pop = np.array([
    [1, 2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15, 16],
    [17, 18, 19, 20, 21, 22, 23, 24]
])

result = shuffle_genetic_parameters(pop, seed=42)
print(result)