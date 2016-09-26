function hmain=setup(outfile,spikefiles,noisefiles,channels,pwflag);
numch=size(channels,2);
numfiles=size(spikefiles,2);
if (~pwflag)
	if (isempty(dir('proj.bin')))
		%Default Filters
		deffiltbutton=questdlg ('Choose default filters', '', 'load', 'calculate','load');
		switch deffiltbutton
		case 'load',
			[deffiltname,deffiltpath]=uigetfile ('*.mat','Load default filters');
			load (deffiltname);
		case 'calculate',
			% Step 1: load in representatives of all channels
			fprintf('Building default filters:\n  Reading sample spike snippets from all channels...\n');
			numperfile = 15000/numfiles;
			spikes = [];
			for i = 1:numfiles
				[newspikes,ssniprange] = ReadFromAllChannels(spikefiles{i},numperfile,channels(find(channels~=2)));
				spikes = [spikes,newspikes];
			end
			% Step 2: do the same for noise
			fprintf('  Reading noise snippets from all channels...\n');
			noiseperfile = 5000/length(noisefiles);
			noise=[];
			for i = 1:length(noisefiles)
				newnoise = ReadFromAllChannels(noisefiles{i},noiseperfile,channels);
				noise = [noise,newnoise];
			end
			% Step 3: let user set sniprange
			deffilters=cell(1,numch);
			sv=cell(1,numch);
			wave=cell(1,numch);
			%Preprocess the spikes for building default filters
			for i=1:size(spikes,2) %subtract the mean
				spikes(:,i)=spikes(:,i)-mean(spikes(:,i));
			end
			%take only the snippets that have the peak at time 0. Because the crosstalk snippet cutter
			%writes coincident snippets, the peak may be elsewhere, or there may not even be a spike.
			spikes=spikes(:,find(max(spikes)==spikes(-ssniprange(1)+1,:)));
			%take only the biggest 50% of the spikes
			peakval=spikes(-ssniprange(1)+1,:); 
			peakval=[peakval;1:size(peakval,2)];
			peakval=sortrows(peakval')';
			peakval=peakval(:,floor(end-size(peakval,2)/2):end);
			spikes=spikes(:,peakval(2,:));
			hfig = ChooseWaveforms(spikes,ssniprange);
			alldone = 0;
			while (alldone == 0)
				waitfor(hfig,'UserData','done');
				if (~ishandle(hfig))
					fprintf('Operation cancelled by user\n');
					return
				end
				choosespikes = getappdata(hfig,'GoodSpikes');
				sniprange = getappdata(hfig,'NewRange');
				if (length(choosespikes) <= sniprange(2)-sniprange(1))
					errordlg('Do not have enough spikes on this channel to build filters! Select more, or cancel.','','modal');
					set(hfig,'UserData','');
				else
					alldone = 1;
				end
			end
			close(hfig);
			% Step 4: build the filters
			subrange = [sniprange(1)-ssniprange(1)+1, sniprange(2)-ssniprange(1)+1];	
			%remove outliers
			goodspikes=removeoutliers(spikes(subrange(1):subrange(2),choosespikes));
			[deffiltersall,waveall,svall] = Build2Filters(goodspikes,noise(subrange(1):subrange(2),:));
		end; %Switch for default filters
		for ch=1:numch
			deffilters{ch}=deffiltersall;
		end
		clear newnoise newspikes noise spikes
		assignin('base','DefaultFilt',deffilters);
		% Step 5: graphical output
		% Taken from DoChanFunctions
		figure('Name','Default filters','Position',[23   541   895   180]);
		subplot(1,3,1)
		hlines = plot(svall(1:min([15 length(svall)])),'r.');
		set(hlines,'MarkerSize',10);
		ylabel('Singular values');
		set(gca,'Tag','SVAxes');
		subplot(1,3,2)
		plot(waveall);
		ylabel('Waveforms');
		set(gca,'XLim',[1 size(waveall,1)]);
		set(gca,'Tag','WaveAxes');
		subplot(1,3,3)
		plot(deffiltersall);
		ylabel('Filters');
		set(gca,'XLim',[1 size(deffiltersall,1)]);
		set(gca,'Tag','FiltAxes');
		[fid,message] = fopen(spikefiles{1},'r'); %sorting continuous waveform data
		if (fid < 1)
			error(message)
		end
		header = ReadSnipHeader(fid);
		scanrate=header.scanrate;
		%Calculate default filter projections for all channels
		totsnips(length(channels))=0;
		projfp=zeros(numch,size(spikefiles,2));
		[placeholder,nsnips,sniprange] = GetSnipNums(spikefiles);
		loadn=50000;
		fid=fopen('proj.bin','w');
		fwrite(fid,projfp,'int32');
		for ch=1:numch
			ch
			for fnum=1:size(spikefiles,2)
				startn=1;
				endn=min(loadn,nsnips(ch,fnum));
				while (startn<=nsnips(ch,fnum))
					[snips,sptimes] = LoadIndexSnip(spikefiles{fnum},channels(ch),startn:endn);
					proj(1:2,startn:endn)=deffilters{ch}'*snips(subrange(1):subrange(2),:);
					proj(3,startn:endn)=max(snips(subrange(1):subrange(2),:))-min(snips(subrange(1):subrange(2),:));
					startn=startn+loadn;
					endn=min(endn+loadn,nsnips(ch,fnum));
				end
				projfp(ch,fnum)=ftell(fid);
				if (exist('proj'))
					fwrite(fid,proj,'float32');
				end
				clear proj
			end
		end
		fseek(fid,0,'bof');
		fwrite(fid,projfp,'int32');
		clear snips sptimes
	end %If proj.bin does not exist
else
	global proj,sptimes;
	channels=1:63;
	numfiles=1;
	numch=size(channels,2);
	chanclust = cell(1,numch);			%Cell clusters, contains spike times
 	removedCT=cell(numch,numfiles);	%Removed crosstalk, contains spike indices
	scanrate=20000;
end
if (pwflag)
	proj=getappdata(handles.main,'proj');
	global sptimes
end
%Create array plot
handles = makearraywindow (channels);

%Definitions
chanclust = cell(1,numch);			%Cell clusters, contains spike times
removedCT=cell(numch,numfiles);	%Removed crosstalk, contains spike indexes
%times=removetimes (times,chanclust,removedCT,1:size(g.channels,2));
xc=cell(1,numch);
yc=cell(1,numch);
nspikes=cell(numch,numfiles);
rectx=zeros(numch,2);
recty=zeros(numch,2);
set (handles.ch(1),'Units','Pixels');
pos=get(handles.ch(1),'Position');
nx=floor(pos(3));ny=floor(pos(4));
[placeholder,nsnips,placeholder] = GetSnipNums(spikefiles);
for ch=1:numch
	if (~pwflag)
		proj=loadproj(ch,numch,numfiles,nsnips(ch,:));
	end
	[xc(ch),yc(ch),nspikes(ch),rectx(ch,:),recty(ch,:)]=Hist2dcalc(proj(1,:),nx,ny); 
end
Arrayplot (channels,handles.ch,xc,yc,nspikes);
%Indicate zero if not a peak-width plot
if ~pwflag
	for chindx=1:size(channels,2)
		axes(handles.ch(chindx));
		plot(0,0,'r+');
	end
end

%Load spikes times for plotting cross-correlations
plottimes=cell(1,numch);
loadn=100000/numch/numfiles;
for ch=1:numch
	plottimes{ch}=cell(1,numfiles);
	for fnum=1:numfiles	
		[plottimes{ch}{fnum},header]=LoadSnipTimes(spikefiles{fnum},channels(ch),loadn);
		plottimes{ch}{fnum}=[plottimes{ch}{fnum}'; 1:size(plottimes{ch}{fnum},1)]; %2nd row is spike index number
	end
end

%Define parameters to be 'globally' available
g.channels=channels;
g.ctchannels=[];
g.spikefiles=spikefiles;
g.xc=xc; g.yc=yc; g.nspikes=nspikes;g.rectx=rectx;g.recty=recty;
g.plottimes=plottimes;
g.sniprange=sniprange;
g.nsnips=nsnips;
if  (pwflag) 
	setappdata (handles.main,'proj',proj);
	setappdata(handles.main,'nfiles',1);
else
	g.noisefiles=noisefiles;
	g.deffilters=deffilters;
	g.subrange=subrange;
end
g.chanclust=chanclust;
g.outfile=outfile;
g.removedCT=removedCT;
g.allchannels=channels;
g.pwflag=pwflag;
g.scanrate=scanrate(1);
setappdata (handles.main,'g',g);
hmain=handles.main; %Return handle to main array figure

