nCrack = 0;  % 裂纹数量; nCrack = length(cCkCrd)
cCkCrd = []; % 裂纹单元坐标 {[x1,y1;x2,y2;...];[];...}
mTpFrz = []; 
mCkBox = []; % 裂纹生长

nCrack = 1; % 单裂纹
cCkCrd{1} = [0.0, 0.05; 1.5, 0.05]; % 裂纹坐标 (对应Abaqus中的水平线)
mTpFrz = []; % 无冻结裂纹尖端