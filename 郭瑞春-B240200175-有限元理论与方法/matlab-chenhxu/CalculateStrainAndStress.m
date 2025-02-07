%%%%%%%%%%%  一阶六面体单元计算应力应变(节点及高斯点)程序 %%%%%%%%%%
%  NodeStrain节点应变
%  NodeStress节点应力  
%  GaussStrain高斯点应变   
%  GaussStress高斯点应力
%  U位移矩阵
%  D线弹性材料应力-应变矩阵
%  Nodes节点坐标信息
%  Elements单元信息
function [NodeStrain,NodeStress,GaussStrain,GaussStress]=CalculateStrainAndStress(U,D,Nodes,Elements)  
ElementCount= size(Elements,1);  %单元个数
GaussCoordinate=[-0.57735026918963D0, 0.57735026918963D0];  %高斯积分点坐标
GaussWeight=[1.00000000000000D0, 1.00000000000000D0];  %高斯积分点权重
GaussPointNumber=0;%高斯积分点编号
INODE=0;% 节点编号
Dof=3; 
%定义矩阵维度 加快运行速度
GaussStrain=zeros(6,ElementCount*8);
GaussStress=zeros(6,ElementCount*8);
NodeStrain=zeros(6,ElementCount*8);
NodeStress=zeros(6,ElementCount*8);
%循环组装总刚
for I=1:ElementCount
    % 单元节点坐标
    ElementNodeCoordinate=Nodes(Elements(I,:),:); 
    % 计算单元节点自由度编号
    ElementNodeDOF=zeros(1,24);
    for J=1:8
        II=(J-1)*Dof+1;
        ElementNodeDOF(II:II+2)=(Elements(I,J)-1)*Dof+1:(Elements(I,J)-1)*Dof+3;
    end
    K=1;
    InterpolationMatrix=zeros(8,8);%求解节点应力应变的插值矩阵
    %循环高斯点
    for X=1:2
        for Y=1:2
            for Z=1:2  
                E1=GaussCoordinate(X); E2=GaussCoordinate(Y); E3=GaussCoordinate(Z);
                GaussPointNumber = GaussPointNumber + 1;
                % 计算局部坐标下的形函数及形函数导数
                [N,NDerivative, ~] = ShapeFunction([E1 E2 E3], ElementNodeCoordinate);
                ElementNodeDisplacement=U(ElementNodeDOF);
                ElementNodeDisplacement=reshape(ElementNodeDisplacement,Dof,8);
                % 计算高斯点应变 GausspointStrain3_3 3*3的应变矩阵
                GausspointStrain3_3=ElementNodeDisplacement*NDerivative';
                %把高斯点应变矩阵改写成6*1
                GausspointStrain=[GausspointStrain3_3(1,1) GausspointStrain3_3(2,2) GausspointStrain3_3(3,3) ...
                GausspointStrain3_3(1,2)+GausspointStrain3_3(2,1)....
                GausspointStrain3_3(2,3)+GausspointStrain3_3(3,2) GausspointStrain3_3(1,3)+GausspointStrain3_3(3,1)]';
                % 计算高斯点应力
                GausspointStress = D*GausspointStrain;
                GaussStrain(:,GaussPointNumber)=GausspointStrain;
                GaussStress(:,GaussPointNumber)=GausspointStress;
                InterpolationMatrix(K,:)=N;
                K=K+1;
            end
        end
    end
    %求得节点应力应变
    Temp1=InterpolationMatrix\(GaussStrain(1:6,GaussPointNumber-7:GaussPointNumber)');
    NodeStrain(1:6,INODE+1:INODE+8)=Temp1';
    Temp2=InterpolationMatrix\(GaussStress(1:6,GaussPointNumber-7:GaussPointNumber)');
    NodeStress(1:6,INODE+1:INODE+8)=Temp2';
    INODE=INODE+8;
end
end