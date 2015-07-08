function WriteVlv(fileout,stimfiles,stim)
% WriteVlv: write the time course of the stimulus in the format of CalcStim
% WriteVlv(outfilename,files,stim)
% where
%	outfilename is the base name for output
%	files is a cell array of filenames
%	stim is a cell array of 2-by-n matrices, containing the
%		valve number and scan number of each transition
% Writes both .sat and .vlv files
[fid,message] = fopen([fileout,'.vlv'],'wt');
if (fid < 0)
	error(message);
end
for i = 1:length(stimfiles)
	fprintf(fid,'%s {',stimfiles{i});
	fprintf(fid,'  %d %d',[stim{i}(1,:);stim{i}(2,:)]);
	fprintf(fid,'}\n');
end
fclose(fid);
[fid,message] = fopen([fileout,'.sat'],'wt');
if (fid < 0)
	error(message);
end
for i = 1:length(stimfiles)
	fprintf(fid,'%s {',stimfiles{i});
	t = stim{i}(2,:);
	killi = find(t(1:end-1)+600 > t(2:end));
	t(killi) = [];
	fprintf(fid,'  %d %d',[t(1:end-1)+600;t(2:end)]);
	fprintf(fid,'}\n');
end
fclose(fid);
