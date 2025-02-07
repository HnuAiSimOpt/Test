                                        %%%%%%%%%主程序%%%%%%%%%%%
function Main()
%读取inp文件获得节点坐标信息Nodes及单元信息Elements
[Nodes, Elements] = Readmesh( 'DataFile.inp' );
% 外力矩阵 Forces=[受力节点  受力方向(1,2,3分别代表x,y,z)  外力大小]  外力节点的编号在inp文件里面找
Forces=[2 2 -500;3 2 -500;24 2 -500;25 2 -500;26 2 -500;27 2 -500;28 2 -500;29 2 -500;30 2 -500;]; 
%约束节点的编号在inp文件里面找
ConNumber=[9,12,  13,  14, 116, 117, 118, 119, 120, 121, 122, 141, 142, 143, 144, 145....
,146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161....
 ,516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531....
 ,532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547....
 ,548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563....
 ,564,];
%约束矩阵 Constraints=[强制位移节点  强制位移方向(1,2,3分别代表x,y,z)  强制位移大小]  
Constraints=zeros(size(ConNumber,2)*3,3);
for i=1:size(ConNumber,2)
Constraints(3*i-2:3*i,:)=[ConNumber(i) 1 0;ConNumber(i) 2 0;ConNumber(i) 3 0;];
end
E=210000; %弹性模量
u=0.3;    %泊松比
%调用应变应力矩阵D
D=LinearIsotropicD(E,u);
U=StaticsSolver(E,u,Forces,Constraints,Nodes,Elements);
% 输出结果
OutputTXT = fopen('Results.txt','w'); %打开一个可写文件，用于写入计算结果
OutputResults(OutputTXT,Nodes,Elements,D,U)%调用输出结果文件
fclose(OutputTXT);
edit('Results.txt')
end