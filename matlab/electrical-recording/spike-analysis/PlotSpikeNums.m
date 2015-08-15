function PlotSpikeNums(record)
figure
nrec = length(record);
ncell = length(record{1}.T);
nspikes = zeros(nrec,ncell);
for i = 1:nrec
	for j = 1:ncell
		nspikes(i,j) = length(record{i}.T{j});
	end
end
dims = CalcSubplotDims(ncell);
dimx = dims(1);
dimy = dims(2);
for j = 1:ncell
	subplot(dimx,dimy,j)
	maxn = max(nspikes(:,j));
	axis([1 nrec 0 maxn]);
	hold on
	plot(nspikes(:,j),'b');
	meann = mean(nspikes(:,j));
	upper = (meann+2*sqrt(meann))*ones(1,nrec);
	lower = (meann-2*sqrt(meann))*ones(1,nrec);
	plot(1:nrec,[upper;lower],'r:');
	title(sprintf('Cell %d',j));
end
