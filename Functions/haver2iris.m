%% haver2iris.m
%
% This routine uses MATLAB's Datafeed Toolbox and IRIS's Tseries functions
% to get HAVER data directly from the vendor data server into MATLAB and in
% IRIS tseries format. Moreover, metadata for each variable is 
% automatically pulled from the source and stored in the respective 
% tseries's userdata field.
%
% DEPENDENCE: IRIS Toolbox, Datafeed Toolbox with subscription to the Haver
% analytics database
% NOTE: Currently, the Haver database communication functions only work on
% a 32-bit system. 
% 
% P.Manchev (pmanchev@imf.org) 20091016

function [fromHAVER] = haver2iris(tickers,matfile)
%% Read variable list from CSV file

yourPathToHaver = '//imfdata/econ/DATA/DLX/DATA/';

v = cell(numel(tickers),2);
for i = 1 : numel(tickers)
    tmp = tickers{i};
    at = findstr('@',tmp);
    v{i,1} = tmp(1:at-1); %series name
    v{i,2} = tmp(at+1:end); %database
end

dbs = unique(v(:,2)); %get unique databases

for j = 1 : numel(dbs)
    tmp = '';
    tmp2 = zeros(0,0);
    for i = 1 : numel(tickers)
        if strcmp(v{i,2},dbs{j})
            tmp = strvcat(tmp,v{i,1});
        end
    end
    vars.(dbs{j}) = cellstr(tmp);
end

%% Get data

db = fieldnames(vars); %which db
ndb = numel(db); %how many databases

%fid = fopen('shortMetadata.txt','w+');
for ii = 1 : ndb
    try
        fprintf('\nAttempting to access %s ... \n',db{ii})
        connect = haver(sprintf('%s%s.dat',yourPathToHaver,db{ii})); %create connection object
        fprintf('Connection to the HAVER database %s established. \n',db{ii})
    catch me1 
        fprintf('MATLAB SAYS: \n %s \n',me1.message) %if you catch an exception, then display it ...
        continue % and continue to next iteration
    end
    thisdb = vars.(db{ii});
    
    for jj = 1 : numel(thisdb)
       
        try
            fprintf('%s@%s: ',thisdb{jj},db{ii});
            d = fetch(connect,thisdb{jj}); %get data from Haver: returns a numeric array with 2 columns -- first one is the date in MATLAB serial date number format, second is the data
            i = info(connect,thisdb{jj}); %get meta-data from Haver: returns a structure
        catch me2
            fprintf('%s \n',me2.message)
            for jjj = 1 : 5
                fprintf('Attempt %d of 5 to download %s@%s ... \n',jjj,thisdb{jj},db{ii});
                try 
                    d = fetch(connect,thisdb{jj}); 
                    i = info(connect,thisdb{jj}); 
                    fprintf('Success! \n');
                    break
                catch me3
                    fprintf('%s \n',me3.message)
                    continue
                end                
            end

            continue
        end
        
        i.AccessedFrom = 'HAVER';
        i.Database = sprintf(db{ii});
        i.DateTimeMod1 = datenum(i.DateTimeMod); %Date and time modified in numeric MATLAB format
        rrr = datestr(i.DateTimeMod,'yyyymmdd');
        i.DateTimeMod2 = str2double(rrr); %Date modified as an integer of the form YYYYMMDD

        if strcmp(i.Frequency,'Q') %quarterly data
            s = datestr(d(:,1),27); %turn Matlab serial date numbers into a string array; format 27 is   QQ-YYYY
            s = [s(:,4:7) s(:,1:2)]; %re-format string array in YYYYQQ format
            c = cellstr(s); %create cell array of strings from character array -- IRIS's str2dat function requires cell array of strings as input
            tt = str2dat(c,'dateformat','yyyyfp'); %map dates to IRIS format; dateformat is format of dates coming in 
            fromHAVER.(db{ii}).(thisdb{jj}) = tseries(tt,d(:,2));%create IRIS tseries object
            fromHAVER.(db{ii}).(thisdb{jj}) = userdata(fromHAVER.(db{ii}).(thisdb{jj}),i); %associate metadata from HAVER with IRIS tseries object          
            
        elseif strcmp(i.Frequency,'M') %monthly data
            s = datestr(d(:,1),'yyyymm'); %turn Matlab serial date numbers into a string array; format is YYYYMM
            c = cellstr(s); %create cell array of strings from character array -- IRIS's str2dat function requires cell array of strings as input
            tt = str2dat(c,'dateformat','yyyymm'); %map dates to IRIS format; dateformat is format of dates coming in 
            fromHAVER.(db{ii}).(thisdb{jj}) = tseries(tt,d(:,2));%create IRIS tseries object
            fromHAVER.(db{ii}).(thisdb{jj}) = userdata(fromHAVER.(db{ii}).(thisdb{jj}),i); %associate metadata from HAVER with IRIS tseries object   
            
        elseif strcmp(i.Frequency,'A') %annual data
            s = datestr(d(:,1),'yyyy'); %turn Matlab serial date numbers into a string array; format is YYYY
            c = cellstr(s); %create cell array of strings from character array -- IRIS's str2dat function requires cell array of strings as input
            tt = str2dat(c,'dateformat','yyyy'); %map dates to IRIS format; dateformat is format of dates coming in  
            fromHAVER.(db{ii}).(thisdb{jj}) = tseries(tt,d(:,2));%create IRIS tseries object
            fromHAVER.(db{ii}).(thisdb{jj}) = userdata(fromHAVER.(db{ii}).(thisdb{jj}),i); %associate metadata from HAVER with IRIS tseries object 
            
        elseif strcmp(i.Frequency,'D') %daily data
            fromHAVER.(db{ii}).(thisdb{jj}) = tseries(d(:,1),d(:,2));%create IRIS tseries object
                                                                 %NOTE: IRIS will fill in the periods missing from the timeseries (weekends) with NaN;
                                                                 %Therefore, there will be (many) more observations in the IRIS tseries object than 
                                                                 %noted in the NumberObs field of userdata()
            fromHAVER.(db{ii}).(thisdb{jj}) = userdata(fromHAVER.(db{ii}).(thisdb{jj}),i); %associate metadata from HAVER with IRIS tseries object
            
        end
        
        ud = userdata(fromHAVER.(db{ii}).(thisdb{jj}));
        fromHAVER.(db{ii}).(thisdb{jj}) = comment(fromHAVER.(db{ii}).(thisdb{jj}),ud.Descriptor);
        fprintf('DONE. \n')
    end
end 

filename = sprintf('%s.mat',matfile);
savestruct(fromHAVER,filename);
fprintf('\nDatabase saved in %s. \n',filename);
