function [snips,filenum,t] = LoadIndexSnippetsMF(filenames,sniptype,chan,indx)
% LoadIndexSnippetsMF: concatenates indexed snippets from sequential files
% [snips,filenum,t] = LoadIndexSnippetsMF(filenames,sniptype,chan,indx)
% Much like LoadSnippetsMF, except that only a subset of the total snippets is
% returned.
% indx is a cell array with one vector/file, where the vector specifies the chosen
% subset of snippets
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Tim Holy
%   - wrote it
%
% 2015-09-02 - Lane McIntosh
%   - using new hdfio functions

for i = 1:length(filenames)
	cindx = indx{i};
	if (~isempty(cindx))
		[snipc{i},tc{i}] = loadSnipIndex(filenames{i},sniptype,chan,cindx);
		fc{i}(1,:) = i*ones(1,length(cindx));
		fc{i}(2,:) = 1:length(cindx);
	else
		snipc{i} = [];
		fc{i} = [];
		tc{i} = [];
	end
end
snips = cat(2,snipc{:});
filenum = cat(2,fc{:});
%t = cat(2,tc{:});
t = tc;
