import numpy as np
import torch, random, time, os
import torch.optim as optim
from BNN_Class import MLP_BBB
from plot_utils import plot_3d_pareto_fronts, plot_scatter, plot_confidence_interval, save_pareto_front_data
from utils import load_config, compute_objective_values, uniformpoint, genetic_operations, CreateInput, envselect, NDsort, shuffle_genetic_parameters

def main():
    config = load_config('D:/Python WorkShop File/BNN+NSGA3/demo3_i8o3/config.yaml')
    num_x = config['num_x']
    num_y = config['num_y']
    LowerBound = torch.tensor(config['LowerBound']).reshape(-1, num_x)
    UpperBound = torch.tensor(config['UpperBound']).reshape(-1, num_x)
    step = torch.tensor(config['step']).reshape(-1, num_x)

    # 调试信息
    print("LowerBound shape:", LowerBound.shape)
    print("UpperBound shape:", UpperBound.shape)
    print("Step shape:", step.shape)

    if torch.any(step <= 0):
        raise ValueError("Step values must be greater than zero")

    length = torch.round((UpperBound - LowerBound) / step, decimals=0).reshape(-1, num_x)
    group = torch.cat([LowerBound, step, UpperBound, length], 0)

    # 调试信息
    print("Group shape:", group.shape)

    npop = 2048
    max_it = 800
    mutation_rate = 0.01
    crossover_prob = 0.6

    path = 'D:/Python WorkShop File/BNN+NSGA3/demo3_i8o3'
    path1 = 'D:/Python WorkShop File/BNN+NSGA3/demo3_i8o3/data'
    os.makedirs(path1, exist_ok=True)

    # 开始时间计算
    start_time = time.time()

    CI = CreateInput()
    input_Parent = CI.generate_multiple_inputs(group, npop)
    Z, N = uniformpoint(max_it, num_y)  # 生成一致性的参考解,Z为参考点坐标

    # 实例化网络并加载预训练模型
    model = MLP_BBB(num_x, 64, num_y, config['prior_var'])
    optimizer = optim.Adam(model.parameters(), lr=0.01)

    # 加载预训练模型和缩放器
    try:
        checkpoint = torch.load(os.path.join(path, 'net_8in3out.pth'))
    except FileNotFoundError:
        raise Exception(f"Checkpoint file not found at {path}/net_8in3out.pth")
    
    model.load_state_dict(checkpoint['net'])
    optimizer.load_state_dict(checkpoint['optimizer'])
    scaler_output = checkpoint['scaler_output']
    scaler_input = checkpoint['scaler_input']

    # 初始计算目标值和罚函数值
    model.eval()
    output_Parent, output_Parent_penalty, _ = compute_objective_values(num_y, model, scaler_input, scaler_output, input_Parent, config['samples'])
    # 遗传算法迭代过程
    Zmin = np.min(output_Parent_penalty.numpy(), 0)

    _, _, frontno_Parent = NDsort(output_Parent_penalty.numpy(), npop)

    # 保存初始种群数据
    pop_all_0 = torch.cat([input_Parent, output_Parent_penalty, output_Parent], axis=1)
    save_pareto_front_data(0, path1, pop_all_0, frontno_Parent)
    
    # 绘制初代种群
    plot_3d_pareto_fronts(0, path1, output_Parent_penalty.numpy())
    plot_scatter(0, output_Parent_penalty.numpy(), path1)

    each50_generation_front = []  # 每一次迭代的Front种群

    for i in range(max_it):
        if (i+1) % 10 == 0:
            print(f"第{i+1}次迭代")
        input_Parent_np = input_Parent.detach().numpy() if isinstance(input_Parent, torch.Tensor) else input_Parent
        matingpool = random.sample(range(len(input_Parent_np)), len(input_Parent_np))
        input_Child = genetic_operations(input_Parent_np[matingpool, :], LowerBound, UpperBound, step, mutation_rate, crossover_prob)
        input_Child = torch.from_numpy(input_Child)
        model.eval()
        _, output_Child_penalty, _ = compute_objective_values(num_y, model, scaler_input, scaler_output, input_Child, config['samples'])

        mixpop = np.vstack((input_Parent_np, input_Child.detach().numpy()))
        mixpopfun = np.vstack((output_Parent_penalty.detach().numpy(), output_Child_penalty.detach().numpy()))
        Zmin = np.min(np.vstack((Zmin, output_Child_penalty.numpy())), axis=0)
        pop, front_list, frontno_pop = envselect(mixpop, npop, Z, Zmin, num_y, num_x, mixpopfun)
        if pop is not None:
            pop = torch.from_numpy(pop)
        else:
            print("Population selection failed.")
            continue
        pop = shuffle_genetic_parameters(pop)
        
        model.eval()
        output_Pop, output_Pop_penalty, sample_pop = compute_objective_values(num_y, model, scaler_input, scaler_output, pop, config['samples'])

        input_Parent = pop
        output_Parent_penalty = output_Pop_penalty
        sample_Parent = sample_pop
        output_Parent = output_Pop
        frontno_Parent = frontno_pop

        if (i+1) % 50 == 0:
            # 保存当前迭代结果
            pop_all = torch.cat([input_Parent if isinstance(input_Parent, torch.Tensor) else torch.from_numpy(input_Parent), 
                                 output_Parent_penalty, output_Parent], axis=1)
            save_pareto_front_data(i, path1, pop_all, frontno_Parent)
            plot_3d_pareto_fronts(i, path1, output_Parent_penalty.numpy())    
            plot_scatter(i, output_Parent_penalty.numpy(), path1)
            each50_generation_front.append(front_list)

        # 自适应调整变异率
        mutation_rate = max(0.01, mutation_rate * 0.99)  # 随着迭代次数增加逐渐减小变异率
    
        # 每隔一定迭代次数引入新个体
        if i % 20 == 0:
            num_new_individuals = int(0.1 * npop)
            new_individuals = CI.generate_multiple_inputs(group, num_new_individuals).numpy()
            input_Parent_np = input_Parent.detach().numpy() if isinstance(input_Parent, torch.Tensor) else input_Parent
            # 随机选择替换位置
            replace_indices = np.random.choice(len(input_Parent_np), num_new_individuals, replace=False)
            input_Parent_np[replace_indices] = new_individuals  # 随机替换旧个体
            input_Parent = torch.from_numpy(input_Parent_np)
            
    # 调用绘图函数绘制二维散点图和置信区间图
    plot_scatter(200, output_Parent_penalty.numpy(), path1)
    plot_confidence_interval(sample_Parent, pop_all, path1)

    print("优化过程完成。")
    # 计算总时间
    end_time = time.time()
    total_time = end_time - start_time
    print(f"总运行时间: {total_time}秒")

if __name__ == "__main__":
    main()
