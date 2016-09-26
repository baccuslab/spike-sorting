function [tonout,n,mn,sigma] = MomentsRateChange(ton,spikediff)
% MomentsRateChange: Calculate the mean & std dev. of the firing rate change
% [tonout,n,mn,sigma] = MomentsRateChange(ton,spikediff)
% See RateChange and PlotMeanRateChange
nstim = length(ton);
ncells = size(spikediff,2);
for i = 1:nstim
	% Determine which valve opening times go together
	t = round(100*ton{i})/100;	% round to nearest .01s
	tu = unique(t);
	% For each different time, compute moments
	tonout{i} = tu;
	for j = 1:length(tu)
		tindx = find(t == tu(j));
		n{i}(j) = length(tindx);
		for k = 1:ncells
			sd = spikediff{i,k}(tindx);
			mn{i,k}(j) = mean(sd);
			sigma{i,k}(j) = std(sd);
		end
	end
end
