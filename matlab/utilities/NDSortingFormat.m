function NDSortingFormat(spikefilename,nrecs)
% NDSortingFormat(spikefilename,nrecs)
%
% (N-dimensional Sorting Format, works with Steve and Tim's multi-D sorting program)
% Takes spike file name and formats it for multidimensional sorting:
% times = (NumberChannels x 1) cell array.
%	each entry is a 1x1 cell array, which contains a
%	2xN matrix of spike times and index
% proj = (NumberChannels x 1) cell array.
%	each entry contains a 2-by-N matrix with rows of spike peaks and widths
%	where N is the number of spikes on that channel
if (nargin == 2)
	[recs,header] = ReadSpikeFile (spikefilename,nrecs);
else
	[recs,header] = ReadSpikeFile (spikefilename);
end

[catrec,catheader] = ConcatenateSpikeRecords(recs,header);
clear recs;

sptimes = cell(63, 1);
proj = cell(63, 1);
for ch=1:header.NumberChannels
	sptimes{ch} = cell(1,1);
	sptimes{ch}{1} = [catrec.T{ch}; 1:size(catrec.T{ch},2)];
	catrec.T{ch} = [];	% free memory as you process each channel
	
	proj{ch} = [catrec.W{ch};catrec.P{ch}];
	catrec.W{ch} = [];
	catrec.P{ch} = [];
end

save 'proj.mat' sptimes proj;


