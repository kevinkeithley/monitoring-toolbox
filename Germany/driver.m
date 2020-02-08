%% Update Data 
cc = 'GE'; %2-letter country code
[s,tickers] = sortComponents(cc); %imports structure from *cc*_definitions.xlsx file in Data/ folder
[d] = updatedata(tickers,cc); %
[dd] = transformd(d);
createDataDescription(d,cc);

%% Plot Historical Data
dateselect = '2014-05-21';

component = 'PrivateConsumption';
printmmhistplot(component,s.histplot,d,cc,'vintage',dateselect);

%% Regression Work
%Create Assumptions Template - Run once and done
% createAssumptionsTemplate(dd);

%Merge forecast data with historical data
[a_m,a_q,a] = mergeForecasts(dd,cc);
ymdtoday = datestr(now(),'yyyy-mm-dd');
filename = ['Assumptions' filesep cc '_assumptions_' ymdtoday '.mat'];
savestruct(filename,a);

%Plot forecast assumptions graphs
dateselect = '2014-04-24';
component = 'PrivateConsumption';
printmmfplot(component,s.histplot,a,cc);

f = struct();

%Private Consumption
eqnlhs = 'PrivateConsumption';
freq = 'Q';
[PrivateConsumptionData] = createTseriesMatrix(eqnlhs,dd,s,freq); 
f.(eqnlhs).data = PrivateConsumptionData;
[PrivateConsumptionResults] = runRegression(PrivateConsumptionData);
f.(eqnlhs).regResults = PrivateConsumptionResults;

prt_reg(PrivateConsumptionResults);
plt_reg(PrivateConsumptionResults);

PrivateConsumptionForecastData = createTseriesMatrix(eqnlhs,a,s,freq);
PrivateConsumptionForecastData(:,2)=1;
f.(eqnlhs).mergedData = PrivateConsumptionForecastData;

%Save f structure
ymdtoday = datestr(now(),'yyyy-mm-dd');
filename = ['ForecastData_' ymdtoday '.mat'];
eval(sprintf('save %s f;',filename));