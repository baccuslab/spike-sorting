function findcrosstalk
[ctfile,ctpath] = uiputfile('ct.txt','Crosstalk file');
fid = fopen([ctpath,ctfile],'at');
cancel = 0;
while (cancel ~= 1)
	[datafile,datapath] = uigetfile('*','Pick raw data file');
	if (datafile == 0)	% User hit cancel
		fclose(fid);
		return;
	end
	
	%Load data for thresholds
	%ldata:loaded data (unaltered)
	%tstart,tend: time bounds in seconds from file
	%ach:array channels
	clear ldata
	tstart=1;tend=3;
	[ldata,hdr] = loadmc([datapath,datafile],[tstart,tend]);
	ach=find(hdr.channels>=3);
	
	% Set the thresholds
	%nch:# of array channels
	%thresh:thresholds
	%d1:recording starting at point 1
	%d2:recording starting at point2
	%tc:threshold crossings
	disp('Calculating thresholds...');
	nch=length(ach);
	thresh(1:nch)=4.5*median(abs(ldata(ach,:))')';
	
	%Load data for threshold crossings and crosstalk
	clear ldata
	tstart=1;tend=8;
	[ldata,hdr] = loadmc([datapath,datafile],[tstart,tend]);
	ach=find(hdr.channels>=3);
	
	d1=ldata(ach,1:end -1); 
	d2=ldata(ach,2:end );
	tc=cell(1,nch); 
	%Find threshold crossings:
	%subtract threshold from data
	%crossings occur when data(p)*data(p+1)<=0
	for ch=1:nch
		d1(ch,:)=d1(ch,:)-thresh(ch);
		d2(ch,:)=d2(ch,:)-thresh(ch);
		dthresh(ch,:)=d1(ch,:).*d2(ch,:);
		tc{ch}=find(dthresh(ch,:)<=0);	
	end
	sptimes=cell(1,nch);
	for ch=1:nch
		%If 1st thresh crossing is negative (if 1st data point > thresh), skip it
		if (d1(ch,1)>thresh(ch)) skip=1; else skip=0; end
		for sp=1:(size(tc{ch},2)/2-1)
			spb=tc{ch}(sp*2-1+skip); % spike beginning
			spe=tc{ch}(sp*2+skip); % spike end
			%find peak of spike  (min fn necessary in case of >1 pt at max)
			sptimes{ch}(sp)=min(find(ldata(ach(ch),spb:spe)==max(ldata(ach(ch),spb:spe))))+spb-1;
		end
	end
	%Compute spike triggered averages
	sta=cell(1,nch);
	stasize=50;
	amp=cell(1,nch);
	ct=zeros(nch,4);
	ct=ct-1;
	ct(:,1)=hdr.channels(ach(1:nch)')';
	for ch=1:nch
		sta{ch}=zeros(nch,2*stasize+1);
		% avoid the ends of the data 
		sptimes{ch}=sptimes{ch}(find(sptimes{ch}>stasize & sptimes{ch}<(size(ldata,2)-stasize)));
		for sp=1:size(sptimes{ch},2)
			sta{ch}=sta{ch}+(ldata(ach,(sptimes{ch}(sp)-stasize):(sptimes{ch}(sp)+stasize)));
		end
		if (sp>0)
			sta{ch}=sta{ch}/sp; %divide by n of spikes
			%Find STAs with largest amplitude
			amp{ch}=[max(sta{ch}(:,stasize-3:stasize+6)')-min(sta{ch}(:,stasize-3:stasize+6)');...
				thresh;1:nch];
			%amp{ch}=sortrows(amp{ch}')';
			%significance threshold for crosstalk
			ctidx=find((amp{ch}(1,:)./amp{ch}(2,:))>0.5 & amp{ch}(3,:)~=ch);
			if length(ctidx)>0
				ctidx=ctidx(max(1,size(ctidx,2)-2):size(ctidx,2));
				ct(ch,2:size(ctidx,2)+1)=hdr.channels(ach(amp{ch}(3,ctidx)));
			end
		end
	end
	% Write the crosstalk channels to file
	%Add event pulse channel, which doesn't have crosstalk
	if (size(find(hdr.channels==2),2)>0)
		ct=[2 -1 -1 -1;ct];
	end
	fname = datafile(1:findstr(datafile,'.bin')-1);
	fprintf(fid,'%s {',fname);
	%size(hdr.channels(ach))
	%size(thresh)
	fprintf(fid,'  %d %d %d %d',ct');
	fprintf(fid,'}\n');
end
