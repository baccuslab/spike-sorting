function [filters,subrange,sv,wave] = BFI(spikefiles,noisefiles,nspikes,nnoise,channel,snipindx)
% tout{clustnum,filenum} = Times of spikes of cell # clustnum, in the file spikefiles{filenum}
% indexout: same as tout except it's the index # of the snippet rather than the time
subset = 0;
if (nargin == 6), subset = 1; end
% First figure out how many snippets we have/channel in each file
if (subset)
	[chans,mnsnips,ssniprange] = GetSnipNums(spikefiles);		%This is here solely to set ssniprange
	for i = 1:length(snipindx)
		nsnips(i) = length(snipindx{i});
	end
else
	[chans,mnsnips,ssniprange] = GetSnipNums(spikefiles);
	chindx = find(chans == channel);
	nsnips = mnsnips(chindx,:);
end
% Do the same for noise snippets. No indexing necessary here!
[chans,mnoise,nsniprange] = GetSnipNums(noisefiles);
chindx = find(chans == channel);
nnoise = mnoise(chindx,:);
% Now load a representative sample of the snippets for filter construction
totsnips = sum(nsnips);
totnoise = sum(nnoise);
fracspike = min(nspikes/totsnips,1);
fracnoise = min(nnoise/totnoise,1);
if (fracnoise*nnoise < ssniprange(2)-ssniprange(1))
	error('Do not have enough noise snippets on this channel to build filters!');
end
rangespike = BuildRangeMF(nsnips,fracspike);
if (subset)
	indexspike = BuildIndexMF(rangespike,snipindx);
else
	indexspike = BuildIndexMF(rangespike);
end
indexnoise = BuildIndexMF(BuildRangeMF(nnoise,fracnoise));
spikes = LoadIndexSnippetsMF(spikefiles,channel,indexspike);
alldone = 0;
hfig = ChooseWaveforms(spikes,ssniprange);
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
noise = LoadIndexSnippetsMF(noisefiles,channel,indexnoise);
%noise = 50*randn(ssniprange(2)-ssniprange(1)+1,nnoise);
subrange = [sniprange(1)-ssniprange(1)+1, sniprange(2)-ssniprange(1)+1];
[filters,wave,sv] = Build2Filters(spikes(subrange(1):subrange(2),goodspikes),noise(subrange(1):subrange(2),:));
%[spikesfilt,IKeepFilt] = AlignSpikesFilt(spikes(:,goodspikes),filters(:,1));
%figure
%plot(spikesfilt)
%title('Aligned')
%filters = Build2Filters(spikesfilt,noise(subrange(1):subrange(2),:));
