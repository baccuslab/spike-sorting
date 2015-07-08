function theAxis = vertsubplot(nrows, ncols, thisPlot)
%VERTSUBPLOT Create axes in tiled positions.
% Identical with SUBPLOT, except plots are arranged vertically
% (Also eliminated backward compatibility)
%   H = VERTSUBPLOT(m,n,p) breaks the Figure window
%   into an m-by-n matrix of small axes, selects the p-th axes for 
%   for the current plot, and returns the axis handle.  The axes 
%   are counted along the left column of the Figure window, then the
%   second column, etc.  For example,
% 
%       SUBPLOT(2,1,1), PLOT(income)
%       SUBPLOT(2,1,2), PLOT(outgo)
% 
%   plots income on the top half of the window and outgo on the
%   bottom half.
% 
%   SUBPLOT(m,n,p), if the axis already exists, makes it current.
%   SUBPLOT(H), where H is an axis handle, is another way of making
%   an axis current for subsequent plotting commands.
%
%   SUBPLOT('position',[left bottom width height]) creates an
%   axis at the specified position in normalized coordinates (in 
%   in the range from 0.0 to 1.0).
%
%   If a SUBPLOT specification causes a new axis to overlap an
%   existing axis, the existing axis is deleted.  For example,
%   the statement SUBPLOT(1,2,1) deletes all existing axes overlapping
%   the left side of the Figure window and creates a new axis on that
%   side.
%
%
% we will kill all overlapping axes siblings if we encounter the
% m,n,p specifier.
% But if we get the 'position' or H specifier, we won't check for and
% delete overlapping siblings:
narg = nargin;
kill_siblings = 0;
create_axis = 1;
delay_destroy = 0;
tol = sqrt(eps);
%check for encoded format
handle = '';
position = '';
if narg == 1
    % The argument is an axis handle
    code = nrows;

    % turn string into a number:
    if(isstr(code)) code = eval(code); end

    % number with a fractional part can only be an identifier:
    if(rem(code,1) > 0)
        handle = code;
        if ~strcmp(get(handle,'type'),'axes')
            error('Requires valid axes handle for input.')
        end
        create_axis = 0;
end
elseif narg == 2
    % The arguments MUST be the string 'position' and a 4-element vector:
    if(strcmp(lower(nrows), 'position'))
        pos_size = size(ncols);
        if(pos_size(1) * pos_size(2) == 4)
            position = ncols;
        else
            error(['subplot(''position'',',...
            ' [left bottom width height]) is what works'])
        end
    else
        error('Unknown command option')
    end
    kill_siblings = 1; % Kill overlaps here also.
elseif narg == 3
    % passed in subplot(m,n,p) -- we should kill overlaps
    % here too:
    kill_siblings = 1;
end

% if we recovered an identifier earlier, use it:
if(~isempty(handle))
    set(get(0,'CurrentFigure'),'CurrentAxes',handle);
% if we haven't recovered position yet, generate it from mnp info:
elseif(isempty(position))
    if (min(thisPlot) < 1)
        error('Illegal plot number.')
        elseif (max(thisPlot) > ncols*nrows)
                error('Index exceeds number of subplots.')
    else
        % This is the percent offset from the subplot grid of the plotbox.
        PERC_OFFSET_L = 2*0.09;
        PERC_OFFSET_R = 2*0.045;
        PERC_OFFSET_B = PERC_OFFSET_L;
        PERC_OFFSET_T = PERC_OFFSET_R;
        if nrows > 2
            PERC_OFFSET_T = 0.9*PERC_OFFSET_T;
            PERC_OFFSET_B = 0.9*PERC_OFFSET_B;
        end
        if ncols > 2
            PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
            PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
        end

        col = floor((thisPlot-1)/nrows);
        row = (nrows-1)-rem (thisPlot-1, nrows);

        % For this to work the default axes position must be in normalized coordinates
        if ~strcmp(get(gcf,'defaultaxesunits'),'normalized')
          warning('DefaultAxesUnits not normalized.')
          tmp = axes;
          set(axes,'units','normalized')
          def_pos = get(tmp,'position');
          delete(tmp)
        else
          def_pos = get(gcf,'DefaultAxesPosition');
        end
        col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...
                                (ncols-PERC_OFFSET_L-PERC_OFFSET_R);
        row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...
                                (nrows-PERC_OFFSET_B-PERC_OFFSET_T);
        totalwidth = def_pos(3) + col_offset;
        totalheight = def_pos(4) + row_offset;
        width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;
        height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;
        position = [def_pos(1)+min(col)*totalwidth/ncols ...
                    def_pos(2)+min(row)*totalheight/nrows ...
                    width height];
        if width <= 0.5*totalwidth/ncols
            position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);
            position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);
        end
        if height <= 0.5*totalheight/nrows
            position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);
            position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);
        end
    end
end

% kill overlapping siblings if mnp specifier was used:
nextstate = get(gcf,'nextplot');
if strncmp(nextstate,'replace',7), nextstate = 'add'; end
if(kill_siblings)
    if delay_destroy
      if nargout
        error('Function called with too many output arguments')
      else
        set(gcf,'NextPlot','replace'); return,
      end
    end
    sibs = get(gcf, 'Children');
    got_one = 0;
    for i = 1:length(sibs)
        % Be aware that handles in this list might be destroyed before
        % we get to them, because of other objects' DeleteFcn callbacks...
        if(ishandle(sibs(i)) & strcmp(get(sibs(i),'Type'),'axes'))
            units = get(sibs(i),'Units');
            set(sibs(i),'Units','normalized')
            sibpos = get(sibs(i),'Position');
            set(sibs(i),'Units',units);
            intersect = 1;
            if(     (position(1) >= sibpos(1) + sibpos(3)-tol) | ...
                        (sibpos(1) >= position(1) + position(3)-tol) | ...
                        (position(2) >= sibpos(2) + sibpos(4)-tol) | ...
                        (sibpos(2) >= position(2) + position(4)-tol))
                         intersect = 0;
            end
            if intersect
                if got_one | any(abs(sibpos - position) > tol)
                    delete(sibs(i));
                else
                    got_one = 1;
                    set(gcf,'CurrentAxes',sibs(i));
                    if strcmp(nextstate,'new')
                        create_axis = 1;
                    else
                        create_axis = 0;
                    end
                end
            end
        end
    end
    set(gcf,'NextPlot',nextstate);
end

% create the axis:
if create_axis
    if strcmp(nextstate,'new'), figure, end
    ax = axes('units','normal','Position', position);
        set(ax,'units',get(gcf,'defaultaxesunits'))
else 
    ax = gca; 
end


% return identifier, if requested:
if(nargout > 0)
    theAxis = ax;
end
