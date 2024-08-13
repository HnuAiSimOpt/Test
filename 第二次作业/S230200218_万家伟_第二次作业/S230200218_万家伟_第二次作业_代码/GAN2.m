clear; clc; %%%clc是清除当前command区域的命令,表示清空,看着舒服些 。而clear用于清空环境变量。两者是不同的。

%%%装载数据集
input=load('shuju.txt');
for i=1:size(input,2)
    maxinput=max(input(:,i));
    inputm(:,i)=input(:,i)/max(input(:,i));
end
save shuju1.txt -ascii inputm;
train_x= load('shuju1.txt');%train_x就是我们希望GAN网络能够生成与其相似的数据。

[m,n]=size(train_x);%m表示train_x有多少行，n表示有多少列。

%%%定义模型

generator=nnsetup([30,15,30]);%第一个30代表第一层有30个神经元，这是要与train_x的维度相同的，最后一个30也是要与train_x的维度相同。

discriminator=nnsetup([30,15,1]);%第一个30要与生成器的最后一层的神经元个数相同，最后一层是1个神经元，输出的是每个样本来自于真实数据的概率。

%%参数设置

batch_size=m; %batchsize表示一次输入多少样本进行训练，因为我的数据量少，直接全部输入进去就行了。

iteration=100;%迭代多少次，或者说走多少次正向传播。

images_num=m;

batch_num=floor(images_num / batch_size);

learning_rate=0.0001;

function nn=nnsetup(architecture)

nn.architecture= architecture;%%%把预定义的网络结构传递给nn（neuron network）这个结构体

nn.layers_count= numel(nn.architecture);% 计算传递过来的网络结构有多少层

%%%%%%%adam优化器需要设置的参数%%%

nn.t=0;

nn.beta1=0.9;

nn.beta2=0.999;

nn.epsilon=10^(-8);

%%%%%%%%%%%%%%%%%%%%%%%

for  i=2:nn.layers_count

nn.layers{i}.w=normrnd(0,0.02,nn.architecture(i-1),nn.architecture(i));%normrnd是指生成正态分布的随机数，第一个数字0表示均值为0，第二个数字0.02表示sigma=0.02,第三个值表示生成的维度大小。例如第三与第四的值分别为30,15，则表示生成30*15的矩阵。

nn.layers{i}.b = normrnd(0, 0.02, 1, nn.architecture(i));%生成偏置
        nn.layers{i}.w_m = 0;%好像是跟权重偏置有关的参数，但是都设置为了0，好像没啥意义。
        nn.layers{i}.w_v = 0;
        nn.layers{i}.b_m = 0;
        nn.layers{i}.b_v = 0;

end 

end

function nn=nnff(nn,x)

        nn.layers{1}.a=x;%%%将数据集x作为输入层

        for i=2:nn.layers_count %%%%nn.layers_count在传入nn时，就已经是网络的层数了

                input=nn.layers{i-1}.a;

                w=nn.layers{i}.w;

                b=nn.layers{i}.b;

                nn.layers{i}.z=input * w +repmat(b,size(input,1),1);

                if i~=nn.layers_count

                        nn.layers{i}.a=relu(nn.layers{i}.z);%%%%如果不是最后一层，就过relu激活函数

                else

                        nn.layers{i}.a=sigmoid(nn.layers{i}.z);

                end

        end

end


function nn=nnbp_d(nn, y_h, y)

%判别器的输入是生成器的最后一层，输出的数据Fake data 和我们手头有的真实数据train_x，即real data

n=nn.layers_count;

nn.layers{n}.d=delta_sigmoid_cross_entropy(y_h,y); %%%%nn.layers{n}.d表示最后一层的残差

for i=n-1:-1:2%%%n是i的初始值，1是终止值，-1是步长。即从i=n开始，每次都加 -1，即减1，直到i等于1为止.

        d=nn.layers{i+1}.d;

        w=nn.layers{i+1}.w;

        z=nn.layers{i}.z;

        nn.layers{i}.d=d*w' .*delta_relu(z);

end

for i=2:n

        d=nn.layers{i}.d;

        a=nn.layers{i-1}.a;

        nn.layers{i}.dw=a'*d /size(d,1);

        nn.layers{i}.db=mean(d,1);

end

end

function g_net=nnbp_g(g_net,d_net)

        n=g_net.layers_count;

        a=g_net.layers{n}.a;

        g_net.layers{n}.d=d_net.layers{2}.d*d_net.layers{2}.w' .* (a .*(1-a));

        for i=n-1:-1:2

                d=g_net.layers{i+1}.d;

                w=g_net.layers{i+1}.w;

                z=g_net.layers{i}.z;

                g_net.layers{i}.d=d*w' .* delta_relu(z);

        end

        %计算偏导数

        for i=2:n

               d=g_net.layers{i}.d;

                a=g_net.layers{i-1}.a;

                g_net.layers{i}.dw=a'*d/size(d,1); 

                g_net.layers{i}.db=mean(d,1);

        end

end

%%%sigmoid激活函数

function output=sigmoid(x)

        output=1 ./(1+exp(-x));

end

%%%relu激活函数

function output=relu(x)

        output=max(x,0);

end

%%%Leaky_Relu激活函数

function output = Leaky_ReLU(x)
a=2;
if x>=0
    output=x;
else
    output=x/a;
end
end

%%%%损失函数

%relu对x的导数

function output=delta_relu(x)

        output=max(x,0);

        output(output>0)=1;

end

%%%%sigmoid交叉熵损失函数

function result=sigmoid_cross_entropy(logits,labels)

        result=max(logits,0) -logits .*labels +log(1+exp(-abs(logits)));

        result=mean(result);

end

%%%sigmoid交叉熵对logits的导数

function result=delta_sigmoid_cross_entropy(logits, labels)

        temp1=max(logits,0);

        temp1(temp1>0)=1;

        temp2=logits;

        temp2(temp2>0)=-1;

        temp2(temp2<0)=1;

        result=temp1-labels+exp(-abs(logits)) ./ (1+exp(-abs(logits))) .* temp2;

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

for i=1:iteration

        kk=randperm(images_num);

        images_real=train_x;

        noise=unifrnd(0,1,m,30);

        generator=nnff(generator,noise);

        images_fake=generator.layers{generator.layers_count}.a;

        discriminator=nnff(discriminator,images_fake);

        logits_fake=discriminator.layers{discriminator.layers_count}.z;

        discriminator=nnbp_d(discriminator, logits_fake, ones(batch_size,1));

        generator= nnbp_g(generator, discriminator);

        generator=nnbp_g(generator, discriminator);

        generator=nnapplygrade(generator,learning_rate);

        %%%%%%%开始更新判别器

        generator=nnff(generator,noise);

        images_fake=generator.layers{generator.layers_count}.a;

        images=[images_fake;images_real];

        discriminator=nnff(discriminator,images);

        logits=discriminator.layers{discriminator.layers_count}.z;

        logits = discriminator.layers{discriminator.layers_count}.z;
    labels = [zeros(batch_size,1); ones(batch_size,1)];%预定义一个标签，前面的数据是0，后面的是1，也进行了拼接。
    discriminator = nnbp_d(discriminator, logits, labels);%logits与真实的标签进行对比，注意与第29行代码进行对比。
    discriminator = nnapplygrade(discriminator, learning_rate);%更新了辨别器网络的权重。
    
    %----输出loss损失
    c_loss(i,:) = sigmoid_cross_entropy(logits(1:batch_size), ones(batch_size,1));%这是生成器的损失
    d_loss (i,:)= sigmoid_cross_entropy(logits, labels);%判别器的损失

end
