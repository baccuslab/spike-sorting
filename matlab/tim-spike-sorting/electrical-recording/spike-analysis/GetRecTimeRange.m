function trange = GetRecTimeRange(record)
% trange = GetRecTimeRange(record)
allEvT = [];
if (~iscell(record))
	record = {record};
end
for i = 1:length(record)
	allEvT(end+1:end+length(record{i}.evT)) = record{i}.evT;
end
toSecs = 50e-6;
trange = toSecs*[min(allEvT),max(allEvT)];
