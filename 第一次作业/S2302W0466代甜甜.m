% 定义线性方程组的系数矩阵和常数向量
linearSystemMatrix = [6 3 1; 3 8 4; 1 4 10]; % 新的对称正定矩阵
rightHandSideVector = [10; 18; 33]; % 新的常数向量

% 初始参数设置
startingEstimate = [0; 0; 0]; % 初始解猜测
iterationCap = 200; % 最大迭代次数
accuracyThreshold = 1e-8; % 收敛容差

% 使用迭代法求解线性系统
solution = iterativeLinearSolver(linearSystemMatrix, rightHandSideVector, startingEstimate, iterationCap, accuracyThreshold);
% 显示解向量
outputSolution(solution);

% 迭代法求解线性系统函数
function sol = iterativeLinearSolver(L, RHS, initialGuess, maxIter, accuracy)
    currentSolution = initialGuess;
    residualVector = RHS - L * currentSolution; % 初始残差
    iterationDirection = residualVector; % 初始化迭代方向
    residualDotProduct = residualVector' * residualVector; % 用于计算beta

    iterationIndex = 0;
    while iterationIndex < maxIter && norm(residualVector) > accuracy
        iterationIndex = iterationIndex + 1;
        
        % 计算步长
        step = residualDotProduct / (iterationDirection' * (L * iterationDirection));
        
        % 更新解
        currentSolution = currentSolution + step * iterationDirection;
        
        % 更新残差
        residualVector = residualVector - step * L * iterationDirection;
        
        % 检查是否满足收敛条件
        if norm(residualVector) < accuracy
            break;
        end
        
        % 更新迭代方向
        newResidualDotProduct = residualVector' * residualVector;
        betaValue = newResidualDotProduct / residualDotProduct;
        iterationDirection = residualVector + betaValue * iterationDirection;
        
        % 准备下一次迭代
        residualDotProduct = newResidualDotProduct;
    end
    
    sol = currentSolution;
end

% 显示解向量的函数
function outputSolution(solution)
    fprintf('The computed solution is:\n');
    disp(solution);
end