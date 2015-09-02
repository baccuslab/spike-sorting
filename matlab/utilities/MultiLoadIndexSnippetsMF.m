function [snips,filenum]  = MultiLoadIndexSnippetsMF(spfiles,ctfiles,channels,indxsel,fullmultiindx,hsort)
% MultiLoadIndexSnippetsMF: concatenates indexed snippets from sequential files for multiple channels
% indx is a cell array with one vector/file, where the vector specifies the chosen
%multiindx is a cell array with a nchannels row array that specifies what snippets are to be chosen
%it is constructed from the spike times of the group of channels
% subset of snippets
% h = ReadSnipHeader(spfiles{1});
range=getSnipRange(spfiles{1}); %range is same across all files, so we can just read it off one of them
snipsize=range(2)-range(1)+1;
nfiles=length(spfiles); %check this
nchans=length(channels);
t=cell(1,nfiles);
snipspcell=cell(1,nfiles);
for fnum = 1:nfiles
	multiindxsel=fullmultiindx{fnum}(:,indxsel{fnum});
	if (length(multiindxsel)>0 )
		[snipspcell{1,fnum},t{fnum}] = loadSnipIndex(spfiles{fnum},'spike',channels(1),multiindxsel);
	end
	if (length(indxsel{fnum}>0))
		fc{fnum}(1,:) = fnum*ones(1,length(indxsel{fnum}));
		fc{fnum}(2,:) = 1:length(indxsel{fnum});
% 		header{fnum} = ReadSnipHeader(spfiles{fnum});
	else
		fc{fnum} = [];
		header{fnum} = [];	
	end
end
snips=cat(2,snipspcell{:});
filenum = cat(2,fc{:});
if (nchans>1)
	stored=0;%Done this cumbersome way because Matlab evaluates all parts of a boolean, 
			%even if its not necessary
	if (exist ('hsort'))
		if (getappdata(hsort,'Storestatus'))
			stored=1;
		end
	end
	if (stored)
		snipctcell=getsnipsfrommem(indxsel,hsort); %crosstalk is the previously loaded snippets
	else
		snipctcell=cell(nchans-1,nfiles); flist=[]; %Don't call loadaibdata with empty lists
		for fn=1:nfiles
			if (~isempty(t{fn}))
				flist=[flist  fn];
			end
		end
		if (~isempty(flist))
			snipctcell(:,flist)= loadRawData(ctfiles(flist),channels(2:end),t(flist),h.sniprange); %crosstalk is a list of files
		end
	end
	snipctchans=cell(nchans-1,1);
	for ch=2:nchans
		temp=snipctcell(ch-1,:);
		snipctchans{ch-1}=cat(2,temp{:});
	end
	snips=[{snips};snipctchans];
	snips=cat(1,snips{:});
end

