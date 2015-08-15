function [data,header] = loadlist(fid,header,chlist,tmax)
% [data,header] = load64(filename,timerange)
% load 64-channel binary data from LabView.
% timerange is an optional 2-vector, indicating
% the range [,) to load in (in seconds),
% with 0 being the first point in the file.
% If timerange is absent, the whole file is loaded.

% End of header
data=[];
alldata=[0 0];
t=1;
while ((size(alldata,2)>0) & (t<=tmax))
	clear alldata;
	alldata = ReadBinaryData(fid,header.numch,round([0,1]*header.scanrate));
	if size(alldata,2) > 0
    	for chn=1:size(chlist,2)
			chnum=index(header.channels',chlist(chn));
			if chnum>0
				newdata(chn,:)=alldata(chnum,:);
			end
     	end
		data=[data newdata];
		clear newdata;    
	end
t=t+1;
end
% Convert to microvolts
for i = 1:size(chlist,2)
%	data(i,:) = (data(i,:)*header.scalemult + header.scaleoff)/0.0147;
end

function idx = index(arr,element)
idx=0;
for i=1:size(arr,2)
	if arr(i)==element
		idx=i;
	end
end
return 
