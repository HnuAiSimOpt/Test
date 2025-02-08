%%%%%%%%%%%  一阶六面体单元单位刚度矩阵  %%%%%%%%%%
% Ke单位刚度矩阵
% D计算各向同性线弹性材料应力-应变矩阵  
% ElementNodeCoordinate单元节点坐标（8*3，每一行代表一个节点的坐标）
function [Ke]=Ke(D, ElementNodeCoordinate)
% 高斯积分点坐标
GaussCoordinate=[-0.57735026918963D0, 0.57735026918963D0];
%高斯积分点权重
GaussWeight=[1.00000000000000D0, 1.00000000000000D0];
%初始化单元刚度阵
Ke=zeros(24,24);
%循环高斯点
for X=1:2
    for Y=1:2
        for Z=1:2
            GP1=GaussCoordinate(X); GP2=GaussCoordinate(Y); GP3=GaussCoordinate(Z); %高斯点坐标
            % 计算形函数对总体坐标的导数（NDerivative）及雅可比矩阵行列式（JacobiDET）
            [~,NDerivative, JacobiDET] = ShapeFunction([GP1 GP2 GP3], ElementNodeCoordinate);
            Coefficient=GaussWeight(X)*GaussWeight(Y)*GaussWeight(Z)*JacobiDET;
            %计算B矩阵  利用形函数对总体坐标的导数（NDerivative）对B进行计算
            B=zeros(6,24);
            for I=1:8
                COL=(I-1)*3+1:(I-1)*3+3;
                B(:,COL)=[NDerivative(1,I) 0         0;
                    0         NDerivative(2,I) 0;
                    0         0         NDerivative(3,I);
                    NDerivative(2,I) NDerivative(1,I) 0;
                    0         NDerivative(3,I) NDerivative(2,I);
                    NDerivative(3,I) 0         NDerivative(1,I)];
            end
            Ke=Ke+Coefficient*B'*D*B;  %叠加刚度阵
        end
    end
end
end