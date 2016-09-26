function WriteRecChan(filesin,fileout)
% WriteRecChan: determine the recorded channels for
% a set of files and write the "allfiles.txt" file
% WriteRecChan(filesin,fileout),
%   where filesin is a cell array containing all files (see dirtime),
%   fileout is the output filename
[fid,message] = fopen(fileout,'wt');
if (fid < 0)
	error(message);
end
for i = 1:length(filesin)
	h = ReadAIHeader(filesin{i});
	chanstr = [sprintf('%d,',h.channels(1:end-1)),num2str(h.channels(end))];
	filepref = strtok(filesin{i},'.');
	fprintf(fid,'%s {%s}\n',filepref,chanstr);
end
fclose(fid);
	
