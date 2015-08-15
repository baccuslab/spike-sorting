function chname = num2name(chnum)
% chname = num2name(chnum)
% Converts channel numbers to channel names
chname = reshape(char([floor(chnum/8)+'A';mod(chnum,8)+'1']),size(chnum,1),2*size(chnum,2));
