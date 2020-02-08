function printmmhistplot(component,s,d,cc,varargin)

%get options name
optnames={varargin{1:2:end}};
optvals={varargin{2:2:end}};
opt = cell2struct(optvals,optnames,2);

vars = s.(component)(1:end,1);
v = cell(numel(vars),2);
for i = 1 : numel(vars)
    tmp = vars{i};
    at = findstr('@',tmp);
    sername = tmp(1:at-1); %series name
    db = tmp(at+1:end); %database
    vars{i} = [db '.' sername];
end
varopts = s.(component)(1:end,2);
reportdate = date();
startdategraph = mm(2007,1); %user defined for function (auto date should be 2007 period 1)
startdategraph_q = qq(2007,1);

sty = struct();
sty.axes.xgrid = 'on';
sty.axes.ygrid = 'on';
sty.line.linewidth = 1.5;
sty.line.color = {'blue','red'};
sty.line.linestyle = {'-','--'};
sty.title.fontsize = 10;
sty.legend.fontsize = 8;
sty.legend.location = 'best';

c = struct;
c(1).test = '~isempty(strfind(mark,''Delta''))';
c(1).format = '\small [?]';
c(2).test = '~isempty(strfind(mark,''Delta'')) && value == Inf';
c(2).value = '--';
c(3).test   = '~isempty(strfind(mark,''Delta'')) && value < -0.009';
c(3).format = '\color{red}';
c(4).test   = '~isempty(strfind(mark,''Delta'')) && value > 0.009';
c(4).format = '\color{green}';

x = report.new([component ' ' reportdate],'orientation','portrait');
if  isfield(opt,'vintage')
        dateselect=opt.vintage;
        h = load(['Data' filesep cc '_data_' dateselect]);
        vintagedate =  datestr(dateselect,'yyyy/mm/dd');
end
for i=2:numel(vars)
    var = ['d.' vars{i}];
    if isfield(opt,'vintage')
        vintvar = ['h.' vars{i}];
        vintser = eval(vintvar);
    end
    
    if strmatch(varopts(i),'nsa')
        ser=x12(eval(var));
    else
        ser = eval(var);
    end
    
    serend = get((ser),'enddate');
    [monthnum,monthstring] = eval(sprintf('month(%s.userdata.EndDate)',var));
    
    ser_q = eval(sprintf('convert(%s,''Q'')',var));
    ser_q_end = get(ser_q,'enddate');
    
    remainder = mod(monthnum,3);
    if remainder == 0
        tablerange_q = (ser_q_end-6):ser_q_end;
        tablerange_m = (serend-6):(serend);
    else
        tablerange_q = (ser_q_end-6):(ser_q_end+1);
        tablerange_m = (serend-6):(serend+(3-remainder));
    end
    graphrange = startdategraph:(serend+1);
    graphrange_q = startdategraph_q:ser_q_end;
    
    tmp_comment = get((ser),'comment');
    [country,datadesc] = strtok(tmp_comment,':');
    [colon,datadesc] = strtok(datadesc,' ');
    [release,season] = strtok(datadesc,'(');
    
    x.figure([cc ': ' component ' Indicators'],'subplot',[5 1],'zeroline',true,'style',sty,'range',graphrange);
    
    datelastmod =  datestr(ser.userdata.DateTimeMod,'dd/mmm/yyyy');
    
    enddate = datestr(ser.userdata.EndDate,'mmmyyyy');
    shortsource = ser.userdata.ShortSource;
    longsource = ser.userdata.LongSource;
    SeasAdj = ['Data SA using X12'];
    
    if isfield(opt,'vintage')
        if datelastmod == datestr(vintser.userdata.DateTimeMod,'dd/mmm/yyyy')
            x.graph([tmp_comment ['EndDate: ' enddate] ['Date last modified: ' datelastmod] ['Source: ' longsource]],'legend',true);
        else
            x.graph([tmp_comment ['EndDate: ' enddate] ['*NEW* Date last modified: ' datelastmod] ['Source: ' longsource]],'legend',true);
        end
    else
        x.graph([tmp_comment ['EndDate: ' enddate] ['Date last modified: ' datelastmod] ['Source: ' longsource]],'legend',true); %add 'last update' data from Haver userdata
    end
    
    x.series('Level',ser);
    
    var_national = ['d.' vars{1}];
    ser_national = eval(var_national);
    ser_national_q = convert(ser_national,'Q');
    
    x.graph(varopts(i),'legend',true);
    if strmatch(varopts(i),'diff')
        x.series('% m/m',pct(ser));
        x.series('% 3m/3m',100*((((ser+ser{-1}+ser{-2})/3)/((ser{-3}+ser{-4}+ser{-5})/3))-1));
    elseif strmatch(varopts(i),'yoy')
        x.series('y/y',pct(ser,-12));
    elseif strmatch(varopts(i),'level')
        x.series('Level',ser);
        x.series('3mma',(ser+ser{-1}+ser{-2})/3);
    else
        %display some error message
    end
    
    x.graph('vs National Accounts Component','legend',true,'range',graphrange_q);
    if strmatch(varopts(i),'diff')
        x.series('NAC %q/q (left)',pct(ser_national_q),'yAxis','left');
        x.series('Indicator %q/q (right)',pct(ser_q),'yAxis','right');
    elseif strmatch(varopts(i),'yoy')
        x.series('NAC %q/q (left)',pct(ser_national_q,-4),'yAxis','left');
        x.series('Indicator Level (right)',pct(ser_q,-4),'yAxis','right');
    elseif strmatch(varopts(i),'level')
        x.series('NAC %q/q (left)',pct(ser_national_q),'yAxis','left');
        x.series('Indicator Level (right)',ser_q,'yAxis','right');
    else
        %display some error message
    end
    
    if  isfield(opt,'vintage')
        dateselect=opt.vintage;
        h = load(['Data' filesep cc '_data_' dateselect]);
        vintagedate =  datestr(dateselect,'yyyy/mm/dd');
        
        varhis = ['h.' vars{i}];
        serhis = eval(varhis);
        d1 = [ser,ser-serhis]; %?diff?
        d2 = [pct(ser),pct(ser)-pct(serhis)]; %?diff?
        d3 = [pct(ser,12),pct(ser,12)-pct(serhis,12)]; %?diff?
        x.table(['Monthly '],'footnote=',['vs (' vintagedate ')'],'range=',tablerange_m,'condFormat=',c,'decimal=',[1],'marks=',{'','{$\Delta$}'});
        
        if strmatch(varopts(i),'diff')
            x.series(' Level',d1,'showMarks',true);
            x.series('% m/m',d2,'showMarks',true);
            x.series('% 3m/3m',100*((((ser+ser{-1}+ser{-2})/3)/((ser{-3}+ser{-4}+ser{-5})/3))-1),'showMarks',false);
        elseif strmatch(varopts(i),'yoy')
            x.series(' Level',d1,'showMarks',true);
            x.series('% y/y',d3,'showMarks',true);
        elseif strmatch(varopts(i),'level')
            x.series(' Level',d1,'showMarks',true);
            x.series('% change',d2,'showMarks',true);
            x.series('3mma',(ser+ser{-1}+ser{-2})/3);
        else
            %error
        end
    else
        x.table('Monthly','range',tablerange_m,'decimal',1);
        if strmatch(varopts(i),'diff')
            x.series(' Level',ser);
            x.series('% m/m',pct(ser));
            x.series('% 3m/3m',100*((((ser+ser{-1}+ser{-2})/3)/((ser{-3}+ser{-4}+ser{-5})/3))-1));
        elseif strmatch(varopts(i),'yoy')
            x.series(' Level',ser);
            x.series(' y/y',pct(ser,-12));
        elseif strmatch(varopts(i),'level')
            x.series(' Level',ser);
            x.series('3mma',(ser+ser{-1}+ser{-2})/3);
        else
            %error
        end
        
    end
    
    x.table('Quarterly','range',tablerange_q,'decimal',1);
    if strmatch(varopts(i),'diff')
        x.series('% (Q/Q)',pct(ser_q));
    elseif strmatch(varopts(i),'level')
        x.series('Level',ser_q);
    else
        %error
    end
    
    x.clearpage();
end

x.publish([cc '_' component '_' reportdate '.pdf']);

%make reports directory
if ~exist('Reports','dir')
    mkdir('Reports');
end

%make component directory
if ~exist(['Reports\' component],'dir')
    mkdir(['Reports\' component]);
end

movefile([cc '_' component '_' reportdate '.pdf'],[pwd '\Reports\' component]);

end

