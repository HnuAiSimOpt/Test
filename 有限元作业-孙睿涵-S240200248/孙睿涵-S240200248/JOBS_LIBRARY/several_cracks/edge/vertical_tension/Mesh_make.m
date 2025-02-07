L = 3.0; 
H = 6.0;
if with_Layered
    yi = [-H/2,-H/4,H/4,H/2]; 
    Ni = [0,2,0];  
end
nH = 60; % 网格
ne = ceil([L/H,1]*nH);
he = H/ne(2);

xlim = [   0,  L];
ylim = [-H/2,H/2];

% 生成Q4网格
[mNdCrd, mLNodS, cBCNod] = MeshRect_q4(xlim, ylim, ne(1), ne(2));
vElPhz = ones(size(mLNodS,1), 1); % 单一材料相位

% 定义边界节点（与Abaqus一致）
cBCNod{1} = find(mNdCrd(:,2) == min(mNdCrd(:,2))); % 底部边界
cBCNod{3} = find(mNdCrd(:,2) == max(mNdCrd(:,2))); % 顶部边界
% BC coordinates (alt.)
cBCCrd = [];

clear xlim ylim yi Ni
