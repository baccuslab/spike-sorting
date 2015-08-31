function autosetthresh
% Interactive way of setting the thresholds for
% spike detection spike-detection filter
answer = inputdlg({'Enter multiplier for threshold'},'',1,{'4'});
threshfact=str2num(answer{1});
[threshfile,threshpath] = uiputfile('.thresh','Append thresholds to file');
fid = fopen([threshpath,threshfile],'at');
cancel = 0;
while (cancel ~= 1)
	[datafiles,datapath] = uigetfile('*','Pick raw data file');
	if (datafiles == 0)	% User hit cancel
		fclose(fid);
		return;
	end
	clear dtemp
	[header,headersize] = ReadFileType(datafiles);
	if (header.type==1)
		[htemp,headersize] = ReadAIHeader(datafiles);
		[dtemp,htemp] = loadmc([datapath,datafiles],[1,6]);
		prompt = {'Select active channels (default is all >= 2):'};
		def = {num2str(htemp.channels(find(htemp.channels>=2)))};
		answer = inputdlg(prompt,'Channel data',1,def);
		if isempty(answer)	% User hit cancel
			fclose(fid);
			return;
		end
		activechan = str2num(answer{1});
	end
	if(header.type==2)
		[htemp,headersize] = ReadAIBHeader(datafiles);
		prompt = {'Select active channels (default is all >= 2):'};
		def = {num2str(htemp.channels(find(htemp.channels>=2)))};
		answer = inputdlg(prompt,'Channel data',1,def);
		if isempty(answer)	% User hit cancel
			fclose(fid);
			return;
		end
		dtempcell= loadaibdata({datafiles},htemp.channels,{htemp.scanrate},[0 htemp.scanrate*5-1]);
		activechan = str2num(answer{1});
		dtemp=cat(2,dtempcell{:})';
	end
	[intrsct,irec,isel] = intersect(htemp.channels,activechan);
	disp('Calculating thresholds...');
	% Set the thresholds
	thresh(1:length(irec))=threshfact*median(abs(dtemp(irec,:))')';
	if(header.type==2)
		%Keep thresholds in A/D units
		thresh=thresh/htemp.scalemult;
	end
	% Write the thresholds to file
	fname = datafiles(1:findstr(datafile,'.bin')-1);
	fprintf(fid,'%s {',fname);
	%size(htemp.channels(irec))
	%size(thresh)
	fprintf(fid,'  %d %f',[htemp.channels(irec);thresh]);
	fprintf(fid,'}\n');
end
