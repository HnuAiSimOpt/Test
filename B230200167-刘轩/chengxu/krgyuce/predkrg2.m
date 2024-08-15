function py = predkrg2(px,rs,f,alfa)
%PREDKRG   Krig method prediction for regressed y = f(x).
%
%          Dimensional mapping:
%          Y    1D
%          X    pD
%
%          Input parameters:
%          PX   the prediction inputs
%          RS   the regressed model
%          F    the original function for comparison
%          ALFA the confidence level
%
%          Output parameters:
%          PS   the prediction, additional fileds are:
%               PY   the estimated outputs
%               PSIG  the estimated residual sigma
%               PYD  the estimated delta of outputs
%               FY   the analytical outputs
%               MSE  the mean squred error
%               RSQR the r squre
%               RAAE the relative average absolute error
%               RMAE the relative maximum absolute error
%               T    the time spent on the algorithm
%
%          Example:
%
%          See also:
%
%          Copyright (c) Dong Zhao (2008-2009)

% checking
if(strcmp(rs.tr,'krg') ~= 1)
  disp('Wrong input structure!');
  ps = NaN;
  return;
end

[n,p] = size(px);
if(p ~= rs.p)
  disp('Wrong input parameter!');
  ps = NaN;
  return;
end

% prediction
tic;
py = zeros(n,1);
psig2 = zeros(n,1);
for i = 1:n
  [py(i,:),dy,psig2(i,:),dsig2] = predictor(px(i,:),rs.md);
end
t = toc;

% estimated residual sigma
psig = sqrt(psig2);

% prediction interval
pyd = norminv(1-alfa,0,psig);

% statistics
if(isa(f,'function_handle'))
  fy = f(px);
  pmse = mean((fy-py).^2);
  pvar = mean((fy-mean(fy)).^2);
  if(pvar ~= 0)
    prsqr = 1-pmse./pvar;
    praae = sum(abs(fy-py))/(n*sqrt(pvar));
    prmae = max(abs(fy-py))/sqrt(pvar);
  else
    prsqr = -inf;
    praae = inf;
    prmae = inf;
  end
else
  fy = NaN;
  pmse =  NaN;
  prsqr = NaN;
  praae = NaN;
  prmae = NaN;
end
pmsig = mean(psig);

% output
ps.px = px;
ps.rs = rs;
ps.f = f;
ps.alfa = alfa;
ps.py = py;
ps.psig = psig;
ps.pyd = pyd;
ps.fy = fy;
ps.mse = pmse;
ps.rsqr = prsqr;
ps.raae = praae;
ps.rmae = prmae;
ps.msig = pmsig;
ps.t = t;

% save data
%save predkrg.mat ps;
end % function ps = predkrg(px,rs,f,alfa)
