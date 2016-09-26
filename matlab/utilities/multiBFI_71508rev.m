function [filters,subrange,sv,wave] = multiBFI(spikefiles,ctfiles,noisefiles,nspikes,nnoise,channels,snipindx,spindx,h)
% tout{clustnum,filenum} = Times of spikes of cell # clustnum, in the file spikefiles{filenum}
% indexout: same as tout except it's the index # of the snippet rather than the time
% First figure out how many snippets we have/channel in each file
% Modified 1/18/08 SAB
% Fixed bug that variance filters wouldn't work with multiple random snippet files
nchans=size(channels,2);
[chans,mnsnips,ssniprange] = GetSnipNums(spikefiles);		%This is here solely to set ssniprange
for i = 1:length(snipindx)
	nsnips(i) = length(snipindx{i});
end

% Now load a representative sample of the snippets for filter construction
totsnips = sum(nsnips);
fracspike = min(nspikes/totsnips,1);
rangespike = BuildRangeMF(nsnips,fracspike);
indexspike = BuildIndexMF(rangespike,snipindx);
spikes=MultiLoadIndexSnippetsMF(spikefiles,ctfiles,channels,indexspike,spindx,h);
msnipsize=size(spikes,1);
onesnipsize=msnipsize/nchans;
multisniprange=ssniprange;
multisniprange(2)=multisniprange(1)+size(spikes,1)-1;
alldone = 0;
hfig = MultiChooseWaveforms(spikes,ssniprange(2)-ssniprange(1)+1,multisniprange);
while (alldone == 0)
	waitfor(hfig,'UserData','done');
	if (~ishandle(hfig))
		warning('Operation cancelled by user');
		filters = [];
		subrange = [];
		sv = [];
		wave = [];
		return
	end
goodspikes = getappdata(hfig,'GoodSpikes');
	sniprange = getappdata(hfig,'NewRange');
	if (length(goodspikes) <= sniprange(2)-sniprange(1))
		errordlg('Do not have enough spikes on this channel to build filters! Select more, or cancel.','','modal');
		set(hfig,'UserData','');
	else
		alldone = 1;
	end
end
close(hfig);
%if (nargin<8)
%	sniprange=[-6 18];
%end
%goodspikes=(1:size(spikes,2))';
%Modified 1/18/08 SAB
%Variance filters wouldn't work with multiple random snippet files
noiseindx=cell(1,size(spikefiles,2));
noiseindx(:)={1:nnoise};
if (size(noisefiles,2)<size(spikefiles,2))
	for fnum=1:size(spikefiles,2)
		noisefilesrep{fnum}=noisefiles{1};
	end
else
	noisefilesrep=noisefiles;
end
noise=MultiLoadIndexSnippetsMF(noisefilesrep,ctfiles,channels,noiseindx,noiseindx,h);
% Old version - fixed 1/18/08
%for ch=1:size(channels,2)
%	if (ch==1)
%		noise =MultiLoadIndexSnippetsMF(noisefiles,{},channels(ch),{1:nnoise},{1:nnoise},h);
%	else
%		noiseone =MultiLoadIndexSnippetsMF(noisefiles,{},channels(ch),{1:nnoise},{1:nnoise},h);
%		noise=[noise;noiseone];
%	end
%end
%noise = MultiLoadRandSnippetsMF(ctfiles,channels,nnoise,ssniprange);
subrange = [sniprange(1)-multisniprange(1)+1, sniprange(2)-multisniprange(1)+1];
snipsize=size(spikes,1)/nchans;
spikesedit=zeros(nchans*(sniprange(2)-sniprange(1)+1),size(goodspikes,1));
noiseedit=zeros(nchans*(sniprange(2)-sniprange(1)+1),size(noise,2));
for ch=1:nchans
	startedit=(sniprange(2)-sniprange(1)+1)*(ch-1)+1;
	endedit=(sniprange(2)-sniprange(1)+1)*ch;
	startfull=onesnipsize*(ch-1)+sniprange(1)-ssniprange(1)+1;
	endfull=onesnipsize*(ch-1)+sniprange(2)-ssniprange(1)+1;
	spikesedit(startedit:endedit,:)=spikes(startfull:endfull,goodspikes);
	noiseedit(startedit:endedit,:)=noise(startfull:endfull,:);
end
%spikesedit=removeoutliers(spikesedit);
[basefilters,basewave,sv] = Build2Filters(spikesedit,noiseedit);
filters=zeros(msnipsize,2);
wave=zeros(msnipsize,2);
for ch=1:nchans
	startedit=(sniprange(2)-sniprange(1)+1)*(ch-1)+1;
	endedit=(sniprange(2)-sniprange(1)+1)*ch;
	startfull=onesnipsize*(ch-1)+sniprange(1)-ssniprange(1)+1;
	endfull=onesnipsize*(ch-1)+sniprange(2)-ssniprange(1)+1;
	filters(startfull:endfull,:)=basefilters(startedit:endedit,:);
	wave(startfull:endfull,:)=basewave(startedit:endedit,:);
end
subrange=[1 msnipsize];
%[spikesfilt,IKeepFilt] = AlignSpikesFilt(spikes(:,goodspikes),filters(:,1));
%figure
%plot(spikesfilt)
%title('Aligned')
%filters = Build2Filters(spikesfilt,noise(subrange(1):subrange(2),:));

