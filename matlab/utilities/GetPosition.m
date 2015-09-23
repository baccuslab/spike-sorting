function pos = GetPosition(ch, array_type, num_channels, x_configuration, y_configuration)
%function pos = GetPosition(ch, array_type, num_channels, x_configuration, y_configuration)
% Returns the x,y positions for plotting the channel projections.
% Inputs:
%   ch                  channels you want the x,y positions from
%   array_type          string; one of 'low-density', 'hexagonal', 'hidens'
%   num_channels        number of total channels recorded
%   x_configuration     for the hidens array, pass in optional configuration.x
%   y_configuration     for the hidens array, pass in optional configuration.y
%
% Written 2015-09-22 by Lane McIntosh by piecing together old GetPosition 
%   and GetPositionHex functions
%

if nargin < 4
    x_configuration = [];
    y_configuration = [];
end

if nargin < 3
    num_channels = -1;
end

if strcmp(array_type, 'low-density')
    % hard coded channel positions for low density MCS array
    poslistx=1/11*[[0 0 10 10] 1.5+[3 3 3 3 2 2 1 2 1 0 1 0 2 1 0 0 1 2 0 1 0 1 2 1 2 2 3 3 3 3 4 4 4 4 5 5 6 5 6 7 6 7 5 6 7 7 6 5 7 6 7 6 5 6 5 5 4 4 4 4]];
    poslisty=0.125*[7 6 7 6 1 0 2 3 0 1 0 2 1 1 2 2 3 3 3 4 4 4 5 5 6 6 5 7 6 7 4 5 7 6 6 7 5 4 7 6 7 5 6 6 5 5 4 4 4 3 3 3 2 2 1 1 2 0 1 0 3 2 0 1];
    pos=[poslistx(ch+1);poslisty(ch+1)]';

elseif strcmp(array_type, 'hexagonal')
    % hard coded channel positions for hexagonal MCS array
    poslistx=[9 9 1.5 5.5 7.5 6 6.5 7 7 6 5.5 5 5 4.5 4.5 4 4 3.5 3 2.5 3 3.5 2 2.5 6.5 4 1.5 3 2 1 1.5 2.5 ...
		3.5 2 3 4.5 2.5 4 3.5 3 5 4 4.5 5 5 5.5 5.5 6 6 6.5 7 7.5 7 6.5 8 7.5 8 6 8.5 7 8 9 8.5 7.5];
    poslistx=(10-poslistx)/9-0.11;
    poslisty=[9 8 9 6 8 7 8 9 7 9 8 7 9 8 6 9 7 8 9 8 7 6 7 6 6 5 6 5 5 5 4 4 ...
            4 3 3 4 2 3 2 1 5 1 2 3 1 2 4 1 3 2 1 2 3 4 3 4 7 5 4 5 5 5 6 6];
    poslisty=(poslisty)/9-0.11;
    pos=[poslistx(ch+1);poslisty(ch+1)]';

elseif strcmp(array_type, 'hidens')
    % Print message if x_configuration or y_configuration is empty
    if or(isempty(x_configuration), isempty(y_configuration))
        err = 'No hidens array x and y configuration loaded!'
    end
    % want poslistx and poslisty to be between 0 and 1
    poslistx = x_configuration/max(x_configuration);
    poslisty = y_configuration/max(y_configuration);
    pos = [poslistx(ch), poslisty(ch)];

else
    % if not one of the above array types, just plot the channels in numerical order
    % Print message if num_channels is unspecified
    if num_channels == -1
        err = 'Number of channels is not specified!'
    end
    width = sqrt(num_channels);
    poslistx = floor(ch / width);
    poslisty = mod(ch, width);
    % want poslistx and postlisty to be between 0 and 1
    poslistx = postlistx/max(postlistx);
    poslisty = postlisty/max(postlisty);
    pos = [poslistx(ch); poslisty(ch)]';

end


