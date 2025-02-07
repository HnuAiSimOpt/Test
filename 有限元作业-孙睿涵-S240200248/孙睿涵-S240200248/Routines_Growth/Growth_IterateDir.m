
%==========================================================================
% Iterations: global energy minimization
%==========================================================================

% iStep     = iStep     - 1;
% iIter_dir = iIter_dir + 1;
% 
% fIter_dir -- is changed here, but topology update is still necesary
%   the general rule is that if this script is executed an update will 
%   be necessary to do.
% 
% key variables used for updating: mCk2Up
% variables not used for updating: vTp2Up
% 
% enrichment will be updated provided any(mCk2Up(:)) == 1 and iIter_dir > 0
% 
% Need to preserve consistency between 'vTp2Up' and 'mCk2Up'; the price of
% managing both is somewhat justified by the convenience to use either one.

%--------------------------------------------------------------------------
% Determine which crack tips to iterate
%--------------------------------------------------------------------------

if iIter_dir == 1; fprintf('\n\titerating directions, iIter_dir = 1\n')
    
    % active tips to iterate
    mCk2Up(mNoInc_grw~=1) = 0;
    mCk2Up = mCk2Up & mTpAct;
    
    % (irrelevant sort order)
    vTp2Up = find(mCk2Up(:));
    nTp2Up = length(vTp2Up);
    
    % init. sum angle changes
    vDlSum = zeros(nTp2Up,1);
    
    % backup (active)
    vTpIt0 = vTp2Up;
    nTpIt0 = nTp2Up;
    
    % no new segments
    mNoInc_grw(:) = 0;
    
elseif iIter_dir > 1; fprintf('\n\titerating directions, iIter_dir = %d\n',iIter_dir)
    
    % tips below minimum change in dir.
    p = vDlBta.^2 < dBetaTol_iterDir^2;
    
    % discard (within tolerance)
    mCk2Up(vTp2Up(p)) = false;
    
    % ones to keep
    p = find(~p);
    
    % update to current
    vTp2Up = vTp2Up(p);
    nTp2Up = length(p);
    
else fprintf('\n\titerating directions, iIter_dir = 1 (restarted)\n')
    
    % restart iter.
    iIter_dir = 1;
    
    % reinitialize
    vTp2Up = vTpIt0;
    nTp2Up = nTpIt0;
    
    % redo all increments
    mCk2Up(vTp2Up) = true;
    
end

if nTp2Up~=nnz(mCk2Up);error('nTp2Up ~= nnz(mCk2Up)'); end
fprintf('\tremaining crack tips, nTp2Up    = %d\n',nTp2Up)

%--------------------------------------------------------------------------
% Check if K1 > 0
%--------------------------------------------------------------------------

if iIter_dir == 1 % || 1
    
    R_sif = mTpRdi*f_sif;
    R_sif(~mCk2Up) = 0;
    
    % K1_aux = 0;
    % K2_aux = 0;
    
    k1 = IntM(nCrack,cCkCrd,mNDspS,mNDspE,...
        mPrLod,vElPhz,cDMatx,G,kappa,R_sif,1,0);
    
    k2 = IntM(nCrack,cCkCrd,mNDspS,mNDspE,...
        mPrLod,vElPhz,cDMatx,G,kappa,R_sif,0,1);
    
    if wCkLod
        k1 = k1 + IntM_CrkLod(nCrack,cCkCrd,...
            nGsBrn_gam,mGsBrn_gamShp,vGsBrn_gamWgt,...
            vElPhz,G,kappa,R_sif,mCkLod,1,0);
        
        k2 = k2 + IntM_CrkLod(nCrack,cCkCrd,...
            nGsBrn_gam,mGsBrn_gamShp,vGsBrn_gamWgt,...
            vElPhz,G,kappa,R_sif,mCkLod,0,1);
    end
    
    % for i = find(k1(:,1))'
    %     k1(i,1) = k1(i,1)*E_str(vElPhz(cBrStd_eTp{i,1}(1)))/2;
    % end
    % for i = find(k2(:,1))'
    %     k2(i,1) = k2(i,1)*E_str(vElPhz(cBrStd_eTp{i,1}(1)))/2;
    % end
    
    % get tips in compression (k1>0)
    p = ismember(vTp2Up,find(k1<0));
    
    if any(p)
        fprintf('\n\tdiscarding crack tips in compression (K1<0)\n')
    end
    
    mCk2Up(vTp2Up(p)) = 0;
    p=~p; vTp2Up=vTp2Up(p);
    nTp2Up = length(vTp2Up);
    
    if nTp2Up == 0
        nTpIt0 = 0;
        vTpIt0 = [];
        vDlSum = [];
    end
end

%--------------------------------------------------------------------------
% Get energy release rates
%--------------------------------------------------------------------------

% compute Gs and Hs
Growth_GsRates_rot
q = find(vGsTip);

if any(eig(mHsTip(q,q)) > 0) % continue with iterations anyway (risky!)
   warning('energy is non-convex with respect to growth direction(s)');
   if with_Debug; keyboard; end;
end

% get inc. dir. change
vDlBta = -mHsTip\vGsTip;

if strcmp(kind_GrwCrt,'symmetric') % average directions
    vDlBta = Growth_MakeSym(vDlBta); % tol = 1e-2;
end

if any(vGsTip==0) % || any(vDlBta==0)
    if with_RfnXrs % (try to refine)
        
        % determine if mesh can be refined
        mCk2Rf = mCk2Up & mCkRfN<nRefine_xrs;
        mCk2Rf(vTp2Up(vGsTip~=0)) = false;
        
        % initially discard all these tips
        mCk2Up(vTp2Up(vGsTip==0)) = false;
        
        if any(mCk2Rf(:))
            
            % revive (some) crack tips
            mCk2Up = mCk2Up | mCk2Rf;
            
            % assert tips to be refined
            mCkRfn(mCk2Rf) = true;
            
            % update n. times to refine
            mCkRfN = mCkRfN+real(mCk2Rf);
            
            % refine enrichment radii (halfing)
            mTpRdi = mTpRdi.*(0.5.^real(mCk2Rf));
            
            for i = find(mCk2Rf(:,1))' % half and rotate back
                cCkCrd{i}(1,:) = 0.5*sum(cCkCrd{i}([1,2],:),1);
                vDlBta(vTp2Up==i) = -vDlSum(vTpIt0==i);
            end
            for i = find(mCk2Rf(:,2))' % half and rotate back
                cCkCrd{i}(end,:) = 0.5*sum(cCkCrd{i}([end-1,end],:),1);
                vDlBta(vTp2Up==i+nCrack) = -vDlSum(vTpIt0==i+nCrack);
            end
            
            % restart iter.
            iIter_dir = -1; % (trick)
            
        end
    else
        % cannot compute Gs; discard tip(s)
        mCk2Up(vTp2Up(vGsTip==0)) = false;
    end
    
    % remaining tips
    p = vDlBta ~= 0;
    nTp2Up = nnz(p);
    
    vTp2Up = vTp2Up(p);
    vDlBta = vDlBta(p);
    vGsTip = vGsTip(p);
    
end

%--------------------------------------------------------------------------
% Update increment directions
%--------------------------------------------------------------------------

if nTp2Up > 0
    
    p = vGsTip~=0 & abs(vDlBta)>0.50;
    vDlBta(p) = sign(vGsTip(p))*0.50;
    
    for i = 1:nTp2Up; j=vTp2Up(i); b=vDlBta(i);
        T = [cos(b),sin(b);-sin(b),cos(b)]; % rotate anti-clockwise
        
        if j <= nCrack; x = cCkCrd{j}(1:2,:);
            cCkCrd{j}(  1,:) = x(2,:) + (x(1,:)-x(2,:))*T;
        else j = j-nCrack; x = cCkCrd{j}(end-1:end,:);
            cCkCrd{j}(end,:) = x(1,:) + (x(2,:)-x(1,:))*T;
        end
        
    end
    
    % update changes in kink angles
    [p,q] = ismember(vTpIt0,vTp2Up);
    vDlSum(p) = vDlSum(p)+vDlBta(q(p));
    
end

%--------------------------------------------------------------------------
% Check if iterations should be stopped
%--------------------------------------------------------------------------

if nTp2Up > 0
    if all(vDlBta.^2 < dBetaTol_iterDir^2); fIter_dir = 0;
        % fprintf('\n\tgrowth directions have converged\n')
    elseif iIter_dir==nIter_dir; fIter_dir = 0;
        fprintf('\n\tWARNING: iterations have not converged\n')
    end
else
    fIter_dir = 0;
end

%--------------------------------------------------------------------------
% Use an averaged growth direction
%--------------------------------------------------------------------------

if with_DirAvg && ~fIter_dir && nTpIt0>0 % (iterations finished)
    
    % upd. all prev. tips
    mCk2Up(vTpIt0) = true;
    
    % avg. inc. angles
    vDlSum = 0.5*vDlSum; % angle change (clockwise)
    
    for i = 1:nTpIt0; j=vTpIt0(i); b=vDlSum(i);
        T = [cos(b),-sin(b);sin(b),cos(b)]; % rotate clockwise
        
        if j <= nCrack; x = cCkCrd{j}(1:2,:);
            cCkCrd{j}(  1,:) = x(2,:) + (x(1,:)-x(2,:))*T;
        else j = j-nCrack; x = cCkCrd{j}(end-1:end,:);
            cCkCrd{j}(end,:) = x(1,:) + (x(2,:)-x(1,:))*T;
        end
        
    end
    
    % n.b.: since vDlSum = 0.5*vDlSum, this has the net effect
    % of a clockwise rotation by 0.5*vDlSum, which is consistent
    % with the initial orientation.
    
    % for completeness
    vTp2Up = vTpIt0;
    nTp2Up = nTpIt0;
    
end

%--------------------------------------------------------------------------
% Refine if angle change is too big
%--------------------------------------------------------------------------

if with_RfnInc && ~fIter_dir && nTpIt0>0
    
    mCk2Rf = false(nCrack,2);
    mCk2Rf(vTpIt0) = abs(vDlSum)>dBetaMin_mshFine & ...
        reshape(mCkRfN(vTpIt0)<nRefine_inc,[],1);
    
    if any(mCk2Rf(:)); fprintf('\n\tadaptive remeshing: refining\n')
        
        % upd. ones that kink a lot
        mCk2Up(mCk2Rf) = true;
        % update which are refined
        mCkRfn(mCk2Rf) = true;
        % update n. times to refine
        mCkRfN = mCkRfN+real(mCk2Rf);
        
        for i = find(mCk2Rf(:,2))' % halfing the increment
            cCkCrd{i}(end,:) = 0.5*sum(cCkCrd{i}([end-1,end],:),1);
        end
        for i = find(mCk2Rf(:,1))' % halfing the increment
            cCkCrd{i}(1,:) = 0.5*sum(cCkCrd{i}([1,2],:),1);
        end
        
        % refine enrichment radii (halfing)
        mTpRdi = mTpRdi.*(0.5.^real(mCk2Rf));
        
        % rotate back to initial direction (better convergence)
        for j = find(mCk2Up(:))'; b=-vDlSum(vTpIt0==j);
            T = [cos(b),sin(b);-sin(b),cos(b)]; % rotate clockwise
            
            if j <= nCrack; x = cCkCrd{j}(1:2,:);
                cCkCrd{j}(  1,:) = x(2,:) + (x(1,:)-x(2,:))*T;
            else j = j-nCrack; x = cCkCrd{j}(end-1:end,:);
                cCkCrd{j}(end,:) = x(1,:) + (x(2,:)-x(1,:))*T;
            end
            
        end
        
        % zero rotations for the restarted increments
        vDlSum(ismember(vTpIt0,find(mCk2Up(:)))) = 0;
        
        % restart iter.
        fIter_dir = 1;
        iIter_dir =-1;
        
        vTp2Up = find(mCk2Up(:));
        nTp2Up = length(vTp2Up);
        
    end
end

%--------------------------------------------------------------------------
% Set crack segments to update
%--------------------------------------------------------------------------

% segments to update (==1)
mNoInc_upd = double(mCk2Up);

% no new segments
% mNoInc_grw(:) = 0; % (already in effect)

%--------------------------------------------------------------------------
