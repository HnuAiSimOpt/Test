clc;
clear;
LB=[2;1;1;1.5;1.5];
UB=[3;2.5;2.5;3;3]; %设计变量的上下界
[x,fval]=ga(@fun,5,[],[],[],[],LB,UB,@nlinconst); %GA 工具箱
options=gaoptimset('Generations',300);
rand('state',71);
randn('state',59);
record=[ ];
for n=0:0.05:1
options=gaoptimset(options,'CrossoverFraction',n);
[x fval]=ga(@rastriginsfcn,10,options);
record = [record;fval];
end
plot(0:0.05:1,record);
xlabel('Crossover Fraction');
ylabel('fval')