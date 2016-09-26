function hmain=setup(outfile,datafiles,snipfiles,channels, noise_channels,pwflag)
numch=length(channels);
numfiles=length(snipfiles);
if (~pwflag)
	if (isempty(dir('proj.bin')))
		%subsetbutton=questdlg ('Define spikes on a subset of data', '', 'yes', 'no','no');
		subsetbutton='no';
		%Default Filters
		%deffiltbutton=questdlg ('Choose default filters', '', 'load', 'calculate','load');
		deffiltbutton='calculate';
		switch deffiltbutton
		case 'load',
			[deffiltname,~]=uigetfile ('*.mat','Load default filters');
			load (deffiltname);
		case 'calculate',
			% Step 1: load in representatives of all channels
			fprintf('Building default filters:\n  Reading sample spike snippets from all channels...\n');
			numperfile = 50000/numfiles;
            spikes = cell(numfiles, 1);
            for i = 1:numfiles
                [spikes{i}, ssniprange] = readFromAllChannels(snipfiles{i}, ...
                    'spike', numperfile, channels);
            end
            spikes = [spikes{:}];
            
			% Step 2: do the same for noise
			fprintf('  Reading noise snippets from all channels...\n');
            noiseperfile = 5000 / length(snipfiles);
            noise = cell(numfiles, 1);
            for i = 1 : length(snipfiles)
                noise{i} = readFromAllChannels(snipfiles{i}, 'noise', ...
                    noiseperfile, noise_channels);
            end
            noise = [noise{:}];
            
			% Step 3: let user set sniprange
			deffilters=cell(1,numch);
            
			% Preprocess the spikes for building default filters, mean
			% subtract from each spike
            spikes = spikes - ones(size(spikes, 1), 1) * mean(spikes, 1);
            
			%take only the snippets that have the peak at time 0. Because the crosstalk snippet cutter
			%writes coincident snippets, the peak may be elsewhere, or there may not even be a spike.
			%spikes=spikes(:,find(max(spikes)==spikes(-ssniprange(1)+1,:)));
			%take only the biggest 50% of the spikes
			peakval=spikes(-ssniprange(1)+1,:); 
            [~, peakIdx] = sort(peakval);
            spikes = spikes(:, floor(end - length(peakIdx) / 2) : end);
			hfig = ChooseWaveforms(spikes, ssniprange);
			alldone = 0;
			while (alldone == 0)
				waitfor(hfig,'UserData','done');
				if (~ishandle(hfig))
					fprintf('Operation cancelled by user\n');
                    hmain = [];
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
        scanrate = double(h5readatt(snipfiles{1}, '/', 'sample-rate'));
        
		%Calculate default filter projections for all channels
        calcproj(snipfiles, 'proj.bin', channels, subrange, deffilters);
        
	end %If proj.bin does not exist
else
	global proj;
	channels=1:63;
	numfiles=1;
	numch=size(channels,2);
	chanclust = cell(1,numch);			%Cell clusters, contains spike times
 	removedCT=cell(numch,numfiles);	%Removed crosstalk, contains spike indices
	scanrate=20000;
end

%Create array plot
handles = makearraywindow (channels, getArrayType(datafiles{1}));

%Definitions
chanclust = cell(1,numch);			%Cell clusters, contains spike times
removedCT=cell(numch,numfiles);	%Removed crosstalk, contains spike indexes
xc=cell(1,numch);
yc=cell(1,numch);
nspikes=cell(numch,numfiles);
rectx=zeros(numch,2);
recty=zeros(numch,2);
set (handles.ch(1),'Units','Pixels');
pos=get(handles.ch(1),'Position');
nx=floor(pos(3));ny=floor(pos(4));
for ch=1:numch
	if (~pwflag)
        nsnips = getNumSnips(snipfiles);
		proj=loadproj('proj.bin',ch,numch,numfiles,nsnips(ch,:));
		[xc(ch),yc(ch),nspikes(ch),rectx(ch,:),recty(ch,:)]=Hist2dcalc(proj(1,:),nx,ny); 
	else
		[xc(ch),yc(ch),nspikes(ch),rectx(ch,:),recty(ch,:)]=Hist2dcalc(proj(ch),nx,ny); 
	end
end
Arrayplot (channels,handles.ch,xc,yc,nspikes);
%Indicate zero if not a peak-width plot
if ~pwflag
	for chindx=1:size(channels,2)
		axes(handles.ch(chindx));
		plot(0,0,'r+');
	end
end

%Define parameters to be 'globally' available
if (exist('subsetbutton', 'var') && strcmp(subsetbutton,'yes')) 
	g.samplesorting=1;
else
	g.samplesorting=0;
end
g.channels=channels;
g.ctchannels=[];
g.snipfiles=snipfiles;
g.ctfiles=datafiles;
g.xc=xc; g.yc=yc; g.nspikes=nspikes;g.rectx=rectx;g.recty=recty;
g.sniprange=sniprange;
g.nsnips=nsnips;
if  (pwflag) 
	setappdata (handles.main,'proj',proj);
	setappdata(handles.main,'nfiles',1);
else
	g.deffilters=deffilters;
	g.subrange=subrange;
end
g.chanclust=chanclust;
g.outfile=outfile;
g.removedCT=removedCT;
g.allchannels=channels;
g.pwflag=pwflag;
g.scanrate=scanrate(1);
g.subsetnum=20000;
g.array=getArrayType(datafiles{1});
setappdata (handles.main,'g',g);
hmain=handles.main; %Return handle to main array figure

function calcproj (files,outfile,channels,subrange,deffilters)
numch=length(channels);
numfiles = length(files);
projfp=zeros(numch, numfiles);
nsnips = getNumSnips(files, 'spike', channels);
loadn=50000;
fid=fopen(outfile,'w');
fwrite(fid,projfp,'int32');
for ch=1:numch
	fprintf('  Computing projection for channel %d\n', ch);
	for fnum=1:numfiles
		startn=1;
		endn=min(loadn,nsnips(ch,fnum));
		while (startn<=nsnips(ch,fnum))
            [snips, ~] = loadIndexSnip(files{fnum}, 'spike', channels(ch), startn:endn);
			proj(1:2,startn:endn)=deffilters{ch}'*snips(subrange(1):subrange(2),:);
			proj(3,startn:endn)=max(snips(subrange(1):subrange(2),:))-min(snips(subrange(1):subrange(2),:));
			startn=startn+loadn;
			endn=min(endn+loadn,nsnips(ch,fnum));
		end
		projfp(ch,fnum)=ftell(fid);
		if (exist('proj', 'var'))
			fwrite(fid,proj,'float32');
		end
		clear proj
	end
end
fseek(fid,0,'bof');
fwrite(fid,projfp,'int32');
fclose(fid);
clear snips sptimes
