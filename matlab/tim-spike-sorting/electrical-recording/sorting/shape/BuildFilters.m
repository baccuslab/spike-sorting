% A script to build filters
%LoadSpikeSnippets;
%disp('Spikes are in variable "spikes." Edit them now; type "return" to resume');
%keyboard
%figure(gcf)
%LoadRandSnippetsDlg;
% Construct the filters by a 2-pass procedure:
% build preliminary filters from crudely aligned spikes,
% then realign them using the crude spike detection filter,
% and finally build better filters from the realigned spikes
spikespeak = polarity*AlignSpikesPeak(polarity*spikes);
figure
plot(spikespeak)
title('Peak-aligned spikes');
spselect = spikespeak(fsniprange(1)-1:fsniprange(2)-1,:);
[f1,w1,sv1] = CalcFiltFromSnips(spselect,snipRand);
[spikesfilt,IKeepFilt] = AlignSpikesFilt(spikes,f1(:,1));
figure
plot(spikesfilt)
title('Filter1-aligned spikes');
[f2,w2,sv2] = CalcFiltFromSnips(spikesfilt,snipRand);
%sv2 = sv1;
%w2 = w1;
%f2 = f1;
%spikesfilt = spikespeak;
figure
plot(sv2(1:min([15 length(sv2)])),'r.')
hlines = findobj(gcf,'Type','line');
set(hlines,'MarkerSize',10);
title('Singular values');
% Show the filters
answer = inputdlg('Number of significant filters:','',1,{'3'});
if isempty(answer)
	error('Interrupted by user');
end
nfilt = str2num(answer{1});
figure
subplot(2,1,1)
plot(w2(:,1:nfilt));
title('Waveforms');
subplot(2,1,2)
plot(f2(:,1:nfilt));
title('Filters');
% Get set on saving filters
outdefname = strcat(datafile(1:findstr(datafile,'.bin')-1),'.flt');
[outfilename,outpath] = uiputfile(outdefname,'Save filter file as:');
if (outfilename == 0)
	error('Interrupted by user');
end
% Set up output data (& their names) nicely, in case
% user wants to mess with things more
sniprange = ssniprange(1)+fsniprange-1;
thresh = min(spikesfilt'*f2(:,1));	% The min value of projection of spike det filt
filt = f2(:,1:nfilt);
wave = w2(:,1:nfilt);
sv = sv2;
% Save the filters
WriteFilters([outpath,outfilename],filt,wave,sv,sniprange,thresh);
% Create a record of user choices
UserRecord.datapath = datapath;
UserRecord.datafile = datafile;
UserRecord.activechan = activechan;
UserRecord.polarity = polarity;
UserRecord.thresh = thresh;
UserRecord.widesnip = ssniprange;
UserRecord.nspike = nspike;
UserRecord.subrange = fsniprange;
UserRecord.nrand = nrand;
UserRecord.nfilt = nfilt;
UserRecord.outpath = outpath;
UserRecord.outfilename = outfilename;
buttonname = questdlg('Do you want to save a record of your choices?');
if (strcmp(buttonname,'Yes'))
	recdefname = strcat('UsrChoices',datafile(1:findstr(datafile,'.bin')-1),'.mat');
	[outrecname,outrecpath] = uiputfile(recdefname,'Save user choices as:');
	save([outrecpath,outrecname],'UserRecord');
end
% Clean up (don't pollute, but leave all the variables that will
% be needed if this function is called again)
clear f1 f2 w1 w2 sv1 sv2 spselect prompt def answer recdefname outdefname
clear buttonname outfilename outpath
clear outrecpath outrecname
clear intrsct irec isel
