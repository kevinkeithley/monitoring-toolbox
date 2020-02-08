function tmp = createTseriesMatrix (eqnlhs,data,s,freq)

for i = 1:numel(s.histplot.(eqnlhs)(:,1))
    tmp_varname = char(strtok(s.histplot.(eqnlhs)((i),1),'@'));
    data.(tmp_varname) = convert(data.(tmp_varname),(freq));
end

tmp= [];
for i = 1:numel(s.regress.(eqnlhs)(:,1))
    if strmatch(s.regress.(eqnlhs)((i),1),'constant')
        tmp = [tmp tseries(get(data.(strtok(s.regress.(eqnlhs){1,1},'@')),'nanrange'),1)];
    elseif strmatch(s.regress.(eqnlhs)((i),2),'pct')
        tmp = [tmp eval(char(strcat(s.regress.(eqnlhs)((i),2),'(data.',strtok(s.regress.(eqnlhs)((i),1),'@'),'{',s.regress.(eqnlhs)((i),3),'})')))];
    else
        tmp = [tmp eval(char(strcat('data.',strtok(s.regress.(eqnlhs)((i),1),'@'),'{',s.regress.(eqnlhs)((i),3),'}')))];
    end
end

end