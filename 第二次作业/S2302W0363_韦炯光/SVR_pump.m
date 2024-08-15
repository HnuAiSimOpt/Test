close all 
clear 
clc 

imp = readmatrix('时间位移振动信号.xlsx');
X = imp(:,1:end-1);
Y = imp(:,end);
x = mapminmax(X', 0, 1);
[y, psout] = mapminmax(Y', 0, 1);

num = size(imp,1);
sample = randperm(num); 
ratio = 0.7; 
tr_num = floor(num*ratio); 
x_tr = x(:,sample(1: tr_num))';
y_tr = y(sample(1: tr_num))';
x_te = x(:,sample(tr_num+1: end))';
y_te = y(sample(tr_num+1: end))';

model = fitrsvm(x_tr, y_tr, "KernelFunction","rbf",...  
    "Solver","ISDA",...  
    "KernelScale","auto"); 
res1 = predict(model, x_tr); 
res2 = predict(model, x_te );

Y_tr = Y(sample(1: tr_num)); 
Y_te = Y(sample(tr_num+1:end));

pre1 = mapminmax('reverse', res1, psout);
pre2 = mapminmax('reverse', res2, psout);

R1 = 1 - norm(Y_tr - pre1)^2 / norm(Y_tr - mean(Y_tr))^2;
R2 = 1 - norm(Y_te -  pre2)^2 / norm(Y_te -  mean(Y_te ))^2;

MAE1 = mean(abs(Y_tr - pre1 ));
MAE2 = mean(abs(pre2 - Y_te ));

RMSE1 = sqrt(mean((pre1 - Y_tr).^2));
RMSE2 = sqrt(mean((pre2 - Y_te).^2));

disp(['训练集的决定系数R2为：', num2str(R1)])
disp(['训练集的平方误差MAE为：', num2str(MAE1)])
disp(['训练集的均方根误差RMSE为：', num2str(RMSE1)])
disp(['测试集的决定系数R2为：', num2str(R2)])
disp(['测试集的平方误差MAE为：', num2str(MAE2)])
disp(['测试集的均方根误差RMSE为：', num2str(RMSE2)])

figure
plot(1: tr_num, Y_tr, 'r-^', 1: tr_num, pre1, 'b-+', 'LineWidth', 1)
legend('真实值','预测值')
xlabel('Sample size')
ylabel('Predictive value')

figure
plot(1: num-tr_num, Y_te, 'r-^', 1: num-tr_num, pre2, 'b-+', 'LineWidth', 1)
legend('真实值','预测值')
xlabel('Sample size')
ylabel('Predictive value')

figure
plot((pre1 - Y_tr )./Y_tr, 'r-o')
legend('百分比误差')
xlabel('Sample size')
ylabel('Error value')

figure
plot((pre2 - Y_te )./Y_te, 'r-o')
legend('百分比误差')
xlabel('Sample size')
ylabel('Error value')