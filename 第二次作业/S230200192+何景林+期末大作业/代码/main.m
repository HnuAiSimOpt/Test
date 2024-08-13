%main.m
close all;
clear all;
clc;
global  precision Cost
Kernel_Cell={'linear';'ploynomial';'RBF';'Sigmoid'};

% Step 1: 下载数据
% X 是具有 N × p 维数的输入数据矩阵
% 为方便可视化, 在这里定义p=2;
data_fisheriris;

% Step 2: 定义参数
% poly_con 是多项式核函数的参数
% gamma 是高斯核函数的参数
% kappa1 & kappa2 是Sigmoid 核函数的参数
% precision 是精度的容忍度
% Cost 是SVM的超参数
define_parameters;

% Step 3: 选择模型
% 选择核函数
kernel=char(Kernel_Cell(1));
% SVM设计
[alpha1,Ker1,beta01]=SVM(X_train,y1_train,kernel);
[alpha2,Ker2,beta02]=SVM(X_train,y2_train,kernel);
[alpha3,Ker3,beta03]=SVM(X_train,y3_train,kernel);
scores1 = SVM_pred(X_test, X_train, y1_train,kernel,alpha1,beta01);
scores2 = SVM_pred(X_test, X_train, y2_train,kernel,alpha2,beta02);
scores3_fig = SVM_pred(X_test, X_train, y3_train,kernel,alpha3,beta03);


pred_label=[];
for i=1:size(X_test,1)
    pred_label=[pred_label; find([scores1(i) scores2(i) scores3_fig(i)]==max([scores1(i) scores2(i) scores3_fig(i)]))];
end

accuracy=sum(pred_label==y_test)/length(y_test)*100;

% Step 4: 二维图形可视化
% SVM_plot(X_train,y1_train,y2_train,y3_train,...
%     alpha1,alpha2,alpha3,...
%     beta01,beta02,beta03,kernel);
SVM_plot(X_train(:,1:2),y1_train,alpha1,beta01,kernel)
% SVM_plot(X_train(:,1:2),y2_train,alpha2,beta02,kernel)
% SVM_plot(X_train(:,1:2),y3_train,alpha3,beta03,kernel)









% %% CV 分区
% 
% c = cvpartition(y1_train,'k',5);
% %% feature selection
% 
% opts = statset('display','iter');
% classf = @(train_data, train_labels, test_data, test_labels)...
%     sum(predict(fitcsvm(train_data, train_labels,'KernelFunction','rbf'), test_data) ~= test_labels);
% 
% [fs, history] = sequentialfs(classf, X_train, y1_train, 'cv', c, 'options', opts,'nfeatures',2);
% %% Best hyperparameter
% 
% X_train_w_best_feature = X_train(:,fs);
% 
% % [alpha1,Ker1,beta01]=SVM(X_train,y1_train,kernel);
% Md1 = fitcsvm(X_train_w_best_feature,y1_train,'KernelFunction','rbf','OptimizeHyperparameters','auto',...
%       'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
%       'expected-improvement-plus','ShowPlots',true)); % Bayes' Optimization ??.
% 
% 
% %% Final test with test set
% X_test_w_best_feature = X_test(:,fs);
% test_accuracy_for_iter = sum((predict(Md1,X_test_w_best_feature) == y1_test))/length(y1_test)*100
% 
% %% hyperplane ??
% 
% % ===================================
% figure;
% hgscatter = gscatter(X_train(:,1),X_train(:,2), y_train);
% legend('orginial setosa','orginal versicolor','orginal virginia')
% hold on;
% h_sv=plot(Md1.SupportVectors(:,1),Md1.SupportVectors(:,2),'ko','markersize',8);
% 
% 
% % test set? data? ?? ??? ????.
% 
% gscatter(X_test(:,1),X_test(:,2),y_test,'rbg','xxx')
% legend('orginial setosa','orginal versicolor','orginal virginia', 'new setosa', 'new versicolor','new virginia')
% % ===================================== 
% % decision plane
% XLIMs = get(gca,'xlim');
% YLIMs = get(gca,'ylim');
% % [xi,yi] = meshgrid([XLIMs(1):0.02:XLIMs(2)],[YLIMs(1):0.02:YLIMs(2)]);
% [xi,yi] = meshgrid(min(X_train(:,1)):0.02:max(X_train(:,1)),...
%     min(X_train(:,2)):0.02:max(X_train(:,2)));
% dd = [xi(:), yi(:)];
% scores1_fig = SVM_pred(dd, X_train(:,1:2), y1_train,kernel,alpha1,beta01);
% scores2_fig = SVM_pred(dd, X_train(:,1:2), y2_train,kernel,alpha2,beta02);
% scores3_fig = SVM_pred(dd, X_train(:,1:2), y3_train,kernel,alpha3,beta03);
% pred_label_fig=[];
% for i=1:size(X_test,1)
%     pred_label_fig=[pred_label_fig; find([scores1_fig(i) scores2_fig(i) scores3_fig(i)]==max([scores1_fig(i) scores2_fig(i) scores3_fig(i)]))];
% end
% pred_mesh = pred_label_fig;
% % pred_mesh = pred_label;
% redcolor = [1, 0.8, 0.8];
% greencolor = [0.8, 1, 0.8];
% bluecolor = [0.8, 0.8, 1];
% pos = find(pred_mesh == 1);
% h1 = plot(X_test(pos,1), X_test(pos,2),'s','color',redcolor,'Markersize',5,'MarkerEdgeColor',redcolor,'MarkerFaceColor',redcolor);
% pos = find(pred_mesh == 2);
% h2 = plot(X_test(pos,1), X_test(pos,2),'s','color',bluecolor,'Markersize',5,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
% pos = find(pred_mesh == 3);
% h3 = plot(X_test(pos,1), X_test(pos,2),'s','color',greencolor,'Markersize',5,'MarkerEdgeColor',bluecolor,'MarkerFaceColor',bluecolor);
% uistack(h1,'bottom');
% uistack(h2,'bottom');
% uistack(h3,'bottom');
% % % legend([hgscatter;h_sv],{'setosa','versicolor','support vectors'})
%  legend([hgscatter],{'setosa','versicolor','virginia'})





