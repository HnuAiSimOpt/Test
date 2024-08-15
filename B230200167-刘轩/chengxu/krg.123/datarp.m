
  Bf = regrkrg(y,x,@regpoly1,@corrspherical,2,0.01,100);
  f7 = regpoly1(x);
  py7 = predkrg2(x,Bf,f7,0.01);