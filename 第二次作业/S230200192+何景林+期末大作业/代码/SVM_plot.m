function SVM_plot(X,Y,alpha,beta0,kernel)
% (X_test,X_train,y1_train,y2_train,y3_train,alpha1,alpha2,alpha3,beta01,beta02,beta03,kernel)
% (X,Y,alpha,beta0,kernel)

global Cost poly_con gamma kappa1
figure
hold on
P = size(X,2);

if P ~=2
   warning('# of input X should be 2 for the 2D visualization!!')
end
plot(X(Y==1,1),X(Y==1,2),'ro',...
    'LineWidth', 4,...
    'MarkerSize', 4);

plot(X(Y==-1,1),X(Y==-1,2),'bs',...
    'LineWidth', 4,...
    'MarkerSize', 4);

%
d = 0.02;
[x1Grid,x2Grid] = meshgrid(min(X(:,1)):d:max(X(:,1)),...
    min(X(:,2)):d:max(X(:,2)));
xGrid = [x1Grid(:),x2Grid(:)];
scores = SVM_pred(xGrid, X, Y,kernel,alpha,beta0);
% scores1 = SVM_pred(X_test, X_train, y1_train,kernel,alpha1,beta01);
% scores2 = SVM_pred(X_test, X_train, y2_train,kernel,alpha2,beta02);
% scores3 = SVM_pred(X_test, X_train, y3_train,kernel,alpha3,beta03);
% for i=1:size(X_test,1)
%     a=find([scores1(i) scores2(i) scores3(i)]==max([scores1(i) scores2(i) scores3(i)]));
% end
    

contour(x1Grid,x2Grid,reshape(scores,size(x1Grid)),[0 0],'k',...
    'LineWidth', 4);

xlabel('$X_1$','FontSize', 18,...
    'Interpreter','latex');
ylabel('$X_2$', 'FontSize', 18,...
    'Interpreter','latex');
switch kernel
    case 'linear'
        title({'SVM',strcat('Kernel:',kernel,';C=',num2str(Cost))}, 'FontSize', 18,...
    'Interpreter','latex');
    case 'ploynomial'
        title({'SVM',strcat('Kernel:',kernel,';C=',num2str(Cost),';n=',num2str(poly_con))}, 'FontSize', 18,...
    'Interpreter','latex');
    case 'RBF'
        title({'SVM',strcat('Kernel:',kernel,';C=',num2str(Cost),';$\gamma$=',num2str(gamma))}, 'FontSize', 18,...
    'Interpreter','latex');
    case 'Sigmoid'
        title({'SVM',strcat('Kernel:',kernel,';C=',num2str(Cost),';$\kappa$=',num2str(kappa1))}, 'FontSize', 18,...
    'Interpreter','latex');
end
legend({'+1:setosa';'-1:versicolor'},'FontSize',16,'Location', 'Best');
hold off
% Maximize figure
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% str_fig = strcat('SVM_',kernel,'_C=',num2str(Cost));
% saveas(gcf, str_fig,'png');
% saveas(gcf, str_fig);
return