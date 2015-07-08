function newclust=selectspikes(chanclust,fnum,current,offset,lev1,lev2)
%This function accepts a list of spikes, and returns those spikes that occurred when 'current' is between lev1 and lev2
%chanclust: g.chanclust, a subfield of the variable "g" contained in the sorted spike .mat file from groupcw
%fnum:filenum
%current:array containing current trace from file fnum
%		 To get the current trace array, use the following command
%		 current=loadaibdata({'rawdatafilename'},1,{[0]},[0 length]);
%		     {usage is data=loadaibdata({'file1' 'file2' ... 'filen'},[ch1 ch2 ... chm],{[times1 times2 ... timesn]},[datastartoffset dataendoffset]) }
%		 where 'length' is the number of sample points in the recording
%offset:accounts for expected latency between current onset (or offset) and effect of current pulse
%lev1:min of current range
%lev2:max of current range
numch=size(chanclust,2);
	newclust=chanclust;
	for ch=1:numch
		numcells=size(chanclust{ch},1);
		for c=1:numcells
			spikes=chanclust{ch}{c,fnum};
			newclust{ch}{c,fnum}=spikes(find(and(current(floor(spikes-offset))>lev1,current(floor(spikes-offset))<lev2)));
		end
	end
	
