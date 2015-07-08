function SetSpikeThresholds(filtflag)
% Interactive way of setting the thresholds for
% spike detection spike-detection filter

% First load the filter file
[filterfile,filterpath] = uigetfile('*.flt','Pick filter file');
if (filterfile == 0)
	error('Interrupted by user');
end
[f,w,sv,sniprange] = ReadFilters([filterpath,filterfile]);
keyboard
fd = f(:,1);

defname = strcat(filterfile,'.thresh');
[threshfile,threshpath] = uiputfile(defname,'Append thresholds to file');
fid = fopen([threshpath,threshfile],'at');

cancel = 0;
while (cancel ~= 1)
	[datafile,datapath] = uigetfile('*.bin','Pick raw data file');
	if (datafile == 0)	% User hit cancel
		fclose(fid);
		return;
	end
	clear dtemp
	[dtemp,htemp] = loadmc([datapath,datafile],[0,5]);
	prompt = {'Select active channels:'};
	def = {'4:63'};
	answer = inputdlg(prompt,'Channel data',1,def);
	if isempty(answer)	% User hit cancel
		fclose(fid);
		return;
	end
	activechan = str2num(answer{1});
	[intrsct,irec,isel] = intersect(htemp.channels,activechan);
	% Filter the data
	disp('Filtering the data...');
	for i = 1:length(activechan)
		dtemp(irec(i),:) = filtSig(dtemp(irec(i),:),fd,-sniprange(2));
	end
	% Set the thresholds
	thresh = SetThresholds(dtemp(irec,:));
	keyboard
	% Write the thresholds to file
	fname = datafile(1:findstr(datafile,'.bin')-1);
	fprintf(fid,'%s {',fname);
	%size(htemp.channels(irec))
	%size(thresh)
	fprintf(fid,'  %d %f',[htemp.channels(irec)';thresh]);
	fprintf(fid,'}\n');
end
