function V1=vv(z1,z2,z3)
   Bf = regrkrg(y,x,@regpoly1,@corrspherical,2,0.01,100);
  f7 = regpoly1(x);
  z1 = 0.02;
  z2=7864;
  z3=6680;
  z=[z1,z2,z3];
  V1 = predkrg2(z,Bf,f7,0.01);
 