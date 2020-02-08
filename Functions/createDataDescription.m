%% Create Data Description
% Creates text file with data series information
% 
% inputs
%   d           data structure from updatedata.m
%   cc          two-letter country code from data definitions xlsx file
% 
% output
%               - .log text file with haver tickers, data description, and source
%               - automatically saved in 'Data' folder
% 
% K. Keithley (kkeithley@imf.org) 2013 
function createDataDescription(d,cc)

if exist(['Data\DataDescriptionCurrent' cc '.log'])
    delete(['Data\DataDescriptionCurrent' cc '.log']);
end
dtmp = rmfield(d,'SAVESTRUCT_CLASS');
dbs = fieldnames(dtmp);
diary(['Data\DataDescriptionCurrent' cc '.log']);
diary
for i = 1 : numel(dbs)
    thisdb = dbs{i};
    vars = fieldnames(d.(thisdb));
    for j = 1 : numel(vars)
        thisvar = vars{j};
        tmp = comment(d.(thisdb).(thisvar));
        source = (d.(thisdb).(thisvar).userdata.LongSource);
        diary
        fprintf('%s@%s -- %s -- %s \n',thisvar,thisdb,tmp{:},source);
        diary
    end
end
diary off;

end