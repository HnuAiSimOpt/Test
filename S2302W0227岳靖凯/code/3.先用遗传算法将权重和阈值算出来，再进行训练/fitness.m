function fitness_value=fitness1(input_chrom,input_num,hidden_num,output_num,input_data,output_data)
%该函数用来计算适应度值
%input_chrom     输入种群
%input_num        输入层的节点数，即数据特征数量
%output_num      隐含层节点数,隐藏层神经元的个数
%input_data        训练输入数据
%output_data     训练输出数据
%fitness_value    个体适应度值
w1=input_chrom(1:input_num*hidden_num);   %输入和隐藏层之间的权重参数
B1=input_chrom(input_num*hidden_num+1:input_num*hidden_num+hidden_num); %隐藏层神经元的偏置
w2=input_chrom(input_num*hidden_num+hidden_num+1:input_num*hidden_num+...
    hidden_num+hidden_num*output_num);  %隐藏层和输出层之间的偏置
B2=input_chrom(input_num*hidden_num+hidden_num+hidden_num*output_num+1:input_num*hidden_num+...
    hidden_num+hidden_num*output_num+output_num); %输出层神经元的偏置
% %网络权值赋值
net=newff(input_data,output_data,hidden_num,{'tansig','purelin'});
%网络进化参数
net.trainParam.epochs=20;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00001;
net.trainParam.show=100;
net.trainParam.showWindow=0;
%网络权值赋值
net.iw{1,1}=reshape(w1,hidden_num,input_num); %信息见csdn %重组

net.lw{2,1}=reshape(w2,output_num,hidden_num);

net.b{1}=reshape(B1,hidden_num,1);

net.b{2}=reshape(B2,output_num,1);

%网络训练
net=train(net,input_data,output_data);
pre=sim(net,input_data);
error=sum(sum(abs(pre-output_data)));
fitness_value=error; %误差即为适应度
end
%%！！！？不懂？？在网络训练里面会训练权重的大小值吗
%这个和另外一个相比，多了一个网络训练
%但是并没有返回修正过后的权值