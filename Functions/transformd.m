function dd = transformd(d)

dd = struct();
tmp = rmfield(d,'SAVESTRUCT_CLASS');
dbs = fieldnames(tmp);
for i = 1:numel(dbs)
    dbname = dbs{i};
    db = d.(dbname);
    vars = fieldnames(db);
    for j = 1:numel(vars)
        var = vars{j};
        dd.(var) = d.(dbname).(var);
    end
end