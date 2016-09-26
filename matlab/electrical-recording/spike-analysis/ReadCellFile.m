function [record,header] = ReadCellFile(filename)
% [record,header] = ReadCellFile(filename)
% Read the file output by "Group" or "Box" (MM).
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header.format = fread(fid,1,'int32');
if (header.format ~= 2)
	error('Don''t recognize format');
end
FileIndex = fread(fid,1,'int32');
BoxIndex = fread(fid,1,'int32');
RecIndex = fread(fid,1,'int32');
StatIndex = fread(fid,1,'int32');
status = fseek(fid,64,'bof');
if (status < 0)
	error(ferror(fid));
end
header.NFiles = fread(fid,1,'int16');
header.NBoxes = fread(fid,1,'int16');
header.NRecords = fread(fid,1,'int16');
header.NCells = fread(fid,1,'int16');
header.NEvents = fread(fid,1,'int32');
header.NSpikes = fread(fid,1,'int32');
status = fseek(fid,RecIndex,'bof');
if (status < 0)
	error(ferror(fid));
end
RecordOffset = fread(fid,header.NRecords,'int32');
for i = 1:header.NRecords
%	ftell(fid)
	status = fseek(fid,RecordOffset(i),'bof');
%	ftell(fid)
	if (status < 0)
		error(ferror(fid));
	end
	record{i} = ReadCellRecord(fid,header.NCells);
end
status = fseek(fid,StatIndex,'bof');
if (status < 0)
	error(ferror(fid));
end
header.CellChan = fread(fid,header.NCells,'int16');
fclose(fid);
return

function record = ReadCellRecord(fid,nCells)
record.StartClock = fread(fid,1,'uint16');
record.EndClock = fread(fid,1,'uint16');
eventsInRecord = fread(fid,1,'int32');
spikesInRecord = fread(fid,1,'int32');
nSpikes = fread(fid,nCells,'int32');
record.evT = fread(fid,eventsInRecord,'int32');
record.evT = CorrectTimingWrap(record.evT);
record.evW = fread(fid,eventsInRecord,'int16')';
record.evP = fread(fid,eventsInRecord,'int16')';
for i = 1:nCells
	record.T{i} = fread(fid,nSpikes(i),'int32');
	record.T{i} = CorrectTimingWrap(record.T{i});
end
return

function corrT = CorrectTimingWrap(inT)
% The time values wrap around every 2^23 ticks,
% so this detects wrap-around and corrects for it
if (isempty(inT))
	corrT = inT;
	return;
end
if (size(inT,1) ~= 1)
	inT = inT';
end
if (size(inT,1) ~= 1)
	error('CorrectTimingWrap: input must be a vector');
end
Tp1 = [0 inT(1:length(inT)-1)];	% Right-shifted inT
Iwrap = find(Tp1 > inT);		% This now contains the indices at which wrap occurs
shift = zeros(size(inT));
for i = 1:length(Iwrap)
	shift(Iwrap(i):length(inT)) = shift(Iwrap(i):length(inT)) + 2^23;
end
corrT = shift + inT;
return
