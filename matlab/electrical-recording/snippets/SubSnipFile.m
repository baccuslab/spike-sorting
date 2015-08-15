function SubSnipFile(snipfile,outfile,channels,keeptimes)
% SubSnip: Write a subset of snippets in one file to a new file
% SubSnip(snipfile,outfile,channels,keeptimes)
% snipfile: name of input file
% outfile: name of output file
% channels: selected channel #s
% keeptimes: a cell array, keeptimes{i} are the times of the selected
%	snippets from channels(i).
% If keeptimes is omitted, all snippets on the selected channels
% will be retained

% First open input & output files
[fidin,message] = fopen(snipfile,'r');
if (fidin < 1)
	error(message);
end
[fidout,message] = fopen(outfile,'w');
if (fidout < 1)
	error(message);
end
% Read original header
hin = ReadSnipHeader(fidin);
width = hin.sniprange(2)-hin.sniprange(1)+1;
hout = hin;	% Copy everything, then scale back
[chans,chindxin,chindxout] = intersect(hin.channels,channels);
if (length(chans) < length(channels))
	warning('Not all selected channels were recorded');
end
hout.channels = chans;
hout.thresh = hin.thresh(chindxin);
% Write the new header
[nsnppos,timepospos,snippospos] = WriteSnipHeader(fidout,hout);	% Leaves space for all the associated pointers
% Write the selected snippets from the selected channels
for i = 1:length(chans)
	nsnips = hin.numofsnips(chindxin(i));
	fseek(fidin,hin.timesfpos(chindxin(i)),'bof');
	timein = fread(fidin,nsnips,'int32');
	fseek(fidin,hin.snipsfpos(chindxin(i)),'bof');
	snipin = fread(fidin,[width,nsnips],'int16');
	if (nargin < 4)
		sindxin = 1:length(timein);
		nsnipsout = length(sindxin);
	else
		prednsnipsout = length(keeptimes{chindxout(i)});
		[dummy,sindxin] = intersect(timein,keeptimes{chindxout(i)});
		nsnipsout = length(sindxin);
		if (nsnipsout < prednsnipsout)
			warning(sprintf('Not all selected snippets were recorded on channel %d\n',chans(i)));
		end
	end
	tfpos = ftell(fidout);
	fwrite(fidout,timein(sindxin),'int32');
	sfpos = ftell(fidout);
	fwrite(fidout,snipin(:,sindxin),'int16');
	fpos = ftell(fidout);
	% Now go backwards in the file and update the header
	% information
	fseek(fidout,nsnppos(i),'bof');
	fwrite(fidout,nsnipsout,'int32');
	fseek(fidout,timepospos(i),'bof');
	fwrite(fidout,tfpos,'uint32');
	fseek(fidout,snippospos(i),'bof');
	fwrite(fidout,sfpos,'uint32');
	fseek(fidout,fpos,'bof');	% Return to last byte in file, for the next iteration
end
fclose(fidin);
fclose(fidout);
