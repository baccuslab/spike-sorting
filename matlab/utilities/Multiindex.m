function [multitimes,multiindx]= Multiindex (hmain,g,sortchannels,mchidx);
nfiles=1
%Load in spike times
sptimes=cell(1); sptimes{1}=cell(1,nfiles);
for fnum=1:nfiles;
	[snips,sptimes{1}{fnum}]=loadSnip(g.snipfile,'spike',sortchannels(1));
	sptimes{1}{fnum}=[sptimes{1}{fnum}';1:length(sptimes{1}{fnum})];
end

sptimes=removetimes (sptimes,g.chanclust(mchidx(1)),g.removedCT(mchidx(1),:),1);
for fnum=1:nfiles;
	if (~isempty(sptimes{1}{fnum}))
		multitimes{fnum}=sptimes{1}{fnum}(1,:);
		multiindx{fnum}=sptimes{1}{fnum}(2,:);
	else
		multitimes{fnum}=[];
		multiindx{fnum}=[];
	end
end
