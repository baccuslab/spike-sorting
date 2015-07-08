function I = CCNN(spikes)
% I = CCNN(spikes)
% For the input cell array "spikes",
% compute the Cross Correlation of
% nearest-neighboring spikes for all
% pairs in the cell array
I = zeros(0,0);
for indx = 1:length(spikes)-1
	Itemp = CrossCorrNN(spikes{indx},spikes(indx+1:length(spikes)));
	I(end+1) = Itemp;
end
