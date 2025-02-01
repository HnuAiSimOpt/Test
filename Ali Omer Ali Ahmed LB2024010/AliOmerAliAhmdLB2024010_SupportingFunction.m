           %% Section Eleven: Supporting Functions:
%% First: function to generate indices for calcualting van mises stress
function dofIndices = getElementDOFIndices(node1, node2, dofPerNode)
    dofIndices = [dofPerNode*(node1-1)+1:dofPerNode*node1, dofPerNode*...
        (node2-1)+1:dofPerNode*node2];
end

%% Second: Transformation matrix for 3D frame
function T = transformation_matrix_3d(direction_cosines)
    lx = direction_cosines(1);
    ly = direction_cosines(2);
    lz = direction_cosines(3);
%     T = blkdiag([lx, ly, lz], [lx, ly, lz]);
    Tt = [lx, ly, lz, 0, 0, 0; -ly, lx, 0, 0, 0, 0; 0, 0, lx, ly, lz, 0;
        0, 0, 0, 1, 0, 0; 0, 0, 0, 0, 1, 0; 0, 0, 0, 0, 0, 1];
    T_expanded = zeros(12, 12);
    T_expanded(1:6, 1:6) = Tt;
    T_expanded(7:12, 7:12) = Tt;
    T = T_expanded;
end

%% Third: Local stiffness matrix for a 3D frame element (12x12)
function k_local = local_stiffness_matrix(a1, a2, b1, b2, b3, c1, c2, c3)
    % Local stiffness matrix for a 3D frame element (12x12)
    k_local = [a1, 0, 0, 0, 0, 0, -a1, 0, 0, 0, 0, 0; 
               0, b1, 0, 0, 0, b2, 0, -b1, 0, 0, 0, b2;
               0, 0, c1, 0, -c2, 0, 0, 0, -c1, 0, -c2, 0;
               0, 0, 0, a2, 0, 0, 0, 0, 0, -a2, 0, 0;
               0, 0, -c2, 0, 2*c3, 0, 0, 0, c2, 0, c3, 0;
               0, b2, 0, 0, 0, 2*b3, 0, -b2, 0, 0, 0, b3;
               -a1, 0, 0, 0, 0, 0, a1, 0, 0, 0, 0, 0;
               0, -b1, 0, 0, 0, b2, 0, b1, 0, 0, 0, -b2;
               0, 0, -c1, 0, -c2, 0, 0, 0, c1, 0, c2, 0;
               0, 0, 0, -a2, 0, 0, 0, 0, 0, a2, 0, 0;
               0, 0, c2, 0, c3, 0, 0, 0, c2, 0, 2*c3, 0;
               0, -b2, 0, 0, 0, b3, 0, -b2, 0, 0, 0, 2*b3];
end

%% Fourth: % Function to generate nodes and elements for the frame
% Function to generate nodes and elements for the frame
function [nodes, elements] = generate_frame_nodes_elements(L1, L2, H1,...
    H2, H3, numDivVertTall, numDivVertShort, numDivHoriz, numDivInclined)
    nodes = [];
    elements = [];
    nodeIdx = 1;
    % Vertical Columns (Tall column - one)
    z_tall = linspace(0, L1, numDivVertTall + 1);
    for i = 1:length(z_tall)
        nodes(nodeIdx, :) = [H2, 0, z_tall(i)];
        elements = [elements; nodeIdx, nodeIdx+1];
        nodeIdx = nodeIdx + 1;
    end
    % Horizantal Beam one
    y_horiz = linspace(0, H1, numDivHoriz + 1);
    for i = 1:length(y_horiz)
            nodes(nodeIdx, :) = [H2, y_horiz(i), L1];
            elements = [elements; nodeIdx-1, nodeIdx];
            nodeIdx = nodeIdx + 1; 
    end
    % Vertical Columns (Tall column - two)
    z_tall2 = linspace(L1, 0, numDivVertTall + 1);
    for i = 1:length(z_tall2)
                nodes(nodeIdx, :) = [H2, H1, z_tall2(i)];
                nodeIdx = nodeIdx + 1;
                elements = [elements; nodeIdx-2, nodeIdx-1];
    end   
    % Vertical Columns (Short column - one)
    z_short = linspace(0, L2, numDivVertShort + 1);
     for i = 1:length(z_short)
                nodes(nodeIdx, :) = [0, H1, z_short(i)];
                nodeIdx = nodeIdx + 1;
                elements = [elements; nodeIdx-2, nodeIdx-1];
     end
    % Horizantal Beam - Two
    x_horiz2 = linspace(H1, 0, numDivHoriz + 1);
    for i = 1:length(x_horiz2)
            nodes(nodeIdx, :) = [0, x_horiz2(i), L2];
            elements = [elements; nodeIdx-1, nodeIdx];
            nodeIdx = nodeIdx + 1; 
    end
    % Vertical Columns (Short column - two)
    z_short2 = linspace(L2, 0, numDivVertShort + 1);
    for i = 1:length(z_short2)
                nodes(nodeIdx, :) = [0, 0, z_short2(i)];
                nodeIdx = nodeIdx + 1;
                elements = [elements; nodeIdx-2, nodeIdx-1];
    end
    % Inclinded Beam - one
    x_inc1 = linspace(0, H3, numDivInclined + 1);
    z_incl = linspace(L2, L1, numDivInclined + 1);
    for i = 1:length(x_inc1)
        nodes(nodeIdx, :) = [x_inc1(i), 0, z_incl(i)];
        elements = [elements; nodeIdx-1, nodeIdx];
        nodeIdx = nodeIdx + 1; 
    end  
    % Inclinded Beam - two
    x_inc2 = linspace(H3, 0, numDivInclined + 1);
    z_inc2 = linspace(L1, L2, numDivInclined + 1);
    for i = 1:length(x_inc2)
        nodes(nodeIdx, :) = [x_inc2(i), H1, z_inc2(i)];
        elements = [elements; nodeIdx-1, nodeIdx];
        nodeIdx = nodeIdx + 1; 
    end
elements(length(z_tall),:) = [length(z_tall), 2*numDivVertTall+...
    2*numDivVertShort+2*numDivHoriz+numDivInclined+7];
elements(2*numDivVertTall+2*numDivHoriz+numDivVertShort+6,:) = ...
    [2*numDivVertTall+2*numDivHoriz+numDivVertShort+5, ...
    2*numDivVertTall+2*numDivHoriz+2*numDivVertShort+6];
elements(2*numDivVertTall+numDivHoriz+4 ,:) = [numDivVertTall+numDivHoriz, ...
    2*numDivVertTall+2*numDivHoriz+2*numDivVertShort+numDivInclined+7];
elements(2*numDivVertTall+numDivHoriz+numDivVertShort+5,:) = ...
    [2*numDivVertTall+numDivHoriz+numDivVertShort+4, 2*numDivVertTall+...
    2*numDivHoriz+2*numDivVertShort+2*numDivInclined+8];
end