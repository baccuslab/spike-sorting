function [record,header] = ReadSpikeFileSel(filename,Chanlist,nrecs)
% [record,header] = ReadSpikeFile(filename,Chanlist,nrecs)
%
% Read the file output of Record64.
% If (optional) nrecs is supplied, only nrecs records are read. Otherwise, all are read.
% Corrects timing wrap within and between records.
% --by xaq, 28.03.01, tested only Format1
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header.format = fread(fid,1,'int32');
if (header.format >= 256)
	FPosIndex = header.format;
	header.format = 1;
elseif (header.format ~= 2)
	error('Don''t recognize format');
end

if (header.format ==1)	% begin reading format 1
	
	header.Text = fread(fid,256,'char');
	header.RecordingTime = fread(fid,1,'uint32');
	header.LengthClock = fread(fid,1,'int32');
						fread(fid,2,'uint16'); % unsigned (?), not used
	header.NumberChannels = fread(fid,1,'int16');
	header.Channel = fread(fid,64,'int16');
	header.Threshold = fread(fid,64,'int16');
	
	status = fseek(fid,FPosIndex,'bof');
	if (status < 0)
		error(ferror(fid));
	end
	header.NRecords = fread(fid,1,'int16');
	if (nargin == 3)
		header.NRecords = nrecs;
	end
	FPos = fread(fid, header.NRecords+1,'int32');	% FPos(1) points to parameters,
												% FPos(2:NRecords+1) points to records.
	keyboard
	for i = 1:header.NRecords
		status = fseek(fid,FPos(i+1),'bof');	% FPos(i+1) points to i'th record. 
		if (status < 0)
			error(ferror(fid));
		end
		record{i} = ReadRecordFormat1(fid,header.NumberChannels,Chanlist);
	end

	% end of reading Format 1

else	% begin reading Format 2
	ParIndex = fread(fid,1,'int32');
	FPosIndex = fread(fid,1,'int32');
	RecIndex = fread(fid,1,'int32');
	
	status = fseek(fid,ParIndex,'bof');
	if (status < 0)
		error(ferror(fid));
	end
	header.Text = fread(fid,256,'char');
	header.SamplingPeriod = fread(fid,1,'float32');
	header.StimulusInterval = fread(fid,1,'float32');
	header.RecordLength = fread(fid,1,'float32');
	header.NumberChannels = fread(fid,1,'int16');
	header.Channel = fread(fid,64,'int16');
	header.Threshold = fread(fid,64,'int16');
	header.Hysteresis = fread(fid,1,'int16');

	status = fseek(fid,FPosIndex,'bof');
	if (status < 0)
		error(ferror(fid));
	end
	header.NRecords = fread(fid,1,'int16');
	if (nargin == 2)
		header.NRecords = nrecs;
	end
	header.FPos = fread(fid,NRecords,'int32');
	status = fseek(fid,RecIndex,'bof');	% read records
	if (status < 0)
		error(ferror(fid));
	end
	for i = 1:header.NRecords
		status = fseek(fid,header.FPos(i),'bof');
		if (status < 0)
			error(ferror(fid));
		end
		record{i} = ReadRecordFormat2(fid,header.NumberChannels);
	end

end	% end of reading Format 2

record = CorrectTimingWrapBetweenRecords(record);	% xaq

fclose(fid);

return


%% AUXILIARY FUNCTIONS %%--------------------------------


function record = ReadRecordFormat1(fid,nChannels,Chanlist)
record.StartClock = fread(fid,1,'uint16');	% unsigned. uint16 or uint32?
record.EndClock = fread(fid,1,'uint16');
record.TotalNSpikes = fread(fid,1,'int32');
record.NSpikes = fread(fid,63,'int32');	% note 63 instead of 64
nSelChan=size(Chanlist,2);
for i = 1:nSelChan		
	record.T{i} = fread(fid, record.NSpikes(i), 'int32'); % spike times
	record.T{i} = CorrectTimingWrapInRecord(record.T{i});
end
for i = 1:nSelChan
	record.W{i} = fread(fid, record.NSpikes(i), 'int16'); % widths
	record.W{i} = record.W{i}';
end
for i = 1:nSelChan
	record.P{i} = fread(fid, record.NSpikes(i), 'int16'); % peaks
	record.P{i} = record.P{i}';
end
return


function record = ReadRecordFormat2(fid,nChannels)
record.RecordingTime = fread(fid,1,'int32');
record.StartClock = fread(fid,1,'uint32');
record.EndClock = fread(fid,1,'uint32');
record.TotalNSpikes = fread(fid,1,'int32');
record.NSpikes = fread(fid,64,'int32');
for i = 1:nChannels
	record.T{i} = fread(fid, record.NSpikes(i), 'uint32'); % spike times
	record.T{i} = CorrectTimingWrapInRecord(record.T{i});

	record.W{i} = fread(fid, record.NSpikes(i), 'int16'); % widths
	record.W{i} = record.W{i}';
	record.P{i} = fread(fid, record.NSpikes(i), 'int16'); % peaks
	record.P{i} = record.P{i}';
end
return

function corrT = CorrectTimingWrapInRecord(inT)
% The time values wrap around every 2^23 ticks,
% so this detects wrap-around within a given record and corrects for it
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

function corrRecs = CorrectTimingWrapBetweenRecords(recs) %xaq
% The time values wrap around every 2^23 ticks,
% so this detects wrap-around between given records and corrects for it.
% This also corrects StartClock and EndClock wrap-around.
corrRecs = recs;
if (size(recs) <2)
	return;
end
nwraps = 0;
for i=1:length(recs)-1 % correct for Event and Spike Timing wrap-around
	if (recs{i+1}.T{1}(1) < recs{i}.T{1}(1))
		nwraps = nwraps + 1;
	end
	corrRecs{i+1} = recs{i+1};
	for c=1:length(recs{1}.T)
		corrRecs{i+1}.T{c} = recs{i+1}.T{c} + nwraps * 2^23;
	end
end

nwraps = 0; % now correct for Clock wrap-around
if (recs{1}.EndClock < recs{1}.StartClock)
	corrRecs{1}.EndClock = recs{1}.EndClock + 2^16; % clock wrap is 2^23 / 128 = 2^16
	nwraps = nwraps + 1;
end
for i=2:length(recs)
	if (corrRecs{i}.StartClock + nwraps*2^16 < corrRecs{i-1}.EndClock)
		nwraps = nwraps + 1;
	end
	corrRecs{i}.StartClock = corrRecs{i}.StartClock + nwraps * 2^16; % clock wrap is 2^23 / 128 = 2^16
	if (recs{i}.EndClock < recs{i}.StartClock)
		nwraps = nwraps + 1;
	end
	corrRecs{i}.EndClock = corrRecs{i}.EndClock + nwraps * 2^16; % clock wrap is 2^23 / 128 = 2^16
end

return
