function [sys,x0,str,ts,simStateCompliance] = LS_mass(t,x,u,flag)
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
sizes.NumOutputs     = 1;
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
persistent Pk xk;
if(t == 0)
    Pk = 1;    
    xk = 1000;
end

% 变量代换
vx = u(1);
Fx = u(2);
ax_s = u(3);
az_s = u(4);

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

% 测量更新
yk = Fx - 0.5 * rou * Cd * A * vx^2;
hk = ax_s + f_r * az_s;

% 最小二乘法估计
Pk = (Pk^(-1) + hk' * hk)^(-1);
xk = xk + Pk * hk' * (yk - hk * xk);

% 加权最小二乘法的最优估计输出
sys = xk;

%% 计算下一个仿真时刻
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

%% 结束
function sys=mdlTerminate(t,x,u)

sys = [];
