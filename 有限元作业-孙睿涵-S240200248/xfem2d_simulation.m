function xfem2d_simulation()
    %% XFEM 2D Crack Propagation Simulation (Simplified Skeleton)
    %
    % This script sets up a 2D rectangular plate with an initial
    % horizontal crack and applies boundary conditions similar to the Abaqus
    % example. It then assembles the finite element system using standard
    % enriched (XFEM) shape functions and solves for the displacements.
    %
    % Note: This code is a demonstration and does not include full XFEM
    % features (such as accurate integration over discontinuous elements or a
    % complete crack propagation algorithm).
    
    clc; clear; close all;
    
    %% Geometry and Mesh Parameters
    Lx = 3.0;      % Length in x-direction (from 0 to 3)
    Ly = 6.0;      % Total height; plate from y = -3 to y = 3
    numX = 30;     % Number of elements along x
    numY = 60;     % Number of elements along y
    [nodes, elements] = generateMesh(0, Lx, -3, 3, numX, numY);
    
    %% Material Properties
    material.E = 210e9;         % Young's modulus in Pa
    material.nu = 0.3;          % Poisson's ratio
    material.t = 1.0;           % Thickness
    % Fracture/damage parameters (for illustration)
    material.sigma_max = 220e6; % Maximum stress for damage initiation (Pa)
    material.Gc = 42200;        % Fracture energy (J/m^2) (example value)
    
    %% Crack Geometry (initial crack)
    % Define the initial crack as a horizontal line from (0,0.05) to (1.5,0.05)
    crack.x1 = 0.0; crack.y1 = 0.05;
    crack.x2 = 1.5; crack.y2 = 0.05;
    
    %% Identify Enriched Nodes
    % In XFEM, nodes whose support is “cut” by the crack are enriched.
    enrich = identifyEnrichedNodes(nodes, elements, crack);
    
    %% Assemble Global Stiffness Matrix and Force Vector
    [K, F] = assembleSystem(nodes, elements, enrich, material, crack);
    
    %% Apply Boundary Conditions
    % For this example, we mimic:
    %   - Top boundary: fixed (encastre)
    %   - Bottom boundary: prescribed displacement u_x=0.2, u_y=-0.15
    [K_bc, F_bc, fixedDofs, prescribedDofs, u_prescribed] = ...
        applyBoundaryConditions(nodes, K, F);
    
    %% Solve the System
    % Solve the linear system for the unknown degrees of freedom.
    u = zeros(size(F));
    freeDofs = setdiff(1:length(F), fixedDofs);
    u(freeDofs) = K_bc(freeDofs, freeDofs) \ F_bc(freeDofs);
    u(fixedDofs) = u_prescribed(fixedDofs);
    
    %% (Optional) Crack Propagation Criterion and Update
    % Here you would compute the stress intensity factors or another fracture
    % criterion to decide if/where the crack should extend. Then update the
    % crack geometry and reassemble the system.
    % For this skeleton code, we assume a single load step.
    
    %% Post-Processing
    postProcess(nodes, elements, u, enrich, crack);
    
    disp('XFEM simulation complete.');
end

%% ----------------- Mesh Generation Function ----------------- %%
function [nodes, elements] = generateMesh(xmin, xmax, ymin, ymax, numX, numY)
    % Generates a structured quadrilateral mesh for a rectangular domain.
    %
    % Inputs:
    %   xmin,xmax, ymin,ymax - Domain limits.
    %   numX, numY         - Number of elements along x and y.
    %
    % Outputs:
    %   nodes    - [nNodes x 2] coordinates of nodes.
    %   elements - [nElem x 4] node connectivity (element node numbers).
    
    % Generate node coordinates
    x = linspace(xmin, xmax, numX+1);
    y = linspace(ymin, ymax, numY+1);
    [X, Y] = meshgrid(x, y);
    nodes = [X(:), Y(:)];
    
    % Generate element connectivity (4-node quads)
    elements = [];
    numNodesX = numX + 1;
    for j = 1:numY
        for i = 1:numX
            n1 = (j-1)*numNodesX + i;
            n2 = n1 + 1;
            n3 = n2 + numNodesX;
            n4 = n1 + numNodesX;
            elements(end+1,:) = [n1, n2, n3, n4];
        end
    end
end

%% ----------------- Enrichment Identification ----------------- %%
function enrich = identifyEnrichedNodes(nodes, elements, crack)
    % Identify nodes to be enriched (e.g., with the Heaviside function) based on
    % the intersection of the crack with the element.
    %
    % For each element, if the crack line crosses the element, then mark its
    % nodes for enrichment.
    %
    % This is a simplified test based on element bounding boxes.
    
    numNodes = size(nodes,1);
    enrich = false(numNodes,1); % flag for enriched nodes
    
    % Loop over elements
    for el = 1:size(elements,1)
        nodeInd = elements(el,:);
        coords = nodes(nodeInd, :);
        % Compute bounding box for the element
        xmin = min(coords(:,1)); xmax = max(coords(:,1));
        ymin = min(coords(:,2)); ymax = max(coords(:,2));
        
        % Check if the crack (as a line segment) intersects the box
        if lineIntersectsBox(crack.x1, crack.y1, crack.x2, crack.y2, xmin, xmax, ymin, ymax)
            enrich(nodeInd) = true;
        end
    end
end

function flag = lineIntersectsBox(x1, y1, x2, y2, xmin, xmax, ymin, ymax)
    % Simple test for intersection between a line segment and an axis-aligned box.
    %
    % This function returns true if the line from (x1,y1) to (x2,y2) intersects
    % the box defined by [xmin, xmax] and [ymin, ymax].
    
    % Check if both endpoints are on one side of the box
    if (x1 < xmin && x2 < xmin) || (x1 > xmax && x2 > xmax) || ...
       (y1 < ymin && y2 < ymin) || (y1 > ymax && y2 > ymax)
        flag = false;
    else
        % A more detailed intersection test could be implemented here.
        flag = true;
    end
end

%% ----------------- System Assembly Function ----------------- %%
function [K, F] = assembleSystem(nodes, elements, enrich, material, crack)
    % Assemble the global stiffness matrix K and force vector F for the plate.
    %
    % This function uses standard finite element assembly with additional
    % enrichment degrees of freedom for nodes flagged in "enrich". The XFEM
    % enrichment functions (e.g., a Heaviside function for the crack face) would
    % be incorporated into the element formulation.
    %
    % For brevity, the code here uses a standard bilinear quadrilateral element.
    % In a full XFEM implementation, you must modify the shape functions and the
    % integration accordingly.
    
    numNodes = size(nodes,1);
    numDofsPerNode = 2;  % u and v displacements
    
    % For enriched nodes, assume one extra degree-of-freedom per node (for the
    % discontinuous enrichment). Here we add a simple flag to account for extra
    % unknowns.
    extraDofs = sum(enrich);
    totalDofs = numNodes * numDofsPerNode + extraDofs;
    
    K = sparse(totalDofs, totalDofs);
    F = zeros(totalDofs,1);
    
    % Gauss points and weights for 2x2 integration (standard quadrature)
    gp = [-1/sqrt(3), 1/sqrt(3)];
    [xi_gp, eta_gp] = meshgrid(gp, gp);
    xi_gp = xi_gp(:); eta_gp = eta_gp(:);
    w = ones(length(xi_gp),1);
    
    % Elasticity matrix (plane stress or plane strain as needed)
    % For this example, we assume plane strain.
    E = material.E; nu = material.nu;
    D = (E/((1+nu)*(1-2*nu)))*[1-nu,   nu,        0;
                                nu,   1-nu,       0;
                                0,      0,   0.5*(1-2*nu)];
    
    % Loop over elements and assemble
    for el = 1:size(elements,1)
        nodeInd = elements(el,:);
        elemCoords = nodes(nodeInd,:);
        
        % Determine if any node in the element is enriched
        enrichedNodes = enrich(nodeInd);
        nEnriched = sum(enrichedNodes);
        
        % Local degrees of freedom indices for standard dofs
        stdDofInd = zeros(1, 2*length(nodeInd));
        for i = 1:length(nodeInd)
            stdDofInd(2*i-1:2*i) = [(nodeInd(i)-1)*2+1, (nodeInd(i)-1)*2+2];
        end
        
        % Local stiffness matrix for the element (including enriched dofs)
        % For demonstration, we only compute the standard part.
        Ke = zeros(2*length(nodeInd));
        for gp_i = 1:length(w)
            xi = xi_gp(gp_i); eta = eta_gp(gp_i);
            [N, dN_dxi] = shapeFunctionsQ4(xi, eta);
            % Jacobian
            J = dN_dxi * elemCoords;
            detJ = det(J);
            dN_dx = J \ dN_dxi;
            % Strain-displacement matrix B
            B = zeros(3, 2*length(nodeInd));
            for i = 1:length(nodeInd)
                B(:,2*i-1:2*i) = [dN_dx(1,i)     0;
                                   0         dN_dx(2,i);
                                   dN_dx(2,i) dN_dx(1,i)];
            end
            Ke = Ke + (B' * D * B)*detJ*w(gp_i);
        end
        
        % Assemble Ke into global K (only standard dofs shown)
        K(stdDofInd, stdDofInd) = K(stdDofInd, stdDofInd) + Ke;
        
        % For a full XFEM formulation, you would also compute coupling terms
        % between standard and enriched dofs and the enriched-enriched stiffness.
    end
    
    % (Optionally) apply body forces or other loads into F.
    % For this example, F remains zero.
end

%% ----------------- Shape Functions for Q4 Element ----------------- %%
function [N, dN_dxi] = shapeFunctionsQ4(xi, eta)
    % Returns the bilinear shape functions and their derivatives for a
    % four-node quadrilateral element evaluated at (xi,eta) in the reference
    % domain [-1,1] x [-1,1].
    
    N = 1/4 * [(1 - xi)*(1 - eta);
               (1 + xi)*(1 - eta);
               (1 + xi)*(1 + eta);
               (1 - xi)*(1 + eta)];
    
    dN_dxi = 1/4 * [-(1 - eta), -(1 - xi);
                     (1 - eta),  -(1 + xi);
                     (1 + eta),   (1 + xi);
                    -(1 + eta),   (1 - xi)]';
    % dN_dxi is 2x4: rows for derivatives w.r.t. xi and eta.
end

%% ----------------- Boundary Conditions ----------------- %%
function [K_mod, F_mod, fixedDofs, prescribedDofs, u_prescribed] = applyBoundaryConditions(nodes, K, F)
    % Applies the following boundary conditions:
    %   - Top boundary (y = 3): u_x = 0, u_y = 0 (encastre)
    %   - Bottom boundary (y = -3): u_x = 0.2, u_y = -0.15
    %
    % The degrees of freedom are arranged as: [u1, v1, u2, v2, ...]
    
    numNodes = size(nodes,1);
    numDofs = numNodes * 2;
    u_prescribed = zeros(numDofs,1);
    fixedDofs = [];
    
    tol = 1e-6;
    for i = 1:numNodes
        y = nodes(i,2);
        dof_u = (i-1)*2+1;
        dof_v = (i-1)*2+2;
        if abs(y - 3) < tol
            % Top boundary: fixed
            fixedDofs = [fixedDofs; dof_u; dof_v];
        elseif abs(y + 3) < tol
            % Bottom boundary: prescribed displacement
            u_prescribed(dof_u) = 0.2;
            u_prescribed(dof_v) = -0.15;
            fixedDofs = [fixedDofs; dof_u; dof_v];
        end
    end
    
    % For simplicity, assume prescribed dofs = fixed dofs.
    prescribedDofs = fixedDofs;
    
    % Modify K and F to account for essential boundary conditions
    K_mod = K;
    F_mod = F;
    % (A common approach is to impose Dirichlet BCs by setting rows and columns)
    for idx = fixedDofs'
        K_mod(idx,:) = 0;
        K_mod(:,idx) = 0;
        K_mod(idx,idx) = 1;
        F_mod(idx) = u_prescribed(idx);
    end
end

%% ----------------- Post-Processing ----------------- %%
function postProcess(nodes, elements, u, enrich, crack)
    % Plot the deformed mesh and highlight enriched nodes and crack location.
    
    scaleFactor = 1e3;  % scale displacement for visualization
    numNodes = size(nodes,1);
    
    % Compute displaced coordinates (only standard displacements are used)
    u_std = u(1:2*numNodes);
    u_disp = reshape(u_std, 2, [])';
    nodes_def = nodes + scaleFactor*u_disp;
    
    figure;
    hold on; axis equal;
    title('Deformed Mesh with XFEM Enrichment (Skeleton)');
    % Plot undeformed mesh in light gray
    for el = 1:size(elements,1)
        nd = elements(el,:);
        coords = nodes(nd,:);
        patch(coords(:,1), coords(:,2), [0.9 0.9 0.9], 'EdgeColor', [0.8 0.8 0.8]);
    end
    % Plot deformed mesh in blue
    for el = 1:size(elements,1)
        nd = elements(el,:);
        coords = nodes_def(nd,:);
        patch(coords(:,1), coords(:,2), 'w', 'EdgeColor', 'b', 'FaceAlpha',0.5);
    end
    % Mark enriched nodes with red circles
    enrichedNodes = find(enrich);
    plot(nodes_def(enrichedNodes,1), nodes_def(enrichedNodes,2), 'ro', 'MarkerSize',6, 'LineWidth',1.5);
    
    % Plot the initial crack in black (using original coordinates)
    plot([crack.x1, crack.x2], [crack.y1, crack.y2], 'k-', 'LineWidth',2);
    
    xlabel('x (m)');
    ylabel('y (m)');
    legend('Undeformed mesh','Deformed mesh','Enriched nodes','Crack');
    hold off;
end
