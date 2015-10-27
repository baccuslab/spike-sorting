function spikesort(dirOrFiles)
%
% FUNCTION spikesort(dirOrFiles)
%
% Run the Baccus lab spike sorting code pipeline. Any snippet files
% that don't already exist will be created.
%
% INPUT:
%	dirOrFiles	- If a string, this is assumed to be a directory. All
%					data files in that directory will be sorted. If
%					A cell array of strings, sort the given datafiles,
%					and their corresponding snippet files.
%
% OUTPUT:
%	None
%
% (C) 2015 Benjamin Naecker bnaecker@stanford.edu

oldPwd = pwd;
if nargin == 0
	dirOrFiles = '.';
end
if ischar(dirOrFiles)
	d = dirOrFiles;
	cd(d);
	dirContents = dir();
	names = {dirContents.name};
	matchString = '[a-z0-9_-]*\.h5';
	datafiles = names(cellfun(@(x) ~isempty(x), regexp(names, matchString)));
else
	datafiles = dirOrFiles;
end
snipfiles = cell(size(datafiles));
for fi = 1:length(snipfiles)
	snipfiles{fi} = regexprep(datafiles{fi}, 'h5', 'snip');
	if ~exist(snipfiles{fi}, 'file')
		fprintf(1, 'extracting snippets from %s\n', datafiles{fi});
		[status, msg] = system(sprintf('extract %s', datafiles{fi}));
		if status
			error(msg)
		end
	end
end

above = regexp(pwd, '/', 'split');
groupcw(sprintf('%s.mat', above{end}), datafiles, snipfiles);
cd(oldPwd);
