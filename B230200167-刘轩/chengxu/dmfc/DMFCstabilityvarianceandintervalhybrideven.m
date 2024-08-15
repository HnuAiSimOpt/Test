clear all
clc
warning off
fluctuatingall=0.2:0.0025:0.2;
Ngeneral=size(fluctuatingall,2);
y1=zeros(1,Ngeneral);
y2=zeros(1,Ngeneral);
for igeneral=1:Ngeneral
    jjpoint=[];
    fluctuating=fluctuatingall(igeneral);
LB=[298,3.5,0.25,81.2];
UB=[343,5.5,2,140.8];
Vsetvalue=0.3;
jinput=0.015:(0.065-0.015)/99:0.065;
%jj=0.0003;
jj=0.015;
iterationno=size(jinput,2);
N=1;
Nparameters=0;
w1=0.5;
w2=0.5;
%Mecomsumption=[];
Mecomsumptionall=0;
%Woutput=[];
Woutputincrease=0;
Woutputall=0;
while jj<0.065
    Nparameters=Nparameters+1;
    ff=@(xx)(w1.*sqrt((DMFCvoltagedeviationcalculation(xx,jj)-Vsetvalue).^2+(DMFCvoltagedeviationcalculation(xx,jj+currentvariedinterval(xx,Vsetvalue,jj,fluctuating))-Vsetvalue).^2)./1.4+w2.*0.008./currentvariedinterval(xx,Vsetvalue,jj,fluctuating));
    %ff=@(xx)(w1.*sqrt((DMFCvoltagedeviationcalculation(xx,jj)-Vsetvalue).^2+(DMFCvoltagedeviationcalculation(xx,jj+currentvariedinterval(xx,Vsetvalue,jj,fluctuating))-Vsetvalue).^2)./1.4);
      xx = simulannealbnd(ff,[343,4.5,1,140.8],LB,UB);
      %xx = pso(ff,4,[],[],[],[],LB,UB);
    if currentvariedinterval(xx,Vsetvalue,jj,fluctuating)<0.01
        ff1=@(xx)(sqrt((DMFCvoltagedeviationcalculation(xx,jj)-Vsetvalue).^2+(DMFCvoltagedeviationcalculation(xx,jj+0.01)-Vsetvalue).^2));
        xx = simulannealbnd(ff1,[343,4.5,1,140.8],LB,UB);
        %xx = pso(ff1,4,[],[],[],[],LB,UB);
        %xx=x;
        xxall(Nparameters,:)=xx;
        jjinitial=jj;
        jj=jj+0.01;
        if jj>0.065
            jj=0.065;

        end
    else
        %xx = ga(ff,4,[],[],[],[],LB,UB);
        xxall(Nparameters,:)=xx;
        jjinitial=jj;
        jj=jj+currentvariedinterval(xx,Vsetvalue,jj,fluctuating);
        if jj>0.065
            jj=0.065;
        end
    end
    output=DMFCvoltagedeviationcalculation(xx,jinput);
    outputall(:,Nparameters)=output';
    jjpoint(Nparameters,:)=jj;
    
    jjall=jjinitial:(jj-jjinitial)/9:jj;
    jjall=jjall';
    jjiterationno=size(jjall,1);
    pointall(N:N+jjiterationno-2,1)=jjall(1:jjiterationno-1,1);
    pointall(N:N+jjiterationno-2,2)=DMFCvoltagedeviationcalculation(xx,jjall(1:jjiterationno-1,:)); 
    N=N+jjiterationno-1;

%     if jj>0.04
%         w1=1;
%         w2=0.5;
%     end
%     
end
Woutput=zeros(1,Nparameters);
Mecomsumption=zeros(1,Nparameters);
for i=1:Nparameters
    if i==1
    jjsectionstart=0.01;
    jjsectionend=jjpoint(i);
    else
    jjsectionstart=jjpoint(i-1);
    jjsectionend=jjpoint(i);
    end
     Mecomsumption(i)=(jjsectionend-jjsectionstart)/0.06*60*xxall(i,2)*xxall(i,3)*0.001;
     jjsection=jjsectionstart:0.0001:jjsectionend;
     currentsectionno=size(jjsection,2);
        for ii=1:currentsectionno-1
            Woutputincrease=0.5*(DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii))+DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii+1))).*jjsection(ii)*10*0.0001/0.06*60*60;
            Woutput(i)=Woutput(i)+Woutputincrease;
        end

%%
% for i=1:Nparameters
%     if i==1
%     jjsectionstart=0.01;
%     jjsectionend=jjpoint(i);
%     else
%     jjsectionstart=jjpoint(i-1);
%     jjsectionend=jjpoint(i);
%     end
%     if jjsectionstart>=0.02&&jjsectionend<=0.06
%         Mecomsumption(i)=(jjsectionend-jjsectionstart)/0.04*48*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=jjsectionstart:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.04*48*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
%     if jjsectionend<=0.02
%         Mecomsumption(i)=(jjsectionend-jjsectionstart)/0.01*6*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=jjsectionstart:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
%     if jjsectionstart<=0.02&&jjsectionend>0.02
%         Mecomsumption(i)=(jjsectionend-0.02)/0.04*48*xxall(i,2)*xxall(i,3)*0.001+(0.02-jjsectionstart)/0.01*6*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=jjsectionstart:0.0001:0.02;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%         jjsection=0.02:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.04*48*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
%     if jjsectionstart<=0.06&&jjsectionend>0.06
%         Mecomsumption(i)=(jjsectionend-0.06)/0.01*6*xxall(i,2)*xxall(i,3)*0.001+(0.06-jjsectionstart)/0.04*48*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=jjsectionstart:0.0001:0.06;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.04*48*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%         jjsection=0.06:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
%     if jjsectionstart<=0.02&&jjsectionend>0.06
%         Mecomsumption(i)=((jjsectionend-0.06)+(0.02-jjsectionstart))/0.01*6*xxall(i,2)*xxall(i,3)*0.001+(0.06-0.02)/0.04*48*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=jjsectionstart:0.0001:0.02;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%         jjsection=0.02:0.0001:0.06;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.04*48*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%         jjsection=0.06:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
%     if jjsectionstart>0.06
%         Mecomsumption(i)=(jjsectionend-jjsectionstart)/0.01*6*xxall(i,2)*xxall(i,3)*0.001;
%         jjsection=0.06:0.0001:jjsectionend;
%         currentsectionno=size(jjsection,2);
%         for ii=1:currentsectionno-1
%             Woutputincrease=DMFCvoltagedeviationcalculation(xxall(i,:),jjsection(ii)).*jjsection(ii)*10*0.0001/0.01*6*60;
%             Woutput(i)=Woutput(i)+Woutputincrease;
%         end
%     end
% 
%     %Mecomsumptionall=Mecomsumptionall+Mecomsumption(i);

end
    Mecomsumptionall=sum(Mecomsumption);
    Woutputall=sum(Woutput);
    Ratio=Woutputall/Mecomsumptionall;
y1(igeneral)=Nparameters;
y2(igeneral)=Woutputall;
y3(igeneral)=Mecomsumptionall;
end
rs = regrply(y3',fluctuatingall',5);
fff=@(x)predply2(x,rs,NaN,0.01);
xfit=0.05:0.0001:0.3;
xfit=xfit';
%plotyy(fluctuatingall,y1,xfit,fff(xfit))
%plotyy(fluctuatingall,y1,fluctuatingall,y2./y3)

plot(pointall(:,1),pointall(:,2),'b-')
hold on
plot(0:0.0008:0.08,Vsetvalue.*ones(1,101),'r-')
for i=1:Nparameters
    plot(jinput,outputall(:,i),'k-')
end



