nStep = 10000; 
initialInc = 0.005; % 初始增量步大小
minInc = 1e-9;% 最小增量步大小
maxInc = 0.01;% 最大增量步大小     

with_MeshRead = 0; 
with_Layered  = 0; % 分层标志位，1表示采用分层结构，0表示为单片结构
% 如果采用分层结构，则不能读取已有网格数据，避免出现意外结果
if with_Layered == 1
    with_MeshRead = 0; 
end

mesh_ElemType = 'Q4'; % 网格单元类型，四边形单元（Q4）
mesh_EnriSize = 'normal';
kind_LawDir = 'energy'; %基于能量的方向准则
kind_LawCrt = 'energy'; %基于能量的破坏准则
kind_GrwCrt = 'all'; 
if strcmpi(kind_GrwCrt,'custom')
    with_GrwCrt_inf = 0.5; 
end
with_Update = 1; 
with_RdoStd = 1;
with_MapTyp = 1;
with_AdpEnr = 0; 

with_GLwInc = 0;% 能量最小化设置，全局最小化增量步标志位，0表示不启用
with_GLwDir = 0;% 全局最小化方向标志位，0表示不启用
with_DirAvg = 0;% 方向平均标志位，0表示不启用
% 如果启用全局最小化方向，则设置相关参数
if with_GLwDir
    % 方向迭代次数
    nIter_dir = 5;
    % 方向迭代的角度容差
    dBetaTol_iterDir = (0.01*pi/180) * 1;
    % 方向迭代的最小角度变化
    dBetaMin_iterDir = (0.01*pi/180) * 1;    
end
% 如果启用全局最小化增量步，则设置相关参数
if with_GLwInc
    dBetaMin_iterInc = (5.00*pi/180) * 0;     % 裂纹起始的最小弯折角度
end
with_RfnInc = 0; % 与裂纹弯折相关的自适应网格细化标志位，0表示不启用
with_RfnXrs = 0; % 裂纹预相交时的自适应网格细化标志位，0表示不启用

% 如果启用了与裂纹弯折或预相交相关的自适应网格细化
if with_RfnInc || with_RfnXrs
    % 裂纹增量或尖端网格的最大细化次数
    nRefine_inc = 1;    
    nRefine_xrs = 3; % 裂纹相交前的细化次数，应大于等于裂纹增量或尖端网格的最大细化次数
    dBetaMin_mshFine = (5.0*pi/180) * 0; % 当裂纹弯折角度大于该值时进行网格细化
    dBetaMax_mshCors = (1.0*pi/180) * 0;  % 当裂纹弯折角度小于该值时进行网格粗化
end

with_BndXrs = 1; 
if with_BndXrs
    with_BndXrs_refine = 1; 
    with_BndXrs_freeze = 1; 
end

with_JIntegral = 1; 
with_Roughness = 0; 
save_CracksEnd = 0; 
save_CracksAll = 0;
save_StressAll = 1; 
save_DisplcAll = 1; 
save_StateVarb = 1; 
save_Roughness = 0; 
plot_Mesh = 0; 
plot_Domain = 0; % 绘制裂纹时绘制域的标志位
plot_Cracks = 0;% 绘制每一步裂纹的标志位 
plot_Enriched = 0; % 绘制富集单元的标志位
plot_Displace = 1; % 绘制位移云图的标志位
plot_Deformed = 0; % 绘制变形后高斯点的标志位
plot_VonMises = 1; % 绘制von Mises应力的标志位
plot_VmsContr = 0; % 绘制von Mises应力云图的标志位
plot_Potential = 0; % 绘制势能的标志位
plot_DissipGlb = 0; % 绘制耗散率的标志位
plot_Roughness = 0; % 绘制断裂表面粗糙度的标志位
mov_Cracks   = 0; % 制作裂纹扩展演变动画的标志位
mov_VonMises = 0; % 制作应力演变动画的标志位
mov_Deformed = 0; % 制作变形演变动画的标志位
with_Debug = 0;