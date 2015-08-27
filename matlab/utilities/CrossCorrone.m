function CrossCorrone(tmax)
% CrossCorrAll: Compute spike time cross correlations for all pairs
% [cpdf,pair] = CrossCorrAll(tall,tmax):
%	Input:

%		tmax: maximum time separation to include
%	Output: sorted in order of least-flat cross correlation
%		idxc = indexes of coincident spikes (crosstalk) to be removed
%     Variables:
%		times: times{i,j} is a vector of spike times. times(i,:) should be a
%			cell array of related spike times, i.e. same channel or same cell.
% 		hcc:array of axis handles to the main cross-correlation plots
h=gcbf;
handles=getappdata (h,'handles');
g=getappdata(handles.main,'g');
if (g.pwflag)
	%Fix this to be g.times
	global times;
end
ch1 = str2num(get(findobj(h,'Tag','ccchannel'),'String'));
%Convert cttime to scans. 
cttime =str2num(get(findobj(h,'Tag','cttime'),'String'))*g.scanrate/1000;
chindx=find(g.channels==ch1);
allchannels = g.channels;
nchans = size(allchannels,2);
cpdf = [];
npb = {};
pair = zeros(0,2);
idxc=cell(1,nchans);
nbins=20;
%Coincidence time, in samples
ctsamp=0.5+str2num(get(findobj(handles.main,'Tag','cttime'),'String'))*g.scanrate/1000;
for ch = 1:nchans
	idxc{ch}=cell(1,4);
	npbtemp = CrossCorrRecRow1(g.plottimes{chindx},g.plottimes{ch},tmax,nbins); %CrossCorrRecRow1 this file below
	[~,idxc{ch}] = CrossCorrRecRow1(g.plottimes{chindx},g.plottimes{ch},ctsamp); %coincident spikes
	%Keep only the 2nd channel
	for fnum=1:length(g.spikefiles)
		if (size(idxc{ch}{fnum},2)>0)
			idxc{ch}{fnum}=idxc{ch}{fnum}(2,:);%keep only the 2nd channel
		end
	end
	nbins = 30;
	npb{end+1} = rehist(npbtemp,nbins);
	pair(end+1,1:2) = [1 ch];
end
%Remove the peak at zero time on channel one
npb{chindx}(floor(nbins/2):floor(nbins/2+1))=0;
ymax=0;
for i=1:length(npb)
	if (max(npb{i})>ymax)
		ymax=max(npb{i});
	end
end
%Plot cross correlations
ctchannels=[];
for chindx = 1:nchans
	hax=handles.cc(chindx);
	axes(hax);
	nbins = length(npb{chindx});
	binwidth = 2*tmax/nbins;
	xax = linspace(-tmax+binwidth/2,tmax-binwidth/2,nbins);
	bar(xax,npb{chindx},1,'k')
	set(hax,'Color',[0.8 1 1])
	setappdata(hax,'CTselected',0);
	ylim([0 ymax])
	setappdata(hax,'cc',npb{chindx});
	setappdata(hax,'xax',xax);
	set(hax,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
	set(hax,'box','off')
	set(hax,'XColor',[0.8 0.8 0.8])
	set(hax,'YColor',[0.8 0.8 0.8])
	set(hax,'XLim',[-tmax,tmax]);
	set(hax,'ButtonDownFcn','CTfunctions');
	%title(sprintf('%d and %d',pair(chindx,1),pair(chindx,2)))
	vx=xlim; %vx used because xlim(1) tries to set the xlim instead of returning a value
	vy=ylim;
	text(vx(1)+(vx(2)-vx(1))/20,vy(2)-(vy(2)-vy(1))/10,num2str(allchannels(chindx)));	
end
ctchannels=setdiff(ctchannels,ch1);
g.ctchannels=ctchannels;
setappdata(h,'g',g)


function [tccout,indxout] = CrossCorrRecRow1(t1,allt,tmax,nbins)
% Specialized modification of CrossCorrRec
% assumes allt has times in the first row
% CrossCorrRecRow2: compute spike crosscorrelations for vectors in a cell array
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
		tccout = tccout + CrossCorr(t1{i}(1,:),allt{i}(1,:),tmax,nbins);
	end
else
	tccout = [];
	for i = 1:length(t1)
		[tcctemp,indxout{i}] = CrossCorr(t1{i}(1,:),allt{i}(1,:),tmax);
		tccout(end+1:end+length(tcctemp)) = tcctemp;
	end
end




