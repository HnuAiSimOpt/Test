function [sys,x0,str,ts,simStateCompliance] = WLS_mass(t,x,u,flag)
switch flag,
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;
  case 1,
    sys=mdlDerivatives(t,x,u);
  case 2,
    sys=mdlUpdate(t,x,u);
  case 3,
    sys=mdlOutputs(t,x,u);
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);
  case 9,
    sys=mdlTerminate(t,x,u);
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
end

%% 初始化
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 3;
sizes.NumInputs      = 4;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

x0  = [];
str = [];
ts  = [0.02 0];
simStateCompliance = 'UnknownSimState';

%% 返回连续状态的导数
function sys=mdlDerivatives(t,x,u)

sys = [];


%% 处理离散的状态更新
function sys=mdlUpdate(t,x,u)

sys = [];


%% 返回输出
function sys=mdlOutputs(t,x,u)
% 静态后验估计值的变量定义
persistent Yk Hk xk1 xk2 xk3;
if(t == 0)
    Yk = [];    
    Hk = [];
    xk1 = 1000;
    xk2 = 1000;
    xk3 = 1000;
end

% 变量代换
vx = u(1);
Fx = u(2);
ax_s = u(3);
az_s = u(4);

% 车辆参数设置
if(t == 0)
    run Parameter.m;
end
global Para_Sim;
global Para_Long;
T = Para_Sim.T;                     % 采样步长
rou = Para_Long.air_mass_density;   % 空气密度,kg/m^3
A = Para_Long.frontal_area;         % 迎风面积,m^2
Cd = Para_Long.aerodynamic_Coeff;   % 风阻系数
g = Para_Long.gravity_acc;      	% 重力加速度,m/s^2
f_r = Para_Long.roll_resistance;    % 滚动阻力

% WLS参数设置
gamma = 100;                        % Huber权重系数
c = 1000;                           % Tukey's biweight权重系数
eps = 2000;                         % 核函数权重系数

% 测量矩阵构造
yk = Fx - 0.5 * rou * Cd * A * vx^2;
hk = ax_s + f_r * az_s;
Yk = [Yk; yk];
Hk = [Hk; hk];

% 权重矩阵更新
% 基于Huber函数的权重更新
E = abs(Yk - Hk * xk1);
wk1 = zeros(size(E));
wk1(E <= gamma) = 1;
wk1(E > gamma) = gamma ./ E(E > gamma);
% 基于Tukey's biweight函数的权重更新
wk2 = (1 - ((yk - hk * xk2) / c).^2).^2;
% 基于核函数的权重更新
wk3 = exp(-(Yk - Hk * xk3).^2 / (2 * eps^2));

Wk1 = diag(wk1);
Wk2 = diag(wk2);
Wk3 = diag(wk3);

% 加权最小二乘法估计
xk1 = (Hk' * Wk1 * Hk)^(-1) * Hk' * Wk1 * Yk;
xk2 = (Hk' * Wk2 * Hk)^(-1) * Hk' * Wk2 * Yk;
xk3 = (Hk' * Wk3 * Hk)^(-1) * Hk' * Wk3 * Yk;

% 加权最小二乘法的最优估计输出
sys = [xk1; xk2; xk3];

%% 计算下一个仿真时刻
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

%% 结束
function sys=mdlTerminate(t,x,u)

sys = [];
