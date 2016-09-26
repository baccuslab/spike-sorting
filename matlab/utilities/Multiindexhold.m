function [multitimes,multiindx]= Multiindex (hmain,g,sortchannels,mchidx,cttime);
nfiles=size(g.spikefiles,2);
%Load in spike times
for ch=1:size(mchidx,2)
	for fnum=1:nfiles;
		[sptimes{ch}{fnum},hdr]=LoadSnipTimes(g.spikefiles{fnum},sortchannels(ch));
		sptimes{ch}{fnum}=[sptimes{ch}{fnum}';1:length(sptimes{ch}{fnum})];
	end
end
sptimes=removetimes (sptimes,g.chanclust(mchidx),g.removedCT(mchidx,:),1:size(mchidx,2));
for fnum=1:nfiles;
	mtimesidx=sptimes{1}{fnum};
	mtimesidx=[mtimesidx;zeros(size(mchidx,2)-1,size(mtimesidx,2))];
	for ch=2:length(mchidx)
		%Find coincident spikes for the next channel
		[delay,ctspikenums]=crosscorr(mtimesidx(1,:),sptimes{ch}{fnum}(1,:),cttime);
		
		%Coincidences of prev. channels with next channel
		ctnext=mtimesidx(1,ctspikenums(1,:));				%coincident times
		ctnext=[ctnext;mtimesidx(2:end,ctspikenums(1,:))]; 		%coincident spike#s of prev. channels
		if (size(ctspikenums,2)>0)	
			ctnext(ch+1,:)=sptimes{ch}{fnum}(2,ctspikenums(2,:));	%coincident spike#s of next channel
		end
		[placeholder,uniqidx]=unique(ctnext(1,:));
		ctnext=ctnext(:,uniqidx);
		%Non-coincident spikes from prev. channels
		noctprev=setdiff(1:size(mtimesidx,2),ctspikenums(1,:));
		tnoctprev=mtimesidx(:,noctprev);
		%Non-coincident spikes for the next channel
		%noctnext=setdiff(1:size(times{mchidx(ch)}{fnum},2),ctspikenums(2,:));	%Get non-coincident spike#s
		%tnoctnext=times{mchidx(ch)}{fnum}(1,noctnext);					%Non-coincident times
		%tnoctnext=[tnoctnext;zeros(size(mchidx,2),size(noctnext,2))];		%Zeros for other channels' spike#s
		%tnoctnext(ch+1,:)=times{mchidx(ch)}{fnum}(2,noctnext);				%Non-coincident spike#s
		
		%Assemble and sort times and spike nums
		%mtimesidx=sortrows([ctnext,tnoctprev,tnoctnext]',[1])'; 	
		mtimesidx=sortrows([ctnext,tnoctprev]',1)'; 	
	end
	%Separate times and spike#s into different variables
	multiindx{fnum}=mtimesidx(2:end,:);
	multitimes{fnum}=mtimesidx(1,:);
end

