global Para_Long;                   % 车辆纵向动力学参数结构体
Para_Long.air_mass_density = 1.206; % 空气密度,kg/m^3
Para_Long.frontal_area = 7.3;       % 迎风面积,m^2
Para_Long.aerodynamic_Coeff = 0.69; % 风阻系数 0.69
Para_Long.gravity_acc = 9.8;        % 重力加速度,m/s^2
Para_Long.roll_resistance = 0.010;  % 滚动阻力 0.002
Para_Long.v_min = 0;                % 最低车速
Para_Long.v_max = 45;               % 最高车速
Para_Long.m_min = 0;                % 最小质量
Para_Long.m_max = 10000;            % 最大质量
Para_Long.theta_min = -30*pi/180;   % 最小坡度
Para_Long.theta_max = 30*pi/180;    % 最大坡度

global Para_Sim;                    % 仿真参数设置结构体
Para_Sim.T = 0.02;                  % 采样步长，s