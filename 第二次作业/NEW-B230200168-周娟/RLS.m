clear all;
b0=3.455;
b1=-0.2274;
b2=0.1187;
b3=1.3750e-4;
b4=0.09521;
b5=-0.002217;

load('battery_data');
tf=length(curr);

c(:,1)=[0.006;0.95;-0.006];
y(1)=3.3;
b(:,1)=[curr(1) 0 0]';%state
x=1;%forgetting factor
%chushihua
% c(:,1)=[0.9 0 0]';%estimated needed
P=10000*eye(3,3);

for k=2:tf
    E(k-1)=volt(k-1)-(b0 + b1*soc(k-1) + b2*soc(k-1)*soc(k-1) + b3/soc(k-1) + b4*log(soc(k-1)) + b5*log(1-soc(k-1)));
    E(k)=volt(k)-(b0 + b1*soc(k) + b2*soc(k)*soc(k) + b3/soc(k) + b4*log(soc(k)) + b5*log(1-soc(k)));
    b(:,k)=[curr(k) E(k-1) curr(k-1)]';
    e(k)=E(k)-b(:,k)'*c(:,(k-1));
    K=(P*b(:,k))/(x+b(:,k)'*P*b(:,k));
    P=(P-K*b(:,k)'*P)/x;
    c(:,k)=c(:,(k-1))+K*e(k);
    y(k)=b(:,k)'*c(:,(k-1))+(b0 + b1*soc(k) + b2*soc(k)*soc(k) + b3/soc(k) + b4*log(soc(k)) + b5*log(1-soc(k))); 
    para=c(:,k); 
    error(k)=y(k)-volt(k);
end

for k=1:tf
   r(k)=c(1,k);
   rps(k)=(c(3,k)+c(1,k)*c(2,k))/(1-c(2,k));
   cps(k)=(c(2,k)-1)/(c(3,k)+c(1,k)*c(2,k))/log(c(2,k));
end

figure;
plot(r, 'r','LineWidth',1.5);
set(gcf,'Unit','normalized','Position',[0.3,0.5,0.25,0.25]); % 设置Screen大小[位置x 位置y 长x 宽y]
set(gca,'linewidth',1.5,'fontsize',12,'fontname','Times New Roman','FontWeight','bold','GridColor',[0,0,0]);
xlabel('Time(s)');% lable
ylabel('R_0/(Ω)');

figure;
plot(rps, 'r','LineWidth',1.5);
set(gcf,'Unit','normalized','Position',[0.3,0.5,0.25,0.25]); % 设置Screen大小[位置x 位置y 长x 宽y]
set(gca,'linewidth',1.5,'fontsize',12,'fontname','Times New Roman','FontWeight','bold','GridColor',[0,0,0]);
xlabel('Time(s)');% lable
ylabel('R_d(Ω)');

figure;
plot(cps, 'r','LineWidth',1.5);
set(gcf,'Unit','normalized','Position',[0.3,0.5,0.25,0.25]); % 设置Screen大小[位置x 位置y 长x 宽y]
set(gca,'linewidth',1.5,'fontsize',12,'fontname','Times New Roman','FontWeight','bold','GridColor',[0,0,0]);
xlabel('Time(s)');% lable
ylabel('C_d(F)');

figure;
plot(volt,'b','LineWidth',1.5);hold on;
plot(y,'r--','LineWidth',1.5);
set(gcf,'Unit','normalized','Position',[0.3,0.5,0.25,0.25]); % 设置Screen大小[位置x 位置y 长x 宽y]
set(gca,'linewidth',1.5,'fontsize',12,'fontname','Times New Roman','FontWeight','bold','GridColor',[0,0,0]);
xlabel('Time(s)');% lable
ylabel('Voltage(V)');
legend('Real','Estimated');

figure;
plot(error,'r','LineWidth',1.5);
set(gcf,'Unit','normalized','Position',[0.3,0.5,0.25,0.25]); % 设置Screen大小[位置x 位置y 长x 宽y]
set(gca,'linewidth',1.5,'fontsize',12,'fontname','Times New Roman','FontWeight','bold','GridColor',[0,0,0]);
xlabel('Time(s)');% lable
ylabel('Voltage error(V)');