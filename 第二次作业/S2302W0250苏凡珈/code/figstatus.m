function varargout = figstatus(i,n,hStatus,hFig)
    
    

    narginchk(2,4);
    
    

    persistent IS_CANCELLED;
    
    

    if isempty(IS_CANCELLED)
        IS_CANCELLED = false;
    end
    
    

    if IS_CANCELLED
        IS_CANCELLED = false;
        varargout = {[],true};
        return
    end
    
    
    if (nargin < 3) || isempty(hStatus) || ~ishandle(hStatus)
        

        if (nargin < 4) || isempty(hFig) || ~ishandle(hFig)
            hFig = gcf;
        end

        hStatus = findobj(hFig,'Tag','_figstatus_');
        if isempty(hStatus) && (i ~= n)
            
  
            figColor = get(hFig,'Color');
            hStatusPanel = uipanel(hFig, ...
                'Units',           'normalized', ...
                'Position',        [0 0 1 0.05], ...
                'BackgroundColor', figColor, ...
                'Tag',             '_figstatuspanel_', ...
                'BorderType',      'etchedin');
            hStatusAx = axes( ...
                'Color',           'w', ...
                'Units',           'normalized', ...
                'Position',        [0 0 1 1], ...
                'XLim',            [0 1], ...
                'YLim',            [0 1], ...
                'Visible',         'off', ...
                'Parent',          hStatusPanel);
            if ~verLessThan('matlab','9.5') % R2018b
                set(hStatusAx.Toolbar,'Visible','off');
                % disableDefaultInteractivity(hStatusAx);
            end
            if (nargout > 1)
                set(hStatusAx,'Position',[0 0 0.95 1]);
                uicontrol(hStatusPanel, ...
                    'Units',       'normalized', ...
                    'Position',    [0.95 0 0.05 1], ...
                    'String',      'X', ...
                    'Callback',    @trigger_cancel);
            end
            % cmw = 0.1 * repmat([7 10 10 7],3,1)';
            % patch([0 0 1 1],[0 1 1 0],[0.5 0.5 0.5], ...
            %     'FaceVertexCData',cmw, ...
            %     'FaceColor','interp', ...
            %     'EdgeColor','none', ...
            %     'Parent',hStatusAx);
            grn = 0.1 * [2 6 2; 8 10 8];
            cmg = grn([1 2 2 1],:);
            hStatus = patch([0 0 1 1],[0 1 1 0],[0.5 0.5 0.5], ...
                'FaceVertexCData',cmg, ...
                'FaceColor','interp', ...
                'EdgeColor','none', ...
                'Tag','_figstatus_', ...
                'Parent',hStatusAx);
            
        end
    end
    
    

    frac = (i / n);
    set(hStatus,'XData',[0 0 frac frac]);
    drawnow();
    
    

    if (i == n)
        hStatusPanel = findobj(hFig,'Tag','_figstatuspanel_');
        delete(hStatusPanel);
    end
    

    if nargout
        varargout = {hStatus,IS_CANCELLED};
    end
    

    function trigger_cancel(varargin)
        IS_CANCELLED = true;
        hStatusPanel  = findobj(hFig,'Tag','_figstatuspanel_');
        delete(hStatusPanel);
    end
    
end

