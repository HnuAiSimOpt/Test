function varargout = tsp_ga(varargin)
    
    
    %初始化默认配置
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
    defaultConfig.popSize     = 100;
    defaultConfig.numIter     = 1000;
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
    
    

    popSize     = 4*ceil(popSize/4);
    numIter     = max(1,round(real(numIter(1))));
    showProg    = logical(showProg(1));
    showStatus  = logical(showStatus(1));
    showResult  = logical(showResult(1));
    showWaitbar = logical(showWaitbar(1));
    
    
    
    % 初始化种群
    
    pop = zeros(popSize,n);
    pop(1,:) = (1:n);
    for k = 2:popSize
        pop(k,:) = randperm(n);
    end
    

    if isfield(userConfig,'optRoute')
        optRoute = userConfig.optRoute;
        isValid = isequal(pop(1,:),sort(optRoute));
        if isValid
            pop(1,:) = optRoute;
        end
    end
    
    
    
    % GA
    
    globalMin = Inf;
    distHistory = NaN(1,numIter);
    tmpPop = zeros(4,n);
    newPop = zeros(popSize,n);
    [isClosed,isStopped,isCancelled] = deal(false);
    if showProg
        hFig = figure('Name','TSP_GA | Current Best Solution', ...
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
        
        row = pop;
        col = pop(:,[2:n 1]);
        ind = N*(col-1) + row;
        totalDist = sum(dmat(ind),2);
        
        
        %选择最优路径

        [minDist,index] = min(totalDist);
        distHistory(iter) = minDist;
        if (minDist < globalMin)
            globalMin = minDist;
            optRoute = pop(index,:);
            if showProg
                
                
                % 画图
                
                rte = optRoute([1:n 1]);
                if (dims > 2), plot3(hAx,xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
                else, plot(hAx,xy(rte,1),xy(rte,2),'r.-'); end
                title(hAx,sprintf('Total Distance = %1.4f, Iteration = %d',minDist,iter));
                drawnow;
                
            end
        end
        
        
        
        % 验证
        
        if showProg && showStatus && ~mod(iter,ceil(numIter/100))
            [hStatus,isCancelled] = figstatus(iter,numIter,hStatus,hFig);
        end
        if (isStopped || isCancelled)
            break
        end
        
        
        randomOrder = randperm(popSize);
        for p = 4:4:popSize
            rtes = pop(randomOrder(p-3:p),:);
            dists = totalDist(randomOrder(p-3:p));
            [ignore,idx] = min(dists); %#ok
            bestOf4Route = rtes(idx,:);
            routeInsertionPoints = sort(randperm(n,2));
            I = routeInsertionPoints(1);
            J = routeInsertionPoints(2);
            for k = 1:4 % Mutate the best to get three new routes
                tmpPop(k,:) = bestOf4Route;
                switch k
                    case 2 % Flip
                        tmpPop(k,I:J) = tmpPop(k,J:-1:I);
                    case 3 % Swap
                        tmpPop(k,[I J]) = tmpPop(k,[J I]);
                    case 4 % Slide
                        tmpPop(k,I:J) = tmpPop(k,[I+1:J I]);
                    otherwise % Do nothing
                end
            end
            newPop(p-3:p,:) = tmpPop;
        end
        pop = newPop;
        
        

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
    
    

    index = find(optRoute == 1,1);
    optSolution = [optRoute([index:n 1:index-1]) 1];
    
    
    
    % 展示最终结果
    
    if showResult
        
        figure('Name','TSP_GA | Results','Numbertitle','off');
        subplot(2,2,1);
        pclr = ~get(0,'DefaultAxesColor');
        if (dims > 2), plot3(xy(:,1),xy(:,2),xy(:,3),'.','Color',pclr);
        else, plot(xy(:,1),xy(:,2),'.','Color',pclr); end
        title('City Locations');
        subplot(2,2,2);
        imagesc(dmat(optRoute,optRoute));
        title('Distance Matrix');
        subplot(2,2,3);
        rte = optSolution;
        if (dims > 2), plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
        else, plot(xy(rte,1),xy(rte,2),'r.-'); end
        title(sprintf('Total Distance = %1.4f',minDist));
        subplot(2,2,4);
        plot(distHistory,'b','LineWidth',2);
        title('Best Solution History');
        set(gca,'XLim',[1 length(distHistory)],'YLim',[0 1.1*max([1 distHistory])]);
    end
    

    if nargout
        

        plotPoints  = @(s)plot(s.xy(:,1),s.xy(:,2),'.','Color',~get(gca,'Color'));
        plotResult  = @(s)plot(s.xy(s.optSolution,1),s.xy(s.optSolution,2),'r.-');
        plotHistory = @(s)plot(s.distHistory,'b-','LineWidth',2);
        plotMatrix  = @(s)imagesc(s.dmat(s.optSolution,s.optSolution));
        
        

        resultStruct = struct( ...
            'xy',          xy, ...
            'dmat',        dmat, ...
            'popSize',     popSize, ...
            'numIter',     numIter, ...
            'showProg',    showProg, ...
            'showResult',  showResult, ...
            'showWaitbar', showWaitbar, ...
            'optRoute',    optRoute, ...
            'optSolution', optSolution, ...
            'plotPoints',  plotPoints, ...
            'plotResult',  plotResult, ...
            'plotHistory', plotHistory, ...
            'plotMatrix',  plotMatrix, ...
            'distHistory', distHistory, ...
            'minDist',     minDist);
        
        varargout = {resultStruct};
        
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

