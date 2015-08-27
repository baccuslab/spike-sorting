function [snipsct]  = MultiLoadIndexCTMF(spfiles,ctfiles,channels,indxsel,fullmultiindx)
% MultiLoadIndexSnippetsMF: concatenates indexed snippets from sequential files for multiple channels
% indx is a cell array with one vector/file, where the vector specifies the chosen
%multiindx is a cell array with a nchannels row array that specifies what snippets are to be chosen
%it is constructed from the spike times of the group of channels
% subset of snippets
nfiles=1; %when add mult file functionality, change nfiles to length(spfiles)
spfiles = {spfiles}; %make it a cell array of 1, when we add multiple file functionality, remove this
range=getSnipRange(spfiles{1}); %when we add mult file functionality, change this arg to spfiles
nchans=length(channels);
hwait=waitbar (0,'Loading');
% h = ReadSnipHeader(spfiles{1});
snipsize=range(2)-range(1)+1;
t=cell(1,nfiles);
for fnum = 1:nfiles
	multiindxsel=fullmultiindx{fnum}(:,indxsel{fnum});
	if (length(multiindxsel)>0 )
		[snip1f,t{fnum}] = loadSnip(spfiles{fnum},'spike',channels(1),len(multiindxsel));
	end
% 	if (length(indxsel{fnum}>0))
% 		header{fnum} = ReadSnipHeader(spfiles{fnum});
% 	else
% 		header{fnum} = [];	
% 	end
end
clear snip1f
snipsct=cell(size(channels,2)-1,nfiles);
if (nchans>1)
	for fnum=1:nfiles
		snipsct(:,fnum) = loadRawData(ctfiles(fnum),channels(2:end),t(fnum),h.sniprange);
		waitbar(fnum/nfiles*0.99);
	end
end
close(hwait);

