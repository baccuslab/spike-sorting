function WriteAnalogOutput (aoutdata,scanrate,filename)
%WriteAnalogOutput (aoutdata,scanrate,filename)
%Writes analog output file to be used by
%recording program Record64CW.
%aoutdata is in picoamps

%Convert to picoamps
aoutdata=aoutdata*(2048/1000);

%Create header
h.type = 1;
h.version = 3;
h.nscans = size (aoutdata,2);
h.numch = 1;
h.channels = 0;
h.scanrate = scanrate;
h.scalemult = 1;
h.scaleoff = 0;
h.date = date;
h.time = '00:00:00 AM';
h.usrhdr = 'Feature Not Yet Supported';

%Write header and analog data
[fid,message] = fopen(filename,'w');
WriteAIHeader (fid,h);
count = fwrite(fid,aoutdata,'int16');
if (count < size(aoutdata,2))
	error(ferror(fid));
end
fclose (fid);
