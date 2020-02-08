function results = runRegression(data,varargin)

%get options name
optnames={varargin{1:2:end}};
optvals={varargin{2:2:end}};
opt = cell2struct(optvals,optnames,2);

%Define regression range and run regression
matrange = get(data,'nanrange');
if isfield(opt,'range')
        matrange = opt.range;
end
datamat = data(matrange);
results = ols(datamat(:,1),datamat(:,2:numel(datamat(1,:))));

end