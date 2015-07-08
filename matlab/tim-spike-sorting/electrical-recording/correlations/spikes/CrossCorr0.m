function [tcc,timet] = CrossCorr(record,cell1,cell2,tmax)
% [tcc,timet] = CrossCorr(record,cell1,cell2,tmax)
% Compute cross-correlations
% The output tcc is a vector containing all time differences less (in abs value)
% than tmax.
% timet contains the spike times (in cell1) that contribute to the samples in tcc.
nrec = length(record);
tcc = [];
timet = [];
for i = 1:nrec
	j = 1;	% iterator over cell 1
	k = 1; 	% iterator over cell 2
	t1 = record{i}.T{cell1};
	t2 = record{i}.T{cell2};
	while (j <= length(t1))
		if (k > length(t2))
			k = length(t2);
		end
		while (k > 1 & t2(k)+tmax > t1(j))	% Back up if necessary
			k = k-1;
		end
		while (t2(k)+tmax < t1(j) & k < length(t2))
			k = k+1;						% Advance if necessary
		end
		while (k <= length(t2) & t2(k)-tmax < t1(j) & t2(k)-t1(j) > -tmax)
			tcc(end+1) = t2(k)-t1(j);
			timet(end+1) = t1(j);
			k = k+1;
		end
		j = j+1;
	end
end
