%%%%%%%%%%  一阶六面体单元形参程序  %%%%%%%%%%%
%  N局部坐标下的形函数矩阵   
%  NDerivative形函数矩阵对全局坐标的导数  
%  JacobiDET雅可比行列式
%  GaussPoint高斯点坐标  
%  ElementNodeCoordinate单元节点坐标（8*3，每一行代表一个节点的坐标）  
function [N,NDerivative,JacobiDET] = ShapeFunction(GaussPoint,ElementNodeCoordinate)
 %等参元坐标  每一列代表一个点的坐标
ParentNodes=[-1  1  1 -1 -1  1  1 -1;
    -1 -1  1  1 -1 -1  1  1;
    -1 -1 -1 -1  1  1  1  1];
N=zeros(8,1); %初始化形函数矩阵8*1
ParentNDerivative=zeros(3,8);%初始化形函数对局部坐标的导数矩阵3*8
%计算形函数及形函数对局部坐标导数
for I=1:8
    XPoint = ParentNodes(1,I);
    YPoint = ParentNodes(2,I);
    ZPoint = ParentNodes(3,I);
    ShapePart = [1+GaussPoint(1)*XPoint 1+GaussPoint(2)*YPoint 1+GaussPoint(3)*ZPoint];  %定义中间变量
    N(I) = 0.125*ShapePart(1)*ShapePart(2)*ShapePart(3);
    ParentNDerivative(1,I) = 0.125*XPoint*ShapePart(2)*ShapePart(3);
    ParentNDerivative(2,I) = 0.125*YPoint*ShapePart(1)*ShapePart(3);
    ParentNDerivative(3,I) = 0.125*ZPoint*ShapePart(1)*ShapePart(2);
end
Jacobi = ParentNDerivative*ElementNodeCoordinate;%计算雅可比矩阵
JacobiDET = det(Jacobi);%计算雅可比行列式
JacobiINV=inv(Jacobi);%对雅可比行列式求逆
NDerivative=JacobiINV*ParentNDerivative;%利用雅可比行列式的逆计算形函数对结构坐标的导数
end