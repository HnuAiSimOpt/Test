%%%%%%%%%%  一阶六面体单元绘制云图程序  %%%%%%%%%%%
%  Nodes节点坐标信息
%  Elements单元信息
%  U位移矩阵   
%  Component云图上节点的值，可以是位移、应力、应变等
function PlotContour(Nodes,Elements,U,Component)
NodeCount = size(Nodes,1) ;  %  节点个数
ElementCount = size(Elements,1) ;    %单元个数
ElementNodeCount=8;  %每个单元节点数
% 矩阵初始化，X Y Z点的坐标：value点的值,对每个单元按照节点序号依次绘制云图
X = zeros(ElementNodeCount,ElementCount) ;
Y = zeros(ElementNodeCount,ElementCount) ;
Z = zeros(ElementNodeCount,ElementCount) ;
value = zeros(ElementNodeCount,ElementCount) ;
%判断矩阵类型（位移，应力，应变）
if size(Component,1)>1
    for i=1:ElementCount
        nd=Elements(i,:);
        value(:,i) = Component(nd) ;
    end
else
    %先进行磨平，再把Component行向量转化成矩阵形式
    Difference=max(Component)-min(Component);%全域上的最大值-最小值
    AVG=0.75;  % 默认阈值75%
    for i=1:1:NodeCount %遍历节点，进行应力磨平
        TElements=Elements';%转置Elements
        itemp=(TElements==i);%进行逻辑判断，itemp:元素为0 1的矩阵
        Cut=max(Component(1,itemp))-min(Component(1,itemp));%该节点的应力（应变）差
        if 0<Cut&&Cut<=AVG*Difference(1)%判断是否满足阈值条件
            Component(1,itemp)=mean(Component(1,itemp));%进行应力（应变）磨平
        end
    end
    value=reshape(Component,ElementNodeCount,ElementCount);%将Component的值赋给value
end
%定义colormap的颜色
myColor=1/255*[0,0,255;  0,93,255;   0,185,255;  0,255,232;
    0,255,139;  0,255,46;  46,255,0;  139,255,0;
    232,255,0;  255,185,0; 255,93,0;  255,0,0];
% 绘制变形后云图
newNodes=Nodes';
newNodes=newNodes(:);
DeformationCoefficient=5.0e2; %变形放大系数
newNodes=newNodes+DeformationCoefficient*U;
newNodes=reshape(newNodes,[3,size(Nodes,1)]);
newNodes=newNodes';
% 定义单元每个面的节点顺序(顺时针或逆时针)
if ElementNodeCount == 4  % C3D4单元
    fm = [1 2 4;2 3 4;3 1 4;1 3 2]; 
elseif ElementNodeCount==6 %C3D6单元
    fm=[1 2 3 1;4 5 6 4;1 2 5 4;1 3 6 4;2 3 6 5];
elseif ElementNodeCount == 8  % C3D8单元
    fm = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
elseif ElementNodeCount == 20  % C3D20单元
    fm = [1,9,2,10,3,11,4,12;5,13,6,14,7,15,8,16;1,9,2,18,6,13,5,17;
        2,10,3,19,7,14,6,18;3,11,4,20,8,15,7,19;1,17,5,16,8,20,4,12]; 
end
xyz = cell(1,ElementCount) ;
profile = xyz ;
%将节点位置赋予其对应值
for e=1:ElementCount %循环获取每个单元内节点的坐标
    nd=Elements(e,:);
    X = newNodes(nd,1) ;
    Y = newNodes(nd,2) ;
    Z = newNodes(nd,3) ;
    xyz{e} = [X  Y Z] ;
    profile{e} = value(:,e);
end
% 采用patch函数进行绘图
figure
cellfun(@patch,repmat({'Vertices'},1,ElementCount),xyz,.......%用多边形面片的方式显示各个面
    repmat({'Faces'},1,ElementCount),repmat({fm},1,ElementCount),......
    repmat({'FaceVertexCdata'},1,ElementCount),profile,......
    repmat({'FaceColor'},1,ElementCount),repmat({'interp'},1,ElementCount));
view(3);
rotate3d on;
axis off; %不显示坐标轴
colormap(myColor);
caxis([min(Component),max(Component)]);
t1=caxis;
t1=linspace(t1(1),t1(2),13);
colorbar('ytick',t1,'Location','westoutside');
axis equal;
end