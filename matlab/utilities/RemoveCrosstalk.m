function [remtimes,remidx]= RemoveCrosstalk(g,ch1,ctchannels,h)
sortchannels=getappdata(h,'sortchannels');
handles = getappdata(h,'handles');
% nfiles=size(g.spikefiles,2);
nfiles = length(g.snipfiles);
chindices=find(ismember(g.channels,ctchannels));
if g.pwflag
	global sptimes
else
	%Load in times
	for ch=1:size(ctchannels,2)
		for fnum=1:nfiles;
% 			[sptimes{ch}{fnum},hdr]=LoadSnipTimes(g.spikefiles{fnum},ctchannels(ch));
            [~, sptimes{ch}{fnum}] = loadSnip(g.snipfiles{fnum}, 'spike', ctchannels(ch));
			sptimes{ch}{fnum}=[sptimes{ch}{fnum}';1:length(sptimes{ch}{fnum})];
		end
	end
	sptimes=removetimes (sptimes,g.chanclust(chindices),g.removedCT(chindices,:),1:size(chindices,2));
end
nctchans = size(ctchannels,2);
cpdf = [];
npb = {};
pair = zeros(0,2);
cttime=0.4;
ctsamp=0.5+cttime*g.scanrate(1)/1000;
idxc=cell(1,nctchans);
remtimes=idxc;
remidx=idxc;
for ch=1:nctchans
	idxc{ch}=cell(1,nfiles);
	remtimes{ch}=cell(1,nfiles);
end
for ch = 1:nctchans
	if g.pwflag
		[placeholder,idxc{ch}] = CrossCorrRecRow1(ch1(1,:),sptimes{ctchannels(ch)},ctsamp); %coincident spikes
	else
		[placeholder,idxc{ch}] = CrossCorrRecRow1(ch1(1,:),sptimes{ch},ctsamp); %coincident spikes
	end
	%Keep only the 2nd channel
	for fnum=1:nfiles
		if (size(idxc{ch}{fnum},2)>0)
			remtimes{ch}{fnum}=sptimes{ch}{fnum}(:,idxc{ch}{fnum}(2,:));
			remidx{ch}{fnum}=sptimes{ch}{fnum}(2,idxc{ch}{fnum}(2,:));%indexed to original snippet number
		end
	end
end

function [tccout,indxout] = CrossCorrRecRow1(t1,allt,tmax,nbins)
% Specialized modification of CrossCorrRec
% assumes allt has times in the first row
% CrossCorrRecRow1: compute spike crosscorrelations for vectors in a cell array
% [tccout,indxout] = CrossCorrRecRow1(t1,allt,tmax,nbins)
% Calling syntax is just like CrossCorr, except t1 & allt may be cell arrays
%   of spike time vectors
%
binning = 0;
if (nargin == 4)
	binning = 1;
end
if (nargout > 1 & binning)
	error('Only one output when binning');
end
if (~iscell(t1))			% Allow vector inputs for generality
	t1 = {t1};
end
if (~iscell(allt))
	allt = {allt};
end
if (length(t1) ~= length(allt))
	error('t1 and allt must have the same number of records');
end
if (binning)
	tccout = zeros(1,nbins);
	for i = 1:length(t1)
		if size(allt{i}, 2) > 0
			tccout = tccout + CrossCorr(t1{i},allt{i}(1,:),tmax,nbins);
		else
			warning('Skipping cross-talk on apparently empty channel');
		end
	end
else
	tccout = [];
	for i = 1:length(t1)
		if size(allt{i}, 2) > 0
			[tcctemp,indxout{i}] = CrossCorr(t1{i},allt{i}(1,:),tmax);
			tccout(end+1:end+length(tcctemp)) = tcctemp;
		else
			indxout{i} = [];
			warning('Skipping cross-talk on apparently empty channel');
		end
	end
end




