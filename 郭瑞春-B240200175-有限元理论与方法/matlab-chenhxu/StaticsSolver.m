%%%%%%%%%%  一阶六面体单元求解程序(求解位移矩阵)  %%%%%%%%%%%
%  U位移矩阵 
%  E弹性模量   
%  u泊松比
%  Forces外力矩阵n*3 [节点 方向 大小]
%  Constraints位移约束n*3 [节点 方向 大小]
%  Nodes节点坐标信息
%  Elements单元信息
function [U]=StaticsSolver(E,u,Forces,Constraints,Nodes,Elements)
Dof=3;
NodeCount = size(Nodes,1);  % 节点个数
ElementCount= size(Elements,1);  %单元个数
Dofs = Dof*NodeCount; %总自由度数
U=sparse(Dofs,1);	% 初始化结构位移
K = sparse(Dofs,Dofs);  %初始化总体刚度阵
Force = sparse(Dofs,1);  %初始化外力向量
%计算应力-应变矩阵D
D=LinearIsotropicD(E,u);
for I=1:ElementCount
    % 单元节点坐标
    ElementNodeCoordinate=Nodes(Elements(I,:),:);
    % 计算单刚
    ElementStiffnessMatrix=Ke(D,ElementNodeCoordinate);
    % 计算单元节点自由度编号
    ElementNodeDOF=zeros(1,24);
    for J=1:8
        II=(J-1)*Dof+1;
        ElementNodeDOF(II:II+2)=(Elements(I,J)-1)*Dof+1:(Elements(I,J)-1)*Dof+3;
    end
    K(ElementNodeDOF,ElementNodeDOF)=K(ElementNodeDOF,ElementNodeDOF)+ElementStiffnessMatrix;%根据单元节点自由度  组装总刚
end
% 施加外力
if size(Forces,1)>0
    ForceDOF = Dof*(Forces(:,1)-1)+Forces(:,2);   %计算外力自由度编号
    Force(ForceDOF) = Force(ForceDOF) + Forces(:,3);
end
% 乘大数法施加位移约束
BigNumber=1e8;
ConstraintsNumber=size(Constraints,1);
if ConstraintsNumber~=0
    FixedDof=Dof*(Constraints(:,1)-1)+Constraints(:,2);  %被约束的自由度编号(列向量)
    for i=1:ConstraintsNumber
        K(FixedDof(i),FixedDof(i))=K(FixedDof(i),FixedDof(i))*BigNumber;
        Force(FixedDof(i))=Constraints(i,3)*K(FixedDof(i),FixedDof(i));
    end
end
%计算位移
U = K\Force;
end