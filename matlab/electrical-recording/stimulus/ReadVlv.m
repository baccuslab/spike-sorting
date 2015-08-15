function [files,stim] = ReadVlv(filename)
% ReadVlv: Read the output of CalcStim, the time course of the stimulus
% [files,stim] = ReadVlv(filename)
% On output,
%	files is a cell array of filenames
%	stim is a cell array of 2-by-n matrices, containing the
%		valve number and scan number of each transition
files = {};
stim = {};
[fid,message] = fopen(filename,'rt');
if (fid < 0)
	error(message);
end
line = GetRealLine(fid);
while (length(line) > 0)
	[files{end+1},tempstim] = strtok(line,'{');	% The filename precedes '{'
	stim{end+1} = sscanf(tempstim(2:end),'%d',[2,inf]);
	line = GetRealLine(fid);
end
fclose(fid);
files = deblank(files);	% eliminate the trailing space

function line = GetRealLine(fid)
% Skip over comments and blank lines
% Comments begin with a '%'
line = fgetl(fid);
while ((length(line) == 0 | strcmp(line(1),'%')) & ~feof(fid))
	line = fgetl(fid);
end
if (strcmp(line(1),'%') | ~ischar(line))
	line = [];
end
