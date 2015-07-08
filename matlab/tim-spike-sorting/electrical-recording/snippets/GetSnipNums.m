function [chans,nsnips,sniprange] = GetSnipNums(filenames)
% GetSnipNums: determine # of snippets/channel for a list of files
% [chans,nsnips,sniprange] = GetSnipNums(filenames)
% nsnips(indxc,indxf) is the number of snippets on channel chans(indxc)
%    in file filenames{indxf}.
% Note that the recorded channels do NOT have to be the same
% across all files, can drop & add channels during experiment
if (length(filenames) == 0)
	chans = [];
	nsnips = [];
	sniprange = [];
	return
end
% First read in all the relevant header data
for i = 1:length(filenames)
	h = ReadSnipHeader(filenames{i});
	filechans{i} = h.channels;
	filesnips{i} = h.numofsnips;
	sr(i,:) = h.sniprange;
end
% Check to make sure that all snippets have the same sniprange
if (length(filenames) > 1)
	diffrange = diff(sr);
	if (length(find(diffrange)) > 0)
		error('All files must have the same sniprange');
	end
end
sniprange = sr(1,:);
% Now find the union of all channel #s
chans = unique(cat(2,filechans{:}));
% Deal out the information from headers into a matrix
nsnips = zeros(length(chans),length(filenames));
for j = 1:length(filenames)
	for i = 1:length(chans)
		chanindx = find(filechans{j} == chans(i));
		if (isempty(chanindx))
			nsnips(i,j) = 0;
		else
			nsnips(i,j) = filesnips{j}(chanindx);
		end
	end
end
