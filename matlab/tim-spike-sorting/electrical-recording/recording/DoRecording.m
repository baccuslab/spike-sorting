function DoRecording(recparams)
% DoRecording(recparams,blocksize)
% recparams: a structure with fields
%	channels (vector)
%	scanrate (scalar, estimate---actual value will be set by hardware,
%	    usually within 0.1% of input value)
%	nscans (scalar)
%	buffersize (scalar, estimate---actual value will be computed to make graphing easy)
%    trigger (scalar): 0 = trigger is put out on PFI0, 1 = acquisition waits for trigger on trigger1/PFI0
%    gain: valid choices are -1 (for 0.5), 1, 2, 5, 10, 20, 50, 100 (a scalar)
%    usrheader (optional string, used only if saving)
%	filename (string, do not create this if you don't wish to save)
global gRecParams gAxH gTextH1 gTextH2 gIsRecording gNPix
windY = 2048*[-ones(64,1),ones(64,1)];
%windY(1,:) = 2048*[-0.2 1.1]/5;
[gAxH,gNPix,gTextH1,gTextH2] = CreateRecordingWindow(windY);
recparams.buffersize = ceil(recparams.buffersize/gNPix)*gNPix;
gRecParams = recparams;
gIsRecording = 0;
