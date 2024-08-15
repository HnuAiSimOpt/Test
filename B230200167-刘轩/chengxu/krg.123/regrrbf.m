function rs = regrrbf(y,x,eg,tf,varargin)
%REGRRBF   Radial basis function regression for y = f(x).
%
%          Dimensional mapping:y
%          Y    1D
%          X    pD
%
%          Input parameters:
%          Y    the outputs
%          X    the inputs
%          EG   the maximum mean squred error of training
%          TF   the type of radial basis functioin
%          VAR  the additional inputs for specific RBFs.
%
%          Output parameters:
%          RS   the regressed model, modified/additional fields are:
%               VAR  the additional inputs for specific RBFs.
%               TR   the regression method
%               N    the number of samples
%               P    the number of input parameters
%               XC   the identified centers from inputs
%               DF   the degree of freedom
%               EF   the polynomial expansion function
%               B    the estimated coefficients
%               R    the residuals
%               T    the time spent on the algorithm
%
%          Example:
%
%          See also:
%
%          Copyright (c) Dong Zhao (2008-2009)

% data metrics
[n,p] = size(x);
var = varargin;

tic;
% determine centers
xc = ct(x',y',eg,tf,var);

% predictor array
xx = ef(x,xc,tf,var);
df = max(0,n-size(xx,2));

% regression
[b,bint,r,rint,stats] = regress(y,xx);
t = toc;

% output
rs.y = y;
rs.x = x;
rs.eg = eg;
rs.tf = tf;
rs.var = var;
rs.tr = 'rbf';
rs.n = n;
rs.p = p;
rs.xc = xc;
rs.df = df;
rs.ef = @(x)ef(x,rs.xc,rs.tf,rs.var);
rs.b = b;
rs.r = r;
rs.t = t;
end % function rs = regrrbf(y,x,eg,tf,varargin)

%======================================================
function w1 = ct(p,t,eg,tf,var)
% data size
[r,q] = size(p);
[s,q] = size(t);

% radial basis layer outputs
switch(tf)
  case 'gaussian'
    sp = var{1};
    b = sqrt(-log(.5))/sp;
    P = radbas(dist(p',p)*b);
  case 'thinplate'
    z = dist(p',p);
    replace = find(z == 0);
    z(replace) = ones(size(replace));
    P = z.^2.*log(z);
  otherwise
    disp('Type not in list!');
    w1 = NaN;
    return;
end
PP = sum(P.*P)';
d = t';
dd = sum(d.*d)';

% calculate errors associated with vectors
e = ((P' * d)' .^ 2) ./ (dd * PP');

% pick vector with most error
pick = findLargeColumn(e);
used = [];
left = 1:q;
W = P(:,pick);
P(:,pick) = [];
PP(pick,:) = [];
e(:,pick) = [];
used = [used left(pick)];
left(pick) = [];

% calculate actual error
w1 = p(:,used)';
switch(tf)
  case 'gaussian'
    a1 = radbas(dist(w1,p)*b);
  case 'thinplate'
    z = dist(w1,p);
    replace = find(z == 0);
    z(replace) = ones(size(replace));
    a1 = z.^2.*log(z);
  otherwise
    disp('Type not in list!');
    w1 = NaN;
    return;
end
[w2,b2] = solvelin2(a1,t);
a2 = w2*a1 + b2*ones(1,q);
sse = sumsqr(t-a2);

for k = 2:q
  % calculate errors associated with vectors
  wj = W(:,k-1);
  a = wj' * P / (wj'*wj);
  P = P - wj * a;
  PP = sum(P.*P)';
  e = ((P' * d)' .^ 2) ./ (dd * PP');

  % pick vector with most error
  pick = findLargeColumn(e);
  W = [W, P(:,pick)];
  P(:,pick) = [];
  PP(pick,:) = [];
  e(:,pick) = [];
  used = [used left(pick)];
  left(pick) = [];

  % calculate actual error
  w1 = p(:,used)';
  switch(tf)
    case 'gaussian'
      a1 = radbas(dist(w1,p)*b);
    case 'thinplate'
      z = dist(w1,p);
      replace = find(z == 0);
      z(replace) = ones(size(replace));
      a1 = z.^2.*log(z);
    otherwise
      disp('Type not in list!');
      w1 = NaN;
      return;
  end
  [w2,b2] = solvelin2(a1,t);
  a2 = w2*a1 + b2*ones(1,q);
  sse = sumsqr(t-a2);

  % check error
  if (sse < eg)
    break;
  end
end % for k = 2:q
end % function w1 = ct(p,t,eg,tf,var)

%======================================================
function i = findLargeColumn(m)
replace = find(isnan(m));
m(replace) = zeros(size(replace));

m = sum(m .^ 2,1);
i = find(m == max(m));
i = i(1);
end % function i = findLargeColumn(m)

%======================================================
function [w,b] = solvelin2(p,t)
if nargout <= 1
  w = t/p;
else
  [pr,pc] = size(p);
  x = t/[p; ones(1,pc)];
  w = x(:,1:pr);
  b = x(:,pr+1);
end % if nargout <= 1
end % function [w,b] = solvelin2(p,t)

%======================================================
function xx = ef(x,xc,tf,var)
switch(tf)
  case 'gaussian'
    sp = var{1};
    b = sqrt(-log(.5))/sp;
    P = radbas(dist(xc,x')*b);
    xx = [ones(1,size(x,1));P]';
  case 'thinplate'
    z = dist(xc,x');
    replace = find(z == 0);
    z(replace) = ones(size(replace));
    P = z.^2.*log(z);
    xx = [ones(1,size(x,1));P]';
  otherwise
    disp('Type not in list!');
    xx = NaN;
    return;
end % switch(tf)
end % function xx = ef(x,xc,tf,var)
