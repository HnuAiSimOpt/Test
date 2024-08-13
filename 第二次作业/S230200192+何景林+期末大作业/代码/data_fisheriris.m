%Fisher Iris 数据
load fisheriris
% inputs1=[];
% inputs2=[];
% inputs3=[];
outputs1=[];
outputs2=[];
outputs3=[];

y=grp2idx(species);
N=max(size(species));
for i=1:N
    if strcmp(species(i),'setosa')
%         inputs1=[inputs1;meas(i,1:2)];
        outputs1=[outputs1;1];
    elseif strcmp(species(i),'versicolor')
%         inputs1=[inputs1;meas(i,1:2)];
        outputs1=[outputs1;-1];
    elseif strcmp(species(i),'virginica')
%         inputs1=[inputs1;meas(i,1:2)];
        outputs1=[outputs1;-1];
    end
end

for i=1:N
    if strcmp(species(i),'versicolor')
%         inputs2=[inputs2;meas(i,1:2)];
        outputs2=[outputs2;1];
    elseif strcmp(species(i),'setosa')
%         inputs2=[inputs2;meas(i,1:2)];
        outputs2=[outputs2;-1];
    elseif strcmp(species(i),'virginica')
%         inputs1=[inputs1;meas(i,1:2)];
        outputs2=[outputs2;-1];
    end
end

for i=1:N
    if strcmp(species(i),'virginica')
%         inputs3=[inputs3;meas(i,1:2)];
        outputs3=[outputs3;1];
    elseif strcmp(species(i),'versicolor')
%         inputs3=[inputs3;meas(i,1:2)];
        outputs3=[outputs3;-1];
    elseif strcmp(species(i),'setosa')
%         inputs1=[inputs1;meas(i,1:2)];
        outputs3=[outputs3;-1];
    end
end

X=meas;
y1 = outputs1;
y2 = outputs2;
y3 = outputs3;

s=rng(3456);
rand_num = randperm(size(X,1));
X_train = X(rand_num(1:round(0.8*length(rand_num))),:);
y_train = y(rand_num(1:round(0.8*length(rand_num))),:);
y1_train = y1(rand_num(1:round(0.8*length(rand_num))),:);
y2_train = y2(rand_num(1:round(0.8*length(rand_num))),:);
y3_train = y3(rand_num(1:round(0.8*length(rand_num))),:);

X_test = X(rand_num(round(0.8*length(rand_num))+1:end),:);
y_test = y(rand_num(round(0.8*length(rand_num))+1:end),:);
y1_test = y1(rand_num(round(0.8*length(rand_num))+1:end),:);
y2_test = y2(rand_num(round(0.8*length(rand_num))+1:end),:);
y3_test = y3(rand_num(round(0.8*length(rand_num))+1:end),:);




