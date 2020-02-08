%% Update data
% Uses datafeed toolbox to take tickers and pull in Haver data and metadata
% 
% inputs
%   tickers     cell array of haver tickers from sortComponents.m
%   cc          two-letter country code from data definitions xlsx file
% 
% outputs
%   d           -structure with haver data in form d.(haverdbase).(ticker)
%               -haver metadata available at series level eg
%               d.(haverdbase).(ticker).userdata
%               -vintage data .mat file automatically stored in 'Data'
%               folder
% 
% K. Keithley (kkeithley@imf.org) 2013 
function [d] = updatedata(tickers,cc)
ymdtoday = datestr(now(),'yyyy-mm-dd');
haver2iris(tickers,['Data' filesep cc '_data_' ymdtoday]);
d = load(['Data' filesep cc '_data_' ymdtoday]);
end