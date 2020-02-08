%% sort_components.m
% Takes *CC_definitions.xlsx* file from 'Data' folder and sorts it to 
% download data and create structure, s, for graphs
%
% Structure and location of definition file:
%   xlsx file must be in 'Data' folder in working directory
% 
%            A                              B                       C           ...
%  1   componentname (no spaces)  
%  2   LHSTICKER@HAVERDBASE             *column 2 value*     *column 3 value* 
%  3   RHSTICKER1@HAVERDBASE            *column 2 value*     *column 3 value*
%  ... RHSTICKERN@HAVERDBASE            *column 2 value*     *column 3 value*
% 
%    ***NOTE: FOR DATA NOT PULLED FROM HAVER: THE FORMAT FOR THE 1ST COLUMN IS
%       SERIESNAME@OUTSIDEDB (seriesname is the name matching your csv
%       series)
%
%  Supported values for 2nd column:
%     'diff'  --for month-on-month growth rates
%     'yoy'   --for year-on-year growth rates
%     'level' 
% 
%  Supported values for 3rd column (seasonality):
%     'nsa'   -will perform x12 on series before plotting
%     'sa'    -no transformations as the series is already SA
%
% inputs
%     cc        two-letter country code associated with the data
%               definitions xlsx file
% 
% outputs
%     s         cell arrays used for graphing structure
%     tickers   cell array of Haver tickers
%
% K. Keithley (kkeithley@imf.org) 2013

function [s,tickers] = sortComponents(cc)
s = struct();

[num,txt,raw]= xlsread(['Data' filesep cc '_definitions.xlsx']);

tickers = [];
for n = 1:(length(raw(1,:))/3)
    component = raw{1,3*n-2};
    for p = 1:length(raw(:,3*n-2))-1
        if isnan(raw{p+1,3*n-2})
        else
            s.histplot.(component){p,1} = raw{p+1,3*n-2};
            s.histplot.(component){p,2} = raw{p+1,3*n-1};
            s.histplot.(component){p,3} = raw{p+1,3*n};
            tmp = raw{p+1,3*n-2};
            [ticker,db] = strtok(tmp,'@');
            if strmatch(db,'@OUTSIDEDB');
            else
                tickers{end+1} = raw{p+1,3*n-2};
            end
        end
    end
end

[num,txt,raw]= xlsread(['Data' filesep cc '_definitions.xlsx'],'Sheet2');

for n = 1:(length(raw(1,:))/3)
    component = raw{1,3*n-2};
    for p = 1:length(raw(:,3*n-2))-1
        if isnan(raw{p+1,3*n-2})
        else
            s.regress.(component){p,1} = raw{p+1,3*n-2};
            s.regress.(component){p,2} = raw{p+1,3*n-1};
            s.regress.(component){p,3} = raw{p+1,3*n};
        end
    end
end

end