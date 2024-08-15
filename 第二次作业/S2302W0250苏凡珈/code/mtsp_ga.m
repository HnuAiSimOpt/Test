function varargout = mtsp_ga(varargin)
    
    
    
    % 初始化默认配置
    coordinate=[4.1407    8.8274;
    9.9339    5.1140;
    7.0053    0.0601;
    8.1937    5.4394;
    1.4101    5.5655;
    2.6250    5.8100;
    8.3461    3.7254;
    2.8093    8.7925;
    9.5243    9.1284;
    6.2144    3.1682;
    2.6524    5.6416;
    9.7351    2.7343;
    8.9118    2.0409;
    1.2368    1.4550;
    4.1805    5.6669;
    9.2835    3.4469;
    6.1246    9.5830;
    2.4024    7.5959;
    0.9313    0.1697;
    0.0890    2.7190;
    4.5766    8.6224;
    4.0450    1.6808;
    6.9011    6.7675;
    0.8016    2.5981;
    7.0669    9.7597;
    2.2726    9.4433;
    0.2269    4.6872;
    2.1449    9.5102;
    0.1090    5.0635;
    1.6699    1.0926;
    3.5195    6.7861;
    5.4987    3.8606;
    4.2036    7.0331;
    9.1478    9.1130;
    3.8139    6.0702;
    9.6466    3.3561;
    9.1552    8.9013;
    9.2342    9.7080;
    1.4453    2.8225;
    2.3678    3.8990];
    defaultConfig.xy          = coordinate;
    defaultConfig.dmat        = [];
    defaultConfig.nSalesmen   = 5;
    defaultConfig.minTour     = 8;
    defaultConfig.popSize     = 80;
    defaultConfig.numIter     = 500;
    defaultConfig.showProg    = true;
    defaultConfig.showStatus  = true;
    defaultConfig.showResult  = true;
    defaultConfig.showWaitbar = false;
    
           
    if ~nargin
        userConfig = struct();
    elseif isstruct(varargin{1})
        userConfig = varargin{1};
    else
        try
            userConfig = struct(varargin{:});
        catch
            error('??? Expected inputs are either a structure or parameter/value pairs');
        end
    end
    
    

    configStruct = get_config(defaultConfig,userConfig);
    
    
    
    % 提取配置
    
    xy          = configStruct.xy;
    dmat        = configStruct.dmat;
    nSalesmen   = configStruct.nSalesmen;
    minTour     = configStruct.minTour;
    popSize     = configStruct.popSize;
    numIter     = configStruct.numIter;
    showProg    = configStruct.showProg;
    showStatus  = configStruct.showStatus;
    showResult  = configStruct.showResult;
    showWaitbar = configStruct.showWaitbar;
    if isempty(dmat)
        nPoints = size(xy,1);
        a = meshgrid(1:nPoints);
        dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),nPoints,nPoints);
    end
    
    
    
    % 验证输入

    [N,dims] = size(xy);
    [nr,nc] = size(dmat);
    if (N ~= nr) || (N ~= nc)
        error('??? Invalid XY or DMAT inputs')
    end
    n = N;
    
    

    nSalesmen   = max(1,min(n,round(real(nSalesmen(1)))));
    minTour     = max(1,min(floor(n/nSalesmen),round(real(minTour(1)))));
    popSize     = max(8,8*ceil(popSize(1)/8));
    numIter     = max(1,round(real(numIter(1))));
    showProg    = logical(showProg(1));
    showStatus  = logical(showStatus(1));
    showResult  = logical(showResult(1));
    showWaitbar = logical(showWaitbar(1));
    
    

    nBreaks = nSalesmen-1;
    dof = n - minTour*nSalesmen;          
    addto = ones(1,dof+1);
    for k = 2:nBreaks
        addto = cumsum(addto);
    end
    cumProb = cumsum(addto)/sum(addto);
    
    
    
    % 初始化种群
    
    popRoute = zeros(popSize,n);         % population of routes
    popBreak = zeros(popSize,nBreaks);   % population of breaks
    popRoute(1,:) = (1:n);
    popBreak(1,:) = rand_breaks();
    for k = 2:popSize
        popRoute(k,:) = randperm(n);
        popBreak(k,:) = rand_breaks();
    end
    
    

    if all(isfield(userConfig,{'optRoute','optBreak'}))
        optRoute = userConfig.optRoute;
        optBreak = userConfig.optBreak;
        isValidRoute = isequal(popRoute(1,:),sort(optRoute));
        isValidBreak = all(optBreak > 0) && all(optBreak <= n) && ...
            (length(optBreak) == nBreaks) && ~any(mod(optBreak,1));
        if isValidRoute && isValidBreak
            popRoute(1,:) = optRoute;
            popBreak(1,:) = optBreak;
        end
    end
    
    

    pclr = ~get(0,'DefaultAxesColor');
    clr = [1 0 0; 0 0 1; 0.67 0 1; 0 1 0; 1 0.5 0];
    if (nSalesmen > 5)
        clr = hsv(nSalesmen);
    end
    
    
    
    % GA
    
    globalMin = Inf;
    distHistory = NaN(1,numIter);
    tmpPopRoute = zeros(8,n);
    tmpPopBreak = zeros(8,nBreaks);
    newPopRoute = zeros(popSize,n);
    newPopBreak = zeros(popSize,nBreaks);
    [isClosed,isStopped,isCancelled] = deal(false);
    if showProg
        hFig = figure('Name','MTSP_GA | Current Best Solution', ...
            'Numbertitle','off','CloseRequestFcn',@close_request);
        hAx = gca;
        if showStatus
            [hStatus,isCancelled] = figstatus(0,numIter,[],hFig);
        end
    end
    if showWaitbar
        hWait = waitbar(0,'Searching for near-optimal solution ...', ...
            'CreateCancelBtn',@cancel_search);
    end
    isRunning = true;
    for iter = 1:numIter
        row = popRoute;
        col = popRoute(:,[2:n 1]);
        for p = 1:popSize
            brk = popBreak(p,:);
            col(p,[brk n]) = row(p,[1 brk+1]);
        end
        ind = N*(col-1) + row;
        totalDist = sum(dmat(ind),2);
        

        [minDist,index] = min(totalDist);
        distHistory(iter) = minDist;
        if (minDist < globalMin)
            globalMin = minDist;
            optRoute = popRoute(index,:);
            optBreak = popBreak(index,:);
            rng = [[1 optBreak+1];[optBreak n]]';
            if showProg
                
                
                % 绘制最优路径
                
                for s = 1:nSalesmen
                    rte = optRoute([rng(s,1):rng(s,2) rng(s,1)]);
                    if (dims > 2), plot3(hAx,xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
                    else, plot(hAx,xy(rte,1),xy(rte,2),'.-','Color',clr(s,:)); end
                    hold(hAx,'on');
                end
                title(hAx,sprintf('Total Distance = %1.4f, Iteration = %d',minDist,iter));
                hold(hAx,'off');
                drawnow;
            end
        end
        
        

        if showProg && showStatus && ~mod(iter,ceil(numIter/100))
            [hStatus,isCancelled] = figstatus(iter,numIter,hStatus,hFig);
        end
        if (isStopped || isCancelled)
            break
        end
        
        

        randomOrder = randperm(popSize);
        for p = 8:8:popSize
            rtes = popRoute(randomOrder(p-7:p),:);
            brks = popBreak(randomOrder(p-7:p),:);
            dists = totalDist(randomOrder(p-7:p));
            [ignore,idx] = min(dists); %#ok
            bestOf8Route = rtes(idx,:);
            bestOf8Break = brks(idx,:);
            routeInsertionPoints = sort(randperm(n,2));
            I = routeInsertionPoints(1);
            J = routeInsertionPoints(2);
            for k = 1:8 % Generate new solutions
                tmpPopRoute(k,:) = bestOf8Route;
                tmpPopBreak(k,:) = bestOf8Break;
                switch k
                    case 2 % Flip
                        tmpPopRoute(k,I:J) = tmpPopRoute(k,J:-1:I);
                    case 3 % Swap
                        tmpPopRoute(k,[I J]) = tmpPopRoute(k,[J I]);
                    case 4 % Slide
                        tmpPopRoute(k,I:J) = tmpPopRoute(k,[I+1:J I]);
                    case 5 % Modify breaks
                        tmpPopBreak(k,:) = rand_breaks();
                    case 6 % Flip, modify breaks
                        tmpPopRoute(k,I:J) = tmpPopRoute(k,J:-1:I);
                        tmpPopBreak(k,:) = rand_breaks();
                    case 7 % Swap, modify breaks
                        tmpPopRoute(k,[I J]) = tmpPopRoute(k,[J I]);
                        tmpPopBreak(k,:) = rand_breaks();
                    case 8 % Slide, modify breaks
                        tmpPopRoute(k,I:J) = tmpPopRoute(k,[I+1:J I]);
                        tmpPopBreak(k,:) = rand_breaks();
                    otherwise % Do nothing
                end
            end
            newPopRoute(p-7:p,:) = tmpPopRoute;
            newPopBreak(p-7:p,:) = tmpPopBreak;
        end
        popRoute = newPopRoute;
        popBreak = newPopBreak;
 
        
        
        if showWaitbar && ~mod(iter,ceil(numIter/325))
            waitbar(iter/numIter,hWait);
        end
        
    end
    if showProg && showStatus
        figstatus(numIter,numIter,hStatus,hFig);
    end
    if showWaitbar
        delete(hWait);
    end
    isRunning = false;
    if isClosed
        delete(hFig);
    end
    
    
    
    if isfield(userConfig,'distHistory')
        priorHistory = userConfig.distHistory;
        isNan = isnan(priorHistory);
        distHistory = [priorHistory(~isNan) distHistory];
    end
    
    

    optSolution = cell(nSalesmen,1);
    rng = [[1 optBreak+1];[optBreak n]]';
    for s = 1:nSalesmen
        optSolution{s} = optRoute([rng(s,1):rng(s,2) rng(s,1)]);
    end
    
    
    
    % 展示最终结果
    
    if showResult
        

        figure('Name','MTSP_GA | Results','Numbertitle','off');
        subplot(2,2,1);
        if (dims > 2), plot3(xy(:,1),xy(:,2),xy(:,3),'.','Color',pclr);
        else, plot(xy(:,1),xy(:,2),'.','Color',pclr); end
        title('City Locations');
        subplot(2,2,2);
        imagesc(dmat(optRoute,optRoute));
        title('Distance Matrix');
        subplot(2,2,3);
        for s = 1:nSalesmen
            rte = optSolution{s};
            if (dims > 2), plot3(xy(rte,1),xy(rte,2),xy(rte,3),'.-','Color',clr(s,:));
            else, plot(xy(rte,1),xy(rte,2),'.-','Color',clr(s,:)); end
            title(sprintf('Total Distance = %1.4f',minDist));
            hold on;
        end
        subplot(2,2,4);
        plot(distHistory,'b','LineWidth',2);
        title('Best Solution History');
        set(gca,'XLim',[1 length(distHistory)],'YLim',[0 1.1*max([1 distHistory])]);
    end
    
    

    if nargout
        

        plotPoints  = @(s)plot(s.xy(:,1),s.xy(:,2),'.','Color',~get(gca,'Color'));
        plotResult  = @(s)cellfun(@(s,i)plot(s.xy(i,1),s.xy(i,2),'.-', ...
            'Color',rand(1,3)),repmat({s},size(s.optSolution)),s.optSolution);
        plotHistory = @(s)plot(s.distHistory,'b-','LineWidth',2);
        plotMatrix  = @(s)imagesc(s.dmat(cat(2,s.optSolution{:}),cat(2,s.optSolution{:})));
        
        

        resultStruct = struct( ...
            'xy',          xy, ...
            'dmat',        dmat, ...
            'nSalesmen',   nSalesmen, ...
            'minTour',     minTour, ...
            'popSize',     popSize, ...
            'numIter',     numIter, ...
            'showProg',    showProg, ...
            'showResult',  showResult, ...
            'showWaitbar', showWaitbar, ...
            'optRoute',    optRoute, ...
            'optBreak',    optBreak, ...
            'optSolution', {optSolution}, ...
            'plotPoints',  plotPoints, ...
            'plotResult',  plotResult, ...
            'plotHistory', plotHistory, ...
            'plotMatrix',  plotMatrix, ...
            'distHistory', distHistory, ...
            'minDist',     minDist);
        
        varargout = {resultStruct};
        
    end
    
    

    function breaks = rand_breaks()
        if (minTour == 1) % No constraints on breaks
            breaks = sort(randperm(n-1,nBreaks));
        else % Force breaks to be at least the minimum tour length
            nAdjust = find(rand < cumProb,1)-1;
            spaces = randi(nBreaks,1,nAdjust);
            adjust = zeros(1,nBreaks);
            for kk = 1:nBreaks
                adjust(kk) = sum(spaces == kk);
            end
            breaks = minTour*(1:nBreaks) + cumsum(adjust);
        end
    end
    
    

    function cancel_search(varargin)
        isStopped = true;
    end
    
    

    function close_request(varargin)
        if isRunning
            [isClosed,isStopped] = deal(true);
            isRunning = false;
        else
            delete(hFig);
        end
    end
    
end

