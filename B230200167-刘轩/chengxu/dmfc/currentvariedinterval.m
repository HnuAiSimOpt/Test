function y=currentvariedinterval(xx,Vsetvalue,jj,fluctuating)
  if (0.06-jj)>0.01
    currentsectionnumber=29;
  elseif (0.06-jj)>0.003
    currentsectionnumber=9;
  else
    currentsectionnumber=1;  
  end
jinput=jj:(0.06-jj)/currentsectionnumber:0.06;
iterationno=size(jinput,2);
voutput=[];
for i=1:iterationno
    voutput(i)=DMFCvoltagedeviationcalculation(xx,jinput(i));
    if jinput(i)==0.06
        jend=jinput(i);
        break
    end
    if i>1
%        if voutput(i)<=Vsetvalue*1.2&&voutput(i-1)<Vsetvalue*1.2
%           jstart=jinput(i);
%        end
       if voutput(i)<Vsetvalue*(1-fluctuating)||voutput(i)>=Vsetvalue*(1+fluctuating)
          jend=jinput(i);
          break
       end
    end
end
y=jend-jj;


