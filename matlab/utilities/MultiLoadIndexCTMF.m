function [snipsct,header]  = MultiLoadIndexCTMF(spfiles,ctfiles,channels,indxsel,fullmultiindx)
% MultiLoadIndexSnippetsMF: concatenates indexed snippets from sequential files for multiple channels
% indx is a cell array with one vector/file, where the vector specifies the chosen
%multiindx is a cell array with a nchannels row array that specifies what snippets are to be chosen
%it is constructed from the spike times of the group of channels
% subset of snippets
nfiles=length(spfiles);nchans=length(channels);
hwait=waitbar (0,'Loading');
% h = ReadSnipHeader(spfiles{1});
h.sniprange = getSnipRange(spfiles{1});
snipsize=h.sniprange(2)-h.sniprange(1)+1;
t=cell(1,nfiles);
for fnum = 1:nfiles
	multiindxsel=fullmultiindx{fnum}(:,indxsel{fnum});
	if (length(multiindxsel)>0 )
% 		[snip1f,t{fnum}] = LoadIndexSnip(spfiles{fnum},channels(1),multiindxsel);
        [~, t{fnum}] = loadIndexSnip(spfiles{fnum}, 'spike', ...
            channels(1), multiindxsel);
	end
	if (length(indxsel{fnum}>0))
% 		header{fnum} = ReadSnipHeader(spfiles{fnum});
        header{fnum} = [];
	else
		header{fnum} = [];	
	end
end
clear snip1f
snipsct=cell(size(channels,2)-1,nfiles);
if (nchans>1)
	for fnum=1:nfiles
% 		snipsct(:,fnum) = loadaibdata(ctfiles(fnum),channels(2:end),t(fnum),h.sniprange);
        snipsct(:, fnum) = loadRawData(ctfiles(fnum), ...
            channels(2:end), t(fnum), h.sniprange);
		waitbar(fnum/nfiles*0.99);
	end
end
close(hwait);

