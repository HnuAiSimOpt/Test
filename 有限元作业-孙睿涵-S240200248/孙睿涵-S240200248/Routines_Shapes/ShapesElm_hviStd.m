
%==========================================================================
% Shapes for Heaviside enriched elements
%==========================================================================

% mGFnDv = []; % H,x = H,y = 0

for iElHvi = 1:length(vElHvi)
    
    uElHvi = vElHvi(iElHvi);
    vHvSgm = mHvSgm(iElHvi,:);
    
    % coord. of ck. segment(s) 
    mHvCrd = mCkCrd(vHvSgm(1):vHvSgm(2)+1,:);
    mElCrd = mNdCrd(mLNodS(uElHvi,:),:);
    
    %----------------------------------------------------------------------
    % Gauss shapes (std.)
    %----------------------------------------------------------------------
    
    mGsShS = cGsEnr_omgShS{uElHvi};
    mGsDvS = cGsEnr_omgDvS{uElHvi};
    
    %----------------------------------------------------------------------
    % Gauss shapes (enr.)
    %----------------------------------------------------------------------
    
    mGsCrd = mGsShS*mElCrd;
    
    [mGFnVl,mNdShf] = EnrFun_Hvi(mElCrd,mGsCrd,mHvCrd);
    
    [nLNodE,mGsShE,mGsDvE] = ShapesEnr_WtShf(mElCrd,...
        mGsShS,mGsDvS,1,mGFnVl,[],mNdShf); % n. enr. fun = 1
    
    cGsEnr_omgShE{uElHvi}(:,end+1:end+nLNodE) = mGsShE;
    cGsEnr_omgDvE{uElHvi}(:,end+1:end+nLNodE) = mGsDvE;
    
    %----------------------------------------------------------------------
    
end