function RecParamCallback(action)
% RecParamCallback(action)
% Switchyard for Recording Parameters window (see function Record)
% action = 'savemode', 'CancelButton', or 'OKButton'
% (disabled: action = 'savebutton', 'dontsavebutton')
global gRecParams gAxH gTextH1 gTextH2 gIsRecording gNPix
switch(action)
% These first two are outdated, and will not be called
case 'savebutton'
	set(gcbo,'Value',1);
	set(findobj(gcbf,'Tag','dontsave'),'Value',0);
	set(findobj(gcbf,'Tag','usrheaderTxt'),'Enable','on');
	set(findobj(gcbf,'Tag','usrheader'),'Enable','on');
	set(findobj(gcbf,'Tag','basenameTxt'),'Enable','on');
	set(findobj(gcbf,'Tag','basename'),'Enable','on');
case 'dontsavebutton'
	set(gcbo,'Value',1);
	set(findobj(gcbf,'Tag','save'),'Value',0);
	set(findobj(gcbf,'Tag','usrheaderTxt'),'Enable','off');
	set(findobj(gcbf,'Tag','usrheader'),'Enable','off');
	set(findobj(gcbf,'Tag','basenameTxt'),'Enable','off');
	set(findobj(gcbf,'Tag','basename'),'Enable','off');
case 'savemode'
	value = get(gcbo,'Value');
	switch(value)
	case 1		% Don't save
		set(findobj(gcbf,'Tag','usrheaderTxt'),'Enable','off');
		set(findobj(gcbf,'Tag','usrheader'),'Enable','off');
		set(findobj(gcbf,'Tag','basenameTxt'),'Enable','off');
		set(findobj(gcbf,'Tag','basename'),'Enable','off');
	case 2		% Save
		set(findobj(gcbf,'Tag','usrheaderTxt'),'Enable','on');
		set(findobj(gcbf,'Tag','usrheader'),'Enable','on');
		set(findobj(gcbf,'Tag','basenameTxt'),'Enable','on');
		set(findobj(gcbf,'Tag','basename'),'Enable','on');
	end
case 'CancelButton'
	delete(gcbf)
case 'OKButton'
	gRecParams.channels = str2num(get(findobj(gcbf,'Tag','ChannelString'),'String'));
	gRecParams.scanrate = str2num(get(findobj(gcbf,'Tag','ScanRate'),'String'));
	rectime = str2num(get(findobj(gcbf,'Tag','RecordingTime'),'String'));
	gRecParams.nscans = rectime*gRecParams.scanrate;
	buffersize = str2num(get(findobj(gcbf,'Tag','BufferSize'),'String'));
	gRecParams.trigger = 2 - get(findobj(gcbf,'Tag','Trigger'),'Value');
	gainv = [0.5 1 2 5 10 20 50 100];
	gainvi = [-1 1 2 5 10 20 50 100];
	gRecParams.gain = gainvi(get(findobj(gcbf,'Tag','RecordingGain'),'Value'));
	gain = gRecParams.gain;
	if (gain < 0)
		gain = 0.5;
	end
	plotg = gainv(get(findobj(gcbf,'Tag','PlottingGain'),'Value'));
	magY = plotg/gain;
	savestatus = get(findobj(gcbf,'Tag','SaveMode'),'Value');
	if (savestatus > 1)
		if (gRecParams.nscans*length(gRecParams.channels) > 2^30)
			error('File length is larger than allowed by operating system. Choose a shorter recording time.');
		end
%		gRecParams.usrheader = get(findobj(gcbf,'Tag','usrheader'),'String')';
		temphdr = get(findobj(gcbf,'Tag','usrheader'),'String')';
		ct = cellstr(temphdr');		% Pad header with returns at end of lines
		ret = double(sprintf('\n'));
		ctcat = strcat(ct,num2cell(char(ret*ones(length(ct),1))));
		gRecParams.usrheader = cat(2,ctcat{:})';	% Turn into a single column string
		[fname,pathname] = uiputfile('*.bin','Save data to file:');
		if (fname == 0)
			disp('Operation cancelled');
			return
		end
		gRecParams.filename = [pathname,fname];
	else
		if isfield(gRecParams,'filename')
			gRecParams = rmfield(gRecParams,'filename');
		end
	end
	windY = 2048*[-ones(64,1),ones(64,1)]/magY;
	windY(1,:) = 2048*([-0.2,1.2]/5)*gain;	% chan0 always from -0.2V to 1.2V
	windY(2,:) = 2048*([2,4]/5)*gain;		% chan1 always from 2V to 4V
	rwh = findobj(0,'Tag','RecWindow');
	if (isempty(rwh) ~= 1)
		delete(rwh);		% Only 1 recording window at a time
	end
	[gAxH,gNPix,gTextH1,gTextH2] = CreateRecordingWindow(windY);
	gRecParams.buffersize = ceil(buffersize/gNPix)*gNPix;
	gIsRecording = 0;
end
