%% addOutsideData.m
% Add data from .csv files (in IRIS format - see dbload() function for details)
%     REQUIRED USERDATA FIELDS:
%         Comment           eg. Country: Data Release (SWDA, units)
%         .EndDate          eg. dd-mmm-yy  
%         .DateTimeMod      eg. dd-mmm-yy
%         .ShortSource      eg. text
%         .LongSource       eg. text
% 
% Inputs
% =========
%    d        data structure with Haver data from updatedata.m
%    csvlist  array of csv filenames located in 'Data' folder
% 
% Outputs
% =========
%    d        data structure with Haver data and outside data
% 
% K. Keithley (kkeithley@imf.org) 2013
function d = addOutsideData(d,csvlist)

d.OUTSIDEDB = struct();

for i = 1:numel(csvlist)
    tmp_db = dbload(['Data' filesep csvlist{i} '.csv'],'case','upper');
    d.OUTSIDEDB = dbmerge(d.OUTSIDEDB,tmp_db);
end

end