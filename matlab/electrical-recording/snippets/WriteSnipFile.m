function WriteSnipFile(filename,header,snips,times)
% WriteSnipFile: writes a set of snippets to disk in standard format
% WriteSnipFile(header,snips,times)
% snips and times are cell arrays, where each element of the cell
%	array is the data for a given channel.
% Exception: if snips & times are matrices, one channel is assumed.
% snips values are supplied in int16 values
% Not all information in the header has to be correct; the obvious
% 	stuff is fixed before writing. It's not a bad idea to use
%	the header from some other snippet file as a template.
if (~iscell(snips))
	snips = {snips};
end
if (~iscell(times))
	times = {times};
end
nchans = length(snips);
if (length(header.channels) ~= nchans)
	error('The number of channels in header.channels does not match');
end
if (length(times) ~= nchans)
	error('The number of channels in snips and times does not match');
end
for i = 1:nchans
	if (length(times{i}) ~= size(snips{i},2))
		error('The number of times does not always match the number of snippets');
	end
end
[fid,message] = fopen(filename,'w');
if (fid < 1)
	error(message);
end
[nsnppos,timepospos,snippospos] = WriteSnipHeader(fid,header);
for i = 1:nchans
	tfpos = ftell(fid);
	fwrite(fid,times{i},'int32');
	sfpos = ftell(fid);
	%fwrite(fid,round((snips{i}-header.scaleoff)/header.scalemult),'int16');
	fwrite(fid,snips{i},'int16');
	fpos = ftell(fid);
	% Now go backwards in the file and update the header
	% information
	fseek(fid,nsnppos(i),'bof');
	fwrite(fid,length(times{i}),'int32');
	fseek(fid,timepospos(i),'bof');
	fwrite(fid,tfpos,'uint32');
	fseek(fid,snippospos(i),'bof');
	fwrite(fid,sfpos,'uint32');
	fseek(fid,fpos,'bof');	% Return to last byte in file, for the next iteration
end
fclose(fid);
