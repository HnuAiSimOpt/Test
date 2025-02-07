%%%%%%%%%%%  一阶六面体单元输出结果程序(输出txt文件及云图)  %%%%%%%%%%%
%  OutputTXT输出信息保存位置
%  Nodes节点坐标信息 
%  Elements单元信息
%  D计算各向同性线弹性材料应力-应变矩阵
%  U位移矩阵
function OutputResults(OutputTXT,Nodes,Elements,D,U)
NodeCount = size(Nodes,1) ;  % 节点个数
ElementCount= size(Elements,1);%单元个数
ElementNodeCount=8;% 每个单元节点数
Dof=3; 
%计算高斯点、节点应力应变值
[~,NodeStress,GaussStrain,GaussStress]=CalculateStrainAndStress(U,D,Nodes,Elements);
%求得MISES应力矩阵
MISES=zeros(1,ElementCount*ElementNodeCount);
for I=1:ElementCount*ElementNodeCount
    MISES(I)=sqrt(0.5)*sqrt((NodeStress(1,I)-NodeStress(2,I))^2+(NodeStress(1,I)-NodeStress(3,I))^2+....
        (NodeStress(2,I)-NodeStress(3,I))^2+6*(NodeStress(4,I)^2+NodeStress(5,I)^2+NodeStress(6,I)^2));
end
%求得Umag位移矩阵
Umag=zeros(NodeCount,1);
for i=1:NodeCount
    Umag(i)=sqrt(U(3*i-2)^2+U(3*i-1)^2+U(3*i)^2);
end
  %将文节点位移、高斯点应力应变写入TXT中
  fprintf(OutputTXT,'\r\n Node          U1          U2          U3');
  for I=1:NodeCount
    II=Dof*(I-1);
    fprintf(OutputTXT,'\r\n%5d %11.3e %11.3e %11.3e',I,U(II+1:II+3)+0);
  end
  fprintf(OutputTXT,'\r\n\r\nElement GaussStrain\r\n');
  fprintf(OutputTXT,'\r\n        E11         E22         E33         E12         E23         E13');
  for I=1:ElementCount
    fprintf(OutputTXT,'\r\nElement %5d',I);
    II=(I-1)*8;
    fprintf(OutputTXT,'\r\n%11.3e %11.3e %11.3e %11.3e %11.3e %11.3e',GaussStrain(1:6,II+1:II+8));
  end
  fprintf(OutputTXT,'\r\n\r\nElement GaussStress\r\n');
  fprintf(OutputTXT,'\r\n        S11         S22         S33         S12         S23         S13');
  for I=1:ElementCount
    fprintf(OutputTXT,'\r\nElement %5d',I);
    II=(I-1)*8;
    fprintf(OutputTXT,'\r\n%11.3e %11.3e %11.3e %11.3e %11.3e %11.3e',GaussStress(1:6,II+1:II+8));
  end
  fprintf(OutputTXT,'\r\n\r\n');
  fprintf(1,'\t\t *** Successful end of program ***\n');
%绘制变形前网格
  for i=1:1:size(Elements,1)
    points=Nodes(Elements(i,:),:);
    mesh=1:1:8;%网格信息
    %六面体单元节点坐标
    vertices_matrix = [points(mesh(1,:),1),points(mesh(1,:),2),points(mesh(1,:),3)];
    %六面体单元节点顺序
    faces_matrix= [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];%给出每个面的节点序号
    patch('vertices', vertices_matrix,'faces',faces_matrix,'facecolor','g');
    view(3);hold on%绘图
  end
axis equal
alpha(1);
 %输出位移、应力、应变云图
for i=1:Dof %输出U1-U3
    PlotContour(Nodes,Elements,U,U(i:3:size(U,1)))
    title(['U',num2str(i)]);%绘制云图标题
end 
%绘制Umag云图
PlotContour(Nodes,Elements,U,Umag)
title('Umag')
end