function WriteCellFile(filename,record,chandef,wrapflag)
% WriteCellFile: write spike and stimulus data in Cell format
% WriteCellFile(filename,record,chandef,wrapflag)
% where
%	filename is the name of the output Cell file
%	record is a cell array containing the records
%	chandef is the vector of channel definitions for the cells
%	wrapflag (optional) is a flag determining whether
%		the timing data should be wrapped, to conform with
%		the Smartbox hardware limits. The default is 'nowrap',
%		and the resulting format version is 3. If one specifies
%		'wrap', format version 2 with wrapping is written. Note
%		that version 2 is the only version compatible with software
%		written before Sept. 1999.
if (nargin < 4)
	wrapflag = 'nowrap';
end
if (~ischar(wrapflag))
	error('Valid values for wrapflag are ''wrap'' and ''nowrap''');
end
if (nargin < 3)
	error('Must supply at least filename, records, and channel definitions');
end
% Gather some statistics, and check
% to see that the input data appears OK
nfiles = length(record);
nrecords = nfiles;
ncells = length(chandef);
for i = 1:nrecords
	if (length(record{i}.T) ~= ncells)
		error('chandef and the number of cells in record do not agree');
	end
end
nevents = 0;
nspikes(ncells) = 0;
for i = 1:nfiles
	nevents = nevents + length(record{i}.evT);
	for j = 1:ncells
		nspikes(j) = nspikes(j) + length(record{i}.T{j});
	end
end
% Open the file and start writing!
[fid,message] = fopen(filename,'w');
if (fid < 1)
	error(message)
end
% Write all the header info
format = 3;
if (strcmp(wrapflag,'wrap'))
	format = 2;
end
count = fwrite(fid,format,'int32');
if (count < 1)
	error(ferror(fid));
end
FileIndexPos = ftell(fid);
count = fwrite(fid,64,'int32');	% Placeholder for fileindex
if (count < 1)
	error(ferror(fid));
end
BoxIndexPos = ftell(fid);
count = fwrite(fid,68,'int32');	% Placeholder for boxindex
if (count < 1)
	error(ferror(fid));
end
RecIndexPos = ftell(fid);
count = fwrite(fid,1,'int32');	% Placeholder for recindex
if (count < 1)
	error(ferror(fid));
end
StatIndexPos = ftell(fid);
count = fwrite(fid,1,'int32');	% Placeholder for statindex
if (count < 1)
	error(ferror(fid));
end
skip = 64-ftell(fid);
count = fwrite(fid,zeros(1,skip),'int8');	% Move forward to 64th byte
if (count < skip)
	error(ferror(fid));
end
count = fwrite(fid,nfiles,'int16');	% Number of files
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,ncells,'int16');	% Number of boxes (not relevant, really)
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,nrecords,'int16');	% Number of records
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,ncells,'int16');	% Number of cells
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,nevents,'int32');	% Total number of events
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,sum(nspikes),'int32');	% Total number of spikes
if (count < 1)
	error(ferror(fid));
end

cpos = ftell(fid);		% Record current position
status = fseek(fid,FileIndexPos,'bof');
if (status < 0)
	error(ferror(fid));
else
	count = fwrite(fid,cpos,'int32');	% Update the FileInfo pointer
	if (count < 1)
		error(ferror(fid));
	end
end
status = fseek(fid,cpos,'bof');	% Return to current position
%_________
count = fwrite(fid,1,'int16');	% Dummy VolRefNum
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,filename,'uchar');	% Name of file
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,blanks(64-length(filename)),'uchar');	% Pad filename with spaces
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,blanks(64),'uchar');	% Blanks for Dir name
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,datenum(now),'int32');	% Current date and time
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,1,'int16');	%Low Record=1
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,1,'int16');	% NRecords=1
if (count < 1)
	error(ferror(fid));
end
count = fwrite(fid,1,'int16');	% Last record=1
if (count < 1)
	error(ferror(fid));
end

%_______
cpos = ftell(fid);		% Record current position
status = fseek(fid,BoxIndexPos,'bof');
if (status < 0)
	error(ferror(fid));
else
	count = fwrite(fid,cpos,'int32');	% Update the BoxIndex pointer
	if (count < 1)
		error(ferror(fid));
	end
end
status = fseek(fid,cpos,'bof');	% Return to current position

count = fwrite(fid,[1 2 3 4 5 6 7],'int32');	% Dummy Box info
if (count < 1)
	error(ferror(fid));
end


% Now write the records
cpos = ftell(fid);		% Record current position
status = fseek(fid,RecIndexPos,'bof');
if (status < 0)
	error(ferror(fid));
else
	count = fwrite(fid,cpos,'int32');	% Update the RecIndex pointer
	if (count < 1)
		error(ferror(fid));
	end
end
status = fseek(fid,cpos,'bof');	% Return to current position
if (status < 0)
	error(ferror(fid));
end
RecordOffsetPos = cpos;			% Save this for later updating
count = fwrite(fid,zeros(1,nrecords),'int32');
if (count < nrecords)
	error(ferror(fid));
end
for i = 1:nrecords
	% First update the pointer
	cpos = ftell(fid);
	status = fseek(fid,RecordOffsetPos+(i-1)*4,'bof');
	if (status < 0)
		error(ferror(fid));
	end
	count = fwrite(fid,cpos,'int32');
	if (count < 1)
		error(ferror(fid));
	end
	fseek(fid,cpos,'bof');
	if (status < 0)
		error(ferror(fid));
	end
	% Now write the data
	WriteCellRecord(fid,record{i},wrapflag);
end

% Now write the statistics; only do the
% channel definitions
cpos = ftell(fid);
status = fseek(fid,StatIndexPos,'bof');
if (status < 0)
	error(ferror(fid));
end
count = fwrite(fid,cpos,'int32');
if (count < 1)
	error(ferror(fid));
end
fseek(fid,cpos,'bof');
if (status < 0)
	error(ferror(fid));
end
count = fwrite(fid,chandef,'int16');
if (count < length(chandef))
	error(ferror(fid));
end
%Write total spikes on each channel (Steve 05/00)
for i=1:ncells
	count = fwrite(fid,nspikes(i),'int32');	% Total number of spikes
	if (count < 1)
		error(ferror(fid));
	end
end
for i=1:4000
	count=fwrite(fid,1,'int16');
end
fclose(fid);
return

function WriteCellRecord(fid,rec,wrapflag)
recClock = [0 65535];		% FIX THIS!
count = fwrite(fid,recClock,'uint16');
if (count < 2)
	error(ferror(fid));
end
count = fwrite(fid,length(rec.evT),'int32');
if (count < 1)
	error(ferror(fid));
end
nSpikes=0;
for i = 1:length(rec.T)
	nSpikes = nSpikes+ length(rec.T{i});
end
count = fwrite(fid,nSpikes,'int32');
if (count < length(nSpikes))
	error(ferror(fid));
end
for i = 1:length(rec.T)
	nSpikes = length(rec.T{i});
	count = fwrite(fid,sum(nSpikes),'int32');
	if (count < 1)
		error(ferror(fid));
	end
end
T = rec.evT;
if (strcmp(wrapflag,'wrap'))
	T = DoTimingWrap(T);
end
count = fwrite(fid,T,'int32');
if (count < length(T))
	error(ferror(fid));
end
count = fwrite(fid,rec.evW,'int16');
if (count < length(T))
	error(ferror(fid));
end
count = fwrite(fid,rec.evP,'int16');
if (count < length(T))
	error(ferror(fid));
end
for i = 1:length(rec.T)
	T = rec.T{i};
	if (strcmp(wrapflag,'wrap'))
		T = DoTimingWrap(T);
	end
	count = fwrite(fid,T,'int32');
	if (count < length(T))
		error(ferror(fid));
	end
end
return

function Tout = DoTimingWrap(Tin)
% Smartbox timing values wrap around every 2^23 ticks.
% Make the timing data look like it comes from the Smartbox.
Tout = mod(Tin,2^23);
return
