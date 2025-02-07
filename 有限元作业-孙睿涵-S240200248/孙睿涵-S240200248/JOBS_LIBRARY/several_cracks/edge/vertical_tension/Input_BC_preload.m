function [e0_xpt,s0_xpt] = Input_BC_preload(x,input_args)
    if length(input_args) == 1
        e0_xpt = repmat(input_args{1}(:),1,size(x,1));
        s0_xpt = [];
        return
    end
    e0_lay = input_args{1};
    s0_lay = [];
    % position of pre-load layers
    depth = input_args{2};
    % thickness of pre-load layers
    thick = input_args{3};
    e0_xpt = [];
    s0_xpt = [];
    
    n = size(x,1);
    N = length(depth);
    
    if length(thick)~=N || (size(e0_lay,1)~=N && size(s0_lay,1)~=N)
        error('Inconsistent size between layer depth, thickness and pre-load.');
    end
    
    if ~isempty(e0_lay)
        e0_xpt = zeros(3,n);
        for i = 1:N
            
            q = find(x(:,2) > depth(i)-0.5*thick(i) ...
                & x(:,2) < depth(i)+0.5*thick(i));
            
            e0_xpt(1,q) = e0_lay(i,1);
            e0_xpt(2,q) = e0_lay(i,2);
            e0_xpt(3,q) = e0_lay(i,3);
            
        end
    else % ~isempty(s0_lay)
        s0_xpt = zeros(3,n);
        for i = 1:N
            
            q = find(x(:,2) > depth(i)-0.5*thick(i) ...
                & x(:,2) < depth(i)+0.5*thick(i));
            
            s0_xpt(1,q) = s0_lay(i,1);
            s0_xpt(2,q) = s0_lay(i,2);
            s0_xpt(3,q) = s0_lay(i,3);
            
        end
    end
end
