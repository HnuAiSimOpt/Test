function rs = regrkrg(y,x,rf,cf,theta,lb,ub)
%REGRKRG   Kriging regression for y = f(x).
%
%          Dimensional mapping:
%          Y    1D
%          X    pD
%
%          Input parameters:
%          Y     the outputs
%          X     the inputs
%          RF    the regression function
%          CF    the correlation function
%          THETA the intial estimate of the correlation function
%                parameter
%          LB    the lower bound for THETA estimation
%          UB    the upper bound for THETA estimation
%
%          Output parameters:
%          RS    the regressed model, additional fields are:
%                TR   the regression method
%                N    the number of samples
%                P    the number of inputer parameters
%                MD   the predicted model
%                PF   the optimization history
%                T    the time spent on the algorithm
%
%          Example:
%
%          See also:
%
%          Copyright (c) Dong Zhao (2008-2009)

% data metrics
[n,p] = size(x);

tic;
% regression
if(nargin == 5)
  [md,pf] = dacefit(x,y,rf,cf,theta);
elseif (nargin == 7)
  [md,pf] = dacefit(x,y,rf,cf,theta,lb,ub);
end
t = toc;

% output
rs.y = y;
rs.x = x;
rs.tr = 'krg';
rs.n = n;
rs.p = p;
rs.md = md;
rs.pf = pf;
rs.t = t;
end % function rs = regrkrg(y,x,rf,cf,theta,lb,ub)
