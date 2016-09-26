function npb = HistSplit(t,tsplit)
% HistSplit: histogram, given the bin boundaries
% npb = HistSplit(t,tsplit)
% tsplit contains the bin boundaries, and t contains the data
nsplitm1 = length(tsplit) - 1;
[ts,ii] = sort([t,tsplit]);
indx = find(ii > length(t));
cnpb = indx(end-nsplitm1:end) - (0:nsplitm1);
npb = diff([1,cnpb,length(t)+1]);
