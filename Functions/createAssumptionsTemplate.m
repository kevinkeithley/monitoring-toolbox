%% Create Assumption csv template files
% inputs
%   dd          cell array of haver tickers from sortComponents.m
% 
% outputs
%               monthly and quarterly assumptions .csv file templates in
%               'Assumptions' folder
% 
% K. Keithley (kkeithley@imf.org) 2013

function createAssumptionsTemplate(dd)

%Make assumptions directory
if ~exist('Assumptions','dir')
    mkdir('Assumptions');
end

%Add ticker names to first row of csv files, sorted by data frequency
fidm = fopen(['Assumptions' filesep 'monthly_assumptions.csv'],'w+');
fidq = fopen(['Assumptions' filesep 'quarterly_assumptions.csv'],'w+');
fprintf(fidm,',');
fprintf(fidq,',');
ticknames = fieldnames(dd);
for i = 1:numel(ticknames)
    if strmatch(dd.(ticknames{i}).userdata.Frequency,'M')
        fprintf(fidm,[(ticknames{i}) ',']);
    elseif strmatch(dd.(ticknames{i}).userdata.Frequency,'Q')
        fprintf(fidq,[(ticknames{i}) ',']);
    else
        sprintf('The variable %s is neither Monthly nor Quarterly.',(ticknames{i}))
    end
end

%Add data descriptions to second row of csv files, sorted by data frequency
fprintf(fidm,'\n Comment,');
fprintf(fidq,'\n Comment,');

for i = 1:numel(ticknames)
    if strmatch(dd.(ticknames{i}).userdata.Frequency,'M')
        desc = regexprep(dd.(ticknames{i}).comment,',','');
        fprintf(fidm,[char(desc) ',']);
    elseif strmatch(dd.(ticknames{i}).userdata.Frequency,'Q')
        desc = regexprep(dd.(ticknames{i}).comment,',','');
        fprintf(fidq,[char(desc) ',']);
    else
        sprintf('The variable %s is neither Monthly nor Quarterly.',(ticknames{i}))
    end
end

%close files
fclose(fidm);
fclose(fidq);

end