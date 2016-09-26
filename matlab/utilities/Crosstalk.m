function [ctchannels,idxc] = Crosstalk(g,ch1,tmax,h)
% CrossCorrAll: Compute spike time cross correlations for all pairs
% [cpdf,pair] = CrossCorrAll(tall,tmax):
%	Input:
%		alltimes: alltimes{i,j} is a vector of spike times. alltimes(i,:) should be a
%			cell array of related spike times, i.e. same channel or same cell.
%		tmax: maximum time separation to include
% 		handles.cc:array of axis handles to the main cross-correlation plots
%		handles.main:figure handle to main array figure
%	Output: sorted in order of least-flat cross correlation
%		idxc = indexes of coincident spikes (crosstalk) to be removed
chindices=getappdata(h,'chindices');
handles = getappdata(h,'handles');
sortchannels =getappdata (h,'sortchannels');
allchannels = g.channels;
nfiles=size(g.spikefiles,2);
if g.pwflag
	global proj sptimes
else
	proj=loadproj('proj.bin',1:size(allchannels,2),size(allchannels,2),nfiles,2000);	
	sptimes=g.plottimes;
end
nchans = size(allchannels,2);
cpdf = [];
npb = {};
pair = zeros(0,2);
ctsamp=0.5+str2num(get(findobj(handles.main,'Tag','cttime'),'String'))*g.scanrate(1)/1000;
idxc=cell(1,nchans);
for ch = 1:nchans
	idxc{ch}=cell(1,4);
	npbtemp = CrossCorrRecRow1(ch1(1,:),sptimes{ch},tmax,20); %CrossCorrRecRow1 this file below
	[~,idxc{ch}] = CrossCorrRecRow1(ch1(1,:),sptimes{ch},ctsamp); %coincident spikes
	%Keep only the 2nd channel
	for fnum=1:nfiles
		if (size(idxc{ch}{fnum},2)>0)
			idxc{ch}{fnum}=idxc{ch}{fnum}(2,:);%keep only the 2nd channel
		end
	end
	nbins = 30;
	npb{end+1} = rehist(npbtemp,nbins);
	pair(end+1,1:2) = [1 ch];
end

% Now compute chisq for each of these
for i = 1:length(npb)
	mncc(i) = median(npb{i})+1;
end
for i = 1:length(npb)
	if (mncc(i) > 0)
		dn = npb{i}-mncc(i);
		chisq(i) = (dn*dn')/mncc(i);
		cpdf(i) = chisq(i)/length(dn);
	else
		chisq(i) = 0;
		cpdf(i) = 0;
	end
end
ymax=0;
for i=1:length(npb)
	if (max(npb{i})>ymax)
		ymax=max(npb{i});
	end
end
if  (ymax==0)
	ymax=ymax+1;
end
%Remove the peak at zero time on channel one
nbins=20;
npb{chindices(1)}(floor(nbins/2):floor(nbins/2+1))=0;

%Plot cross correlations
figure (handles.main);
hctlist=getappdata(h,'hctlist');
setappdata (handles.main,'hctlist',hctlist);
Arrayplot (allchannels,handles.ch,g.xc,g.yc,g.nspikes) 
ctchannels=[];
for chindx = 1:nchans
	hax=handles.cc(chindx);
	axes(hax);
	nbins = length(npb{chindx});
	binwidth = 2*tmax/nbins;
	xax = linspace(-tmax+binwidth/2,tmax-binwidth/2,nbins);
	if  (cpdf(chindx)>500)
		%set(gcf,'defaultaxesxcolor',[1 0 0]);
		bar(xax,npb{chindx},1,'k');
		set(hax,'Color',[1 0.8 0.8])
		setappdata(hax,'CTselected',1);
		ylim([0 ymax]);
		ctchannels=[ctchannels allchannels(chindx)];
		%set(gcf,'defaultaxesxcolor',[0 0 0]);
	else
		%set(gcf,'defaultaxesxcolor',[0 1 1]);
		bar(xax,npb{chindx},1,'k')
		set(hax,'Color',[0.8 1 1])
		setappdata(hax,'CTselected',0);
		ylim([0 ymax]);
		%set(gcf,'defaultaxesxcolor',[0 0 0]);
	end
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
ctchannels=setdiff(ctchannels,sortchannels(1));
%Plot coincident spikes'
for ch = 1:nchans
	hax=handles.ch(ch);
	axes(hax);
	%set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
	%set(gca,'box','off')
	%set(gca,'XColor',[0.8 0.8 0.8])
	%set(gca,'YColor',[0.8 0.8 0.8])
	
	for  fnum=1:nfiles
		if (length(sptimes{ch}{fnum})>=1)
			idxorig=sptimes{ch}{fnum}(2,idxc{ch}{fnum});%indexes to spikes before removal
			projc=proj{ch,fnum}(:,idxorig(idxorig<size(proj{ch,fnum},2)));
			if (size(g.xc{ch},2)>1)
				plot(projc(2,:),projc(1,:),'r.');
			end
		end
	end
end
g.ctchannels=ctchannels;
setappdata (handles.main,'g',g);
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
if (nargout > 1 && binning)
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
		tccout = tccout + CrossCorr(t1{i},allt{i}(1,:),tmax,nbins);
	end
else
	tccout = [];
	for i = 1:length(t1)
		[tcctemp,indxout{i}] = CrossCorr(t1{i},allt{i}(1,:),tmax);
		tccout(end+1:end+length(tcctemp)) = tcctemp;
	end
end




