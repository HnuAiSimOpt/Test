  Bf = regrkrg(y,x,@regpoly1,@corrspherical,2,0.01,100);
  f7 = regpoly1(x);
  z1 = 0.02:(0.05-0.02)/99:0.05;
  z1=z1';
  z2=7960:4:8356;
  z2=z2';
  z3=zeros(100,1)+6012;
  z=[z1,z2,z3];
  V1 = predkrg2(z,Bf,f7,0.01)
 