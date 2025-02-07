%初始化
vFxBnd = []; % 固定边界
mFxDim = []; 
mFxVal = []; 

vLdBnd = []; % 载荷边界
mBnLod = []; 

mCkLod = []; % 内部裂纹压力
vBdLod = []; 

vFxBnd = [3];
mFxDim(1,:) = [ 1, 1];%自由度约束
mFxVal(1,:) = [ 0, 0];

vLdBnd = [1]; %平板底部
mBnLod(1,:) = [0.2,-0.15];%载荷

wCkLod = 0;
mCkLod(1,:) = [1,0]; % =[p_n,p_t]
wBdLod = 0; 
vBdLod = [0,0]; % =[b_x,b_y]