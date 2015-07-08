function RecWindowCallback(action)
% RecWindowCallback(action)
% Switchyard for button presses in the Recording Window
% action = 'start' or 'stop'
global gRecParams gAxH gTextH1 gTextH2 gIsRecording gNPix
switch(action)
case 'start'
	% First, clear anything that might be in the axes
	rwh = findobj(0,'Tag','RecWindow');
	caxh = get(gAxH,'Children');
	caxh = cat(1,caxh{:});
	delete(caxh);
	gIsRecording = 1;
	set(gcbo,'Enable','off');	% disable Start button
	set(findobj(gcbf,'Tag','StopRecButton'),'Enable','on'); % enable Stop button
	set(gTextH1,'String',sprintf('Recording for %d seconds',round(gRecParams.nscans/gRecParams.scanrate)));
	set(gTextH2,'String','Recording...');
	if (isfield(gRecParams,'filename'))
		status = RecordingWork(gRecParams.channels,gRecParams.scanrate,gRecParams.nscans,gRecParams.buffersize,gRecParams.trigger,gRecParams.gain,gNPix,gAxH,gTextH2,gRecParams.usrheader,gRecParams.filename);
	else
		status = RecordingWork(gRecParams.channels,gRecParams.scanrate,gRecParams.nscans,gRecParams.buffersize,gRecParams.trigger,gRecParams.gain,gNPix,gAxH,gTextH2);
	end	
	% RecordingWork will check back and see if gIsRecording has been set to 0;
	% if so, it terminates early
	if (status == 0)
		set(gTextH2,'String','Done!');
	else
		set(gTextH2,'String','Aborted');
	end
	gIsRecording = 0;
	set(findobj(gcbf,'Tag','StopRecButton'),'Enable','off'); % disable Stop button
	if (~isfield(gRecParams,'filename'))
		set(gcbo,'Enable','on');		% re-enable Start button, if not saving to disk (would need new filename)
	end
	clear RecordingWork;		% A workaround for Nat. Inst. bug (?)
	sound(sin((1:1000)/4))
case 'stop'
	gIsRecording = 0;
	set(gcbo,'Enable','off');	% disable Stop button
otherwise
	disp('RecWindowCallback: do nothing');
end
