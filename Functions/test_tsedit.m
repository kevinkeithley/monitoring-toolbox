%% TSEDIT -- Editing IRIS Time Series
% by Michal Andrle (IMF)
%
% This tutorial shows how to use a very simple visual tool
% to manually edit IRIS time series and vectors. The code is from
% 2007 and was primarily written for fun and use in the forecasting
% process. In the forecasting process it can be used to fine-tune
% assumptions on exogenous variables and judgment...
%

%% IRIS time series
% Any time series is simply passed to |tsedit|. There use the mouse to move
% the circles to values you like. Circles are big so it is easy to grab a
% point. When you are done, click save and quit. The result is stored in
% the workspace under the name |edited_series|.
%
% As a homework, you can rewrite the code so it returns the series as an
% output. The structure of callbacks needs to change a bit then...

a = tseries(qq(1994,1):qq(2000,4),@randn);
tsedit(a);


%% Vector
% The code can handle also vectors, not just time series. It does not
% handle MATLAB Time series objects...

%b = randn(20,1);
%tsedit(b);


