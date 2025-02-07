problemType = 'PlaneStress'; %平面应力
lengthUnits = 'm';

nPhase = 1;% 相位
E(1) = 210e3; % 弹性模量 (MPa), 对应Abaqus中的210 GPa
v(1) = 0.3;   % 泊松比

% 损伤准则
K_crt = 220; % 最大主应力损伤阈值 (MPa)
G_f = 42200; % 断裂能 (J/m²), 对应Abaqus中的损伤演化能量

switch lengthUnits
    case 'mm'
        K_crt = K_crt * 1e-6; % MPa -> N/mm²
        G_f = G_f * 1e3;      % J/m² -> mJ/mm²
    case 'm'
    otherwise
        error('Length units?')
end