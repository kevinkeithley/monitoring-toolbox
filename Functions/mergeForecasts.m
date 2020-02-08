function [a_m,a_q,a] = mergeForecasts(dd,cc)

ticknames = fieldnames(dd);
a_m = struct();
a_q = struct();
tmp_a_m = dbload(['Assumptions' filesep 'monthly_assumptions.csv']);
tmp_a_q = dbload(['Assumptions' filesep 'quarterly_assumptions.csv']);
ymdtoday = datestr(now(),'yyyy-mm-dd');
filename_m = ['Assumptions' filesep cc '_monthly_assumptions_' ymdtoday '.mat'];
filename_q = ['Assumptions' filesep cc '_quarterly_assumptions_' ymdtoday '.mat'];
savestruct(tmp_a_m,filename_m);
savestruct(tmp_a_q,filename_q);
for i = 1:numel(ticknames)
    if strmatch(dd.(ticknames{i}).userdata.Frequency,'M')
        a_m.(ticknames{i}) = tseries();
        a_m.(ticknames{i}) = userdata(dd.(ticknames{i}),dd.(ticknames{i}).userdata);
        tmp_rng_a = get(tmp_a_m.(ticknames{i}),'range');
        a_m.(ticknames{i})(tmp_rng_a) = tmp_a_m.(ticknames{i});
    elseif strmatch(dd.(ticknames{i}).userdata.Frequency,'Q')
        a_q.(ticknames{i}) = tseries();
        a_q.(ticknames{i}) = userdata(dd.(ticknames{i}),dd.(ticknames{i}).userdata);
        tmp_rng_q = get(tmp_a_q.(ticknames{i}),'range');
        a_q.(ticknames{i})(tmp_rng_q) = tmp_a_q.(ticknames{i});
    else
        sprintf('The variable %s is neither Monthly nor Quarterly.',(ticknames{i}))
    end
    a = dbmerge(a_m,a_q);
end

end