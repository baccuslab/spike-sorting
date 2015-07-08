function [envmm,header] = loadenv(filename,n,time)
% [envmm,header] = loadenv(filename,n,timerange)
% Loads waveform data but stores only the envelope
% See loadFromEnv to load a .env file
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
% End of header
ShowAIHeader(header)
if (nargin == 3)
	range = round(time*header.scanrate);
else
	range = [0,header.nscans-1];
end
envmm = envelope(fid,n,header.numch,range)
fclose(fid);
for i = 1:header.numch
	envmm.min(i,:) = envmm.min(i,:)*header.scalemult + header.scaleoff;
	envmm.max(i,:) = envmm.max(i,:)*header.scalemult + header.scaleoff;
end
