function [sys,x0,str,ts,simStateCompliance] = WLS_slope(t,x,u,flag)
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
sizes.NumInputs      = 9;
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
persistent Yk1 Yk2 Yk3 Hk1 Hk2 Hk3 xk1 xk2 xk3;
if(t == 0)
    Yk1 = [];    
    Hk1 = [];
    Yk2 = [];    
    Hk2 = [];
    Yk3 = [];    
    Hk3 = [];
    xk1 = 0.05;
    xk2 = 0.05;
    xk3 = 0.05;
end

% 变量代换
vx = u(1);
Fx = u(2);
ax_s = u(3);
az_s = u(4);
ax = u(5);
m1 = u(6);
m2 = u(7);
m3 = u(8);

% 参数设置
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
gamma = 0.01;                        % Huber权重系数
c = 1000;                              % Tukey's biweight权重系数
eps = 1000;                         % 核函数权重系数

% 测量矩阵构造
yk1 = Fx - m1 * ax - 0.5 * rou * Cd * A * vx^2;
hk1 = m1 * g;
Yk1 = [Yk1; yk1];
Hk1 = [Hk1; hk1];
yk2 = Fx - m2 * ax - 0.5 * rou * Cd * A * vx^2;
hk2 = m2 * g;
Yk2 = [Yk2; yk2];
Hk2 = [Hk2; hk2];
yk3 = Fx - m3 * ax - 0.5 * rou * Cd * A * vx^2;
hk3 = m3 * g;
Yk3 = [Yk3; yk3];
Hk3 = [Hk3; hk3];

% 权重矩阵更新
% 基于Huber函数的权重更新
E = abs(Yk1 - Hk1 * xk1);
wk1 = zeros(size(E));
wk1(E <= gamma) = 1;
wk1(E > gamma) = gamma ./ E(E > gamma);
% 基于Tukey's biweight函数的权重更新
wk2 = (1 - ((Yk2 - Hk2 * xk2) / c).^2).^2;
% 基于核函数的权重更新
wk3 = exp(-(Yk3 - Hk3 * xk3).^2 / (2 * eps^2));

Wk1 = diag(wk1);
Wk2 = diag(wk2);
Wk3 = diag(wk3);

% 加权最小二乘法估计
xk1 = (Hk1' * Wk1 * Hk1)^(-1) * Hk1' * Wk1 * Yk1;
xk2 = (Hk2' * Wk2 * Hk2)^(-1) * Hk2' * Wk2 * Yk2;
xk3 = (Hk3' * Wk3 * Hk3)^(-1) * Hk3' * Wk3 * Yk3;

% 加权最小二乘法的最优估计输出
sys = [asin(xk1 / sqrt(1 + f_r^2)) - atan(f_r);...
       asin(xk2 / sqrt(1 + f_r^2)) - atan(f_r);...
       asin(xk3 / sqrt(1 + f_r^2)) - atan(f_r)];


%% 计算下一个仿真时刻
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

%% 结束
function sys=mdlTerminate(t,x,u)

sys = [];
