clear;
clc;
%------------装载数据
input=load('shuju.txt');
for i=1:size(input,2)
    maxinput=max(input(:,i));
    input(:,i)=input(:,i)/max(input(:,i));
end
save shuju1.txt -ascii input;
train_x= load('shuju1.txt');
[m,n]= size(train_x);
%-----------定义模型
generator=nnsetup([5,15,5]);
discriminator=nnsetup([5,15,1]);
%----------参数设置
batch_size= m; 
iteration= 10000;
images_num= m;
batch_num= floor(images_num / batch_size);
learning_rate= 0.001;
for i = 1: iteration
    kk = randperm(images_num);
    images_real = train_x;
    noise = unifrnd(0,1,m,5);
    %开始训练
    %--------更新生成器，固定住辨别器
    generator = nnff(generator, noise);
    images_fake = generator.layers{generator.layers_count}.a; 
    discriminator = nnff(discriminator,images_fake);
    logits_fake = discriminator.layers{discriminator.layers_count}.z;
    discriminator = nnbp_d(discriminator, logits_fake, ones(batch_size, 1));
    generator = nnbp_g(generator, discriminator);
    generator = nnapplygrade(generator, learning_rate);
    %------更新辨别器，固定住生成器
    generator = nnff(generator, noise);
    images_fake = generator.layers{generator.layers_count}.a;
    images = [images_fake; images_real]; 
    discriminator = nnff(discriminator, images);
    logits = discriminator.layers{discriminator.layers_count}.z;
    labels = [zeros(batch_size,1); ones(batch_size,1)];
    discriminator = nnbp_d(discriminator, logits, labels);
    discriminator = nnapplygrade(discriminator, learning_rate);
    %----输出loss损失
    c_loss(i,:) = sigmoid_cross_entropy(logits(1:batch_size), ones(batch_size,1));
    d_loss (i,:)= sigmoid_cross_entropy(logits, labels);
end 
%% BiLSTM
demands=images(1:162,5);
orgin=images(1:162,1:4);
in=orgin;
out=demands;
i=1;
while ~isempty(in)
    pick=4;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        X{i}=in';
        Y(i)=out(end);
        break;
    end
end
%% 网络参数设置
inputSize = 4;
numHiddenUnits = 110;
layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(1)
    regressionLayer];
maxEpochs = 1750;
options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'InitialLearnRate',0.01, ...
    'GradientThreshold',1, ...
    'Shuffle','never', ...
    'Plots','training-progress',...
    'Verbose',0);
%% 训练
net = trainNetwork(X,Y',layers,options);
save('net.mat','net')
trainY=double(predict(net,X));
figure, ploterrhist(trainY-Y')
figure, plot(trainY,'-o')
hold on
plot(Y,'-^')
title('微磨具磨损训练结果')
xlabel('数据组数')
ylabel('归一化处理后磨损值');
legend('BiLSTM模型预测值','实际磨损值','Location','NorthWest')
%% 测试数据处理
clear X Y
demands=images(162:180,5);
orgin=images(162:180,1:4);
in=orgin;
out=demands;
i=1;
while ~isempty(in)
    pick=4;
    if pick<=size(in,1)
        X{i}=(in(1:pick,:))';
        Y(i)=out(pick);
        in(1,:)=[];
        out(1,:)=[];
        i=i+1;
    else
        X{i}=in';
        Y(i)=out(end);
        break
    end
end
%% 测试
testY=double(predict(net,X));
figure, ploterrhist(testY-Y'), title('test')
figure, plot(testY,'-o')
hold on
plot(Y,'-^')
title('微磨具磨损预测结果')
xlabel('数据组数')
ylabel('归一化处理后磨损值');
legend('BiLSTM模型预测值','实际磨损值','Location','NorthWest')
%% 计算误差
RMSE=sqrt(mean((testY-Y').^2))
R=corrcoef(testY,Y')
r=R(1,2)
disp(['均方根误差',num2str(RMSE)])
disp(['决定系数R^2为',num2str(r)])
% sigmoid函数
function output = sigmoid(x)
    output = 1 ./(1+exp(-x));
end
%relu函数
function output = relu(x)
    output = max(x,0);
end 
%relu对x的导数
function output = delta_relu(x)
    output = max(x,0);
    output(output>0) = 1;
end
%sigmoid交叉熵损失函数
function result = sigmoid_cross_entropy(logits,labels)
    result = max(logits,0) - logits .* labels + log(1+exp(-abs(logits)));
    result = mean(result);
end
%sigmoid_cross_entropy对logits的导数=
function result = delta_sigmoid_cross_entropy(logits,labels)
    temp1 = max(logits, 0);
    temp1(temp1>0) = 1;
    temp2 = logits;
    temp2(temp2>0) = -1;
    temp2(temp2<0) = 1;
    result = temp1- labels +exp(-abs(logits))./(1+exp(-abs(logits))) .*temp2;
end
%根据所给的结构构建神经网络
function nn = nnsetup(architecture)
    nn.architecture = architecture;
    nn.layers_count = numel(nn.architecture);
    %adam优化器所用参数
    nn.t=0;
    nn.beta1 = 0.9;
    nn.beta2 = 0.999;
    nn.epsilon = 10^(-8);
    %----------------------
    for i=2 : nn.layers_count
        nn.layers{i}.w = normrnd(0, 0.02, nn.architecture(i-1), nn.architecture(i));
        nn.layers{i}.b = normrnd(0, 0.02, 1, nn.architecture(i));
        nn.layers{i}.w_m = 0;
        nn.layers{i}.w_v = 0;
        nn.layers{i}.b_m = 0;
        nn.layers{i}.b_v = 0;
    end
end
%前向传播
function nn = nnff(nn, x)
    nn.layers{1}.a = x;
    for i = 2 : nn.layers_count
        input = nn.layers{i-1}.a;
        w = nn.layers{i}.w;
        b = nn.layers{i}.b;
        nn.layers{i}.z = input *w + repmat(b, size(input,1), 1); 
        if i ~= nn.layers_count
            nn.layers{i}.a = relu(nn.layers{i}.z); 
        else
            nn.layers{i}.a = sigmoid(nn.layers{i}.z);
        end
    end
 
end
%discriminator辨别器的bp反传
function nn = nnbp_d(nn, y_h, y)
    %d表示残差
    n = nn.layers_count;
    %最后一层的残差
    nn.layers{n}.d = delta_sigmoid_cross_entropy(y_h, y); 
    for i = n-1 : -1:2 
        d = nn.layers{i+1}.d;
        w = nn.layers{i+1}.w;
        z = nn.layers{i}.z;
        nn.layers{i}.d = d * w' .* delta_relu(z);
    end
    for i = 2: n
        d = nn.layers{i}.d;
        a = nn.layers{i-1}.a;
        nn.layers{i}.dw = a'*d /size(d,1);
        nn.layers{i}.db = mean(d,1);
    end
end
function g_net = nnbp_g(g_net, d_net)
    n = g_net.layers_count;
    a = g_net.layers{n}.a;
    % generator的loss是由label_fake得到的，(images_fake过discriminator得到label_fake)
    % 对g进行bp的时候，可以将g和d看成是一个整体
    % g最后一层的残差等于d第2层的残差乘上(a .* (a_o))
    g_net.layers{n}.d = d_net.layers{2}.d * d_net.layers{2}.w' .* (a .* (1-a));
    for i = n-1:-1:2
        d = g_net.layers{i+1}.d;
        w = g_net.layers{i+1}.w;
        z = g_net.layers{i}.z;
        % 每一层的残差是对每一层的未激活值求偏导数，所以是后一层的残差乘上w,再乘上对激活值对未激活值的偏导数
        g_net.layers{i}.d = d*w' .* delta_relu(z);    
    end
    % 求出各层的残差之后，就可以根据残差求出最终loss对weights和biases的偏导数
    for i = 2:n
        d = g_net.layers{i}.d;
        a = g_net.layers{i-1}.a;
        % dw是对每层的weights进行偏导数的求解
        g_net.layers{i}.dw = a'*d / size(d, 1);
        g_net.layers{i}.db = mean(d, 1);
    end
end
%Adam优化器
function nn = nnapplygrade(nn, learning_rate);
    n = nn.layers_count;
    nn.t = nn.t+1;
    beta1 = nn.beta1;
    beta2 = nn.beta2;
    lr = learning_rate * sqrt(1-nn.beta2^nn.t) / (1-nn.beta1^nn.t);
    for i = 2:n
        dw = nn.layers{i}.dw;
        db = nn.layers{i}.db;
        %使用adam更新权重与偏置
        nn.layers{i}.w_m = beta1 * nn.layers{i}.w_m + (1-beta1) * dw;
        nn.layers{i}.w_v = beta2 * nn.layers{i}.w_v + (1-beta2) * (dw.*dw);
        nn.layers{i}.w = nn.layers{i}.w -lr * nn.layers{i}.w_m ./ (sqrt(nn.layers{i}.w_v) + nn.epsilon);
        nn.layers{i}.b_m = beta1 * nn.layers{i}.b_m + (1-beta1) * db;
        nn.layers{i}.b_v = beta2 * nn.layers{i}.b_v + (1-beta2) * (db .* db);
        nn.layers{i}.b = nn.layers{i}.b -lr * nn.layers{i}.b_m ./ (sqrt(nn.layers{i}.b_v) + nn.epsilon);        
    end
    
end
%%initialization初始化，生成随机高斯变量
function parameter=initializeGaussian(parameterSize,sigma)
if nargin < 2
    sigma=0.05;
end
parameter=randn(parameterSize,'double') .* sigma;%sigma是标准差，.*sigma是为了让生成的正太分布的随机数满足标准差为sigma,标准差越大，离散程度越大，图形越平缓，反之，图形越陡，数据越集中，越靠近均值
end