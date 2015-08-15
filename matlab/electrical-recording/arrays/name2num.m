function chnum = name2num(chname)
% chnum = name2num(chname)
% Converts channel names to channel numbers
chnum = (chname(:,1:2:size(chname,2))-'A')*8+(chname(:,2:2:size(chname,2))-'0') - 1;
