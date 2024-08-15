function rs = regrply(y,x,d)
%REGRPLY   Response surface regression for y = f(x).
%
%          Dimensional mapping:
%          Y    1D
%          X    nD
%
%          Input parameters:
%          Y    the outputs
%          X    the inputs
%          D    the degree of polynomial
%
%          Output parameters:
%          RS   the regressed model, additional fields are:
%               TR   the regression method
%               N    the number of samples
%               P    the number of input parameters
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

tic;
% predictor array
xx = ef(x,p,d);
df = max(0,n-size(xx,2));

% regression
[b,bint,r,rint,stats] = regress(y,xx);
t = toc;

% output
rs.y = y;
rs.x = x;
rs.d = d;
rs.tr = 'ply';
rs.n = n;
rs.p = p;
rs.df = df;
rs.ef = @(x)ef(x,p,d);
rs.b = b;
rs.r = r;
rs.t = t;
end % function rs = regrply(y,x,d)

%======================================================
function xx = ef(x,p,d)
% checking
p1 = size(x,2);
if(p1 ~= p)
  disp('Wrong inputs!');
  xx = NaN;
  return;
end

% calculation
if(p == 1)
  xx = ones(size(x,1),1);
  for i = 1:d
    xx = [xx,x.^i];
  end
else
  xx = [ones(size(x,1),1),x(:,1:p)];
  if(d >= 2)
    for i = 2:d
      cmb = nchoosek(1:p,i);
      ncmb = size(cmb,1);
      xi = [];
      for j = 1:ncmb
        m = 1;
        for k = 1:i
          m = m.*x(:,cmb(j,k));
        end
        xi = [xi,m];
      end
      xi = [xi,x(:,1:p).^i];
      xx = [xx,xi];
    end % for i = 2:d
  end % if(d >= 2)
end % if(p == 1)
end % function xx = ef(x,p,d)
