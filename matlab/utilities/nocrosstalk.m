%Creates a crosstalk file with the right channel numbers but with
%no crosstalk channels selected
function nocrosstalk
[ctfile,ctpath] = uiputfile('noct.txt','Crosstalk file');
fid = fopen([ctpath,ctfile],'at');
[datafiles,datapath] = uigetfile('*','Pick raw data file');
tstart=0;tend=0.1;
[ldata,hdr] = loadmc([datapath,datafiles],[tstart,tend]);
chnums=hdr.channels(find(hdr.channels>=2));
ct=zeros(length(chnums),4);
ct=ct-1;
ct(:,1)=chnums';
fname = datafiles(1:findstr(datafile,'.bin')-1);
fprintf(fid,'%s {',fname);
fprintf(fid,'  %d %d %d %d',ct');
fprintf(fid,'}\n');
fclose(fid);
