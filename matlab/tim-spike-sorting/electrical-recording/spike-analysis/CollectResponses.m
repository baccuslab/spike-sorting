function [stimout,spikeout,vlvsout] = CollectResponses(stimin,spikein,trange,vlvs)
% CollectResponses: organize responses by stimulus
% [stimout,spikeout,vlvsout] = CollectResponses(stimin,spikein,trange,vlvs)
% The inputs:
% stimin is a cell array of 2-by-n matrix of valve numbers and transition
%	times, of the format of ReadVlv or ImportCellsStim
% spikein is a cell array of spikes of the format of ImportCellsStim,
%	where spikein{filenumber,cellnumber} is a vector of spike times
% trange is the time (in secs) before and after the valve opening
% 	that should be collected
% vlvs is an optional vector of valve numbers; if absent, all opened
% 	valves are extracted
%
% The outputs:
% stimout{filenum,vlvindx}{rptnum} is a 2-by-n matrix containing a
%	"stimulus snippet", the valve numbers and transition times
%	(or at least beg/end time of range).
% spikeout{filenum,vlvindx,cellnum}{rptnum} contains the corresponding
%	spike times for the given cell.
% vlvsout: converts vlvindx to a valve number
%
% All times are measured in seconds.
if ~iscell(stimin)
	stimin = {stimin};
end
if ~iscell(spikein)
	spikein = {spikein};
end
nfiles = length(stimin);
if (size(spikein,1) ~= nfiles)
	error('Must have the same number of files in both stimin and spikein');
end
ncells = size(spikein,2);
% Find out the number of valves
if (nargin == 4)
	nvalves = length(vlvs);
	vlvsout = vlvs;
else
	vlvs = [];
	for i = 1:nfiles
		vlvs = unique([vlvs,stimin{i}(1,:)]);
	end
	vlvs = setdiff(vlvs,0);		% Do not include 0
	vlvsout = vlvs;
	nvalves = length(vlvs);
end
% Pre-allocate
stimout = cell(nfiles,nvalves);
spikeout = cell(nfiles,nvalves,ncells);
% Loop over files
for i = 1:nfiles
	v = stimin{i}(1,:);
	t = stimin{i}(2,:);
	vcom = intersect(v,vlvs);
	% Loop over the different valves & assemble a
	% list of the corresponding transition times
	ncom = length(vcom);
	indx = cell(1,ncom);
	indxnum = cell(1,ncom);
	for j = 1:ncom
		indx{j} = find(vcom(j) == v);
		indxnum{j} = find(vcom(j)==vlvs)*ones(size(indx{j}));
	end
	[allindx,permi] = sort(cat(2,indx{:}));
	allindxnum = cat(2,indxnum{:});
	allindxnum = allindxnum(permi);
	ttrans = t(allindx);
	% Find boundaries of regions around the chosen transitions
	tbeg = ttrans + trange(1);
	badi = find(tbeg < t(1));	% discard any that go over the edge
	tbeg(badi) = t(1);
	tend = ttrans + trange(2);
	badi = find(tend > t(end));
	tend(badi) = t(end);
	% Make stimulus snippets
	[tsbeg,tsbegi] = sort([t,tbeg]);	% Note orders are opposite: this handles ties correctly
	[tsend,tsendi] = sort([tend,t]);
	nt = length(t);
	nsnip = length(ttrans);
	ibeg = find(tsbegi > nt) - (1:nsnip);
	iend = find(tsendi <= nsnip) - (1:nsnip);
	for k = 1:nsnip
		rng = [ibeg(k):iend(k),iend(k)];
		tempsnip = [v(rng);t(rng)];
		tempsnip(2,1) = tbeg(k);
		tempsnip(2,end) = tend(k);
		stimout{i,allindxnum(k)}{end+1} = tempsnip;
	end
	% Make spike snippets
	for j = 1:ncells
		t = spikein{i,j}';
		[tsbeg,tsbegi] = sort([t,tbeg]);
		[tsend,tsendi] = sort([tend,t]);
		nt = length(t);
		ibeg = find(tsbegi > nt) - (1:nsnip);
		iend = find(tsendi <= nsnip) - (1:nsnip);
		for k = 1:nsnip
			spikeout{i,allindxnum(k),j}{end+1} = t((ibeg(k)+1):iend(k));
		end
	end
	% How to handle cases where valve was not turned on?
end
