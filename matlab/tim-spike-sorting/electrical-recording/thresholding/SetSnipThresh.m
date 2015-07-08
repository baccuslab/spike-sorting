function SetSnipThresholds(filtflag)
% Interactive way of setting the thresholds for
% cutting snippets

defname ='.thresh';
[threshfile,threshpath] = uiputfile(defname,'Append thresholds to file');
if (threshfile == 0)
	'Cancel'
	return
end
[fid,message] = fopen([threshpath,threshfile],'at');
if (fid < 1)
	error(message);
end

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
	def = {'3:63'};
	answer = inputdlg(prompt,'Channel data',1,def);
	if isempty(answer)	% User hit cancel
		fclose(fid);
		return;
	end
	activechan = str2num(answer{1});
	[intrsct,irec,isel] = intersect(htemp.channels,activechan);
	% Set the thresholds
	thresh = SetThresholds(dtemp(irec,:));
	% Write the thresholds to file
	fname = datafile(1:findstr(datafile,'.bin')-1);
	fprintf(fid,'%s {',fname);
	fprintf(fid,'  %d %f',[htemp.channels(irec);thresh]);
	fprintf(fid,'}\n');
end
