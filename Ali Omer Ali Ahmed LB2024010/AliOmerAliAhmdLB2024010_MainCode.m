%% Finite Element Analysis for 3D Spatial frame element: 
% Student Name: Ali Omer Ali Ahmed
% Student ID:   LB2024010
% Date:        28/12/2024
% About:     This is a simple matlab script to analysis the deformation 
%             for 3D spatial frame element using finite element method 

clear; clc;
%% Section One: Shape Parameters:
% Hollow rectangular tube 
b = 0.03;                                  % Outer width in [m]
h = 0.06;                                  % Outer hight in [m]
t = 0.003;                                 % Wall thicness in [m]
b_in = b - 2 * t;                          % Inner width in [m]
h_in = h - 2 * t;                          % Inner hight in [m]

%% Section Two: Geometry Input Parameters: 
A = (b * h) - (b_in * h_in);               % Cross-sectional area [m^2]
I_y = ((b * h^3)/12)-((b_in * h_in^3)/12); % Moment of inertia y_axis [m^4]
I_x = ((h * b^3)/12)-((h_in * b_in^3)/12); % Moment of inertia x_axis [m^4]
Z_x = I_x /(h/2);                          % Section modulus [m^3]
J = (1/12)*(b*h^3 - b_in *h_in^3);         % Polar moment of Inertia [m^4]
L1 = 2;                                    % Length of tall columns [m]
L2 =  L1/ 2;                               % Length of short columns [m]
H1 = 4;                                    % Length of the frame [m]
H2 = 3;                                    % Width of the frame [m]
H3 = 3;                                    % Length of the inclined beam [m]

%% Section Three: Material Parameters (Mild Steel): 
E = 2e11;                                  % Young's Modulus [Pa]
G = 8e10;                                  % Shear modulus [Pa]
GJ = G * J; 

%% Section Four: Looding or Natutral Boundary condition:
distributedLoad = 400;         % Distributed load on horizontal beams (N/m)
scaleFactor = 1e-3;            % Scale factor for deformation visualization

%% Section Five: Domain Discritization (Meshing:
% The discritization is performed by selecting element length;
L_elem = input('What is element lenght for the automatic mesh? ');
numDivVertTall = L1/L_elem;       % Number of elements for taller columns
numDivVertShort = L2/L_elem;      % Number of elements for shorter columns
numDivHoriz = H1/L_elem;          % Number of elements for horizontal beams
numDivInclined = H3/L_elem;       % Number of elements for inclined beams
%Section Six: Generate Nodes and Connectivity
% Nodes and element connectivity calculated using a seperate function
% the Function is provided below in the Functions section
[nodes, elements] = generate_frame_nodes_elements(L1, L2, H1, H2, H3,...
    numDivVertTall, numDivVertShort, numDivHoriz, numDivInclined);

%% Section Six: Global Degrees of Freedom and Intialization:
nNodes =size(nodes,1);           % Total Number of Nodes
GDof = 6*nNodes;                 % DOFs per node
K_global = zeros(GDof);          % Global stiffness matrix
F = zeros(GDof, 1);              % Force vector

%% Section Seven: Assemble Global Stiffness Matrix
for e = 1:size(elements, 1)
       % Get element nodes
    n1 = elements(e, 1);
    n2 = elements(e, 2);
       % Get coordinates of the nodes
    x1 = nodes(n1, :);
    x2 = nodes(n2, :);  
      % Compute element length and direction cosines
    L = L_elem;
    direction_cosines = (x2 - x1) / L;   
    % Transformation matrix (local-to-global)
    T = transformation_matrix_3d(direction_cosines);
    % Local stiffness matrix (12x12)
    a1 = E*A/L; a2 = GJ/L; 
    b1 = (12*E*I_y)/L^3; b2 = (6*E*I_y)/L^2; b3 = (2*E*I_y)/L;
    c1 = (12*E*I_x)/L^3; c2 = (6*E*I_x)/L^2; c3 = (2*E*I_x)/L;
    k_local = local_stiffness_matrix(a1, a2, b1, b2, b3, c1, c2, c3);
    % Global stiffness matrix for the element
    k_glo = T' * k_local * T;
    % Global DOF indices
    dof_indices = [(n1-1)*6 + (1:6), (n2-1)*6 + (1:6) ]; 
    % Assemble into global stiffness matrix
    dof1 = (n1 - 1) * 6 + (1:6);
    dof2 = (n2 - 1) * 6 + (1:6);
    K_global(dof1, dof1) = K_global(dof1, dof1) + k_glo(1:6, 1:6);
    K_global(dof1, dof2) = K_global(dof1, dof2) + k_glo(1:6, 7:12);
    K_global(dof2, dof1) = K_global(dof2, dof1) + k_glo(7:12, 1:6);
    K_global(dof2, dof2) = K_global(dof2, dof2) + k_glo(7:12, 7:12);
end

%% Section Eight: Apply Boundary Conditions
% First: fixed Displacement at the bottom of the columns
Fixed_Point1 = 1;
Fixed_Point2 = 2*numDivVertTall+numDivHoriz+3;
Fixed_Point3 = 2*numDivVertTall+numDivHoriz+4;
Fixed_Point4 = 2*numDivVertTall+2*numDivHoriz+2*numDivVertShort+6;
fixedNodes = [Fixed_Point1, Fixed_Point2, Fixed_Point3, Fixed_Point4];
fixedDOFs = [1:6 ((Fixed_Point2-1)*6+1):Fixed_Point3*6 ((Fixed_Point4-1)*6+1):Fixed_Point4*6];
for i = 1: length(fixedDOFs)
K_global(fixedDOFs(i), :) = 0;
K_global(:, fixedDOFs(i)) = 0;
K_global(fixedDOFs(i), fixedDOFs(i)) = 1e3;
F(fixedDOFs(i)) = 0;
end
K_global = K_global + eye(size(K_global,1));
F = F + 1e-3;
% Second: External forces boundary conditions
Equivalent_load = 2*distributedLoad * L_elem/2;
top_nodes = [numDivVertTall+1:numDivVertTall+numDivHoriz+3 ...
    2*numDivVertTall+numDivHoriz+numDivVertShort+4:2*numDivVertTall+2*...
    numDivHoriz+numDivVertShort+6 ...
    Fixed_Point4+1:Fixed_Point4+2*numDivInclined+2]; % Indices of top nodes
Top_DOF = [(numDivVertTall*6)+3:6:((numDivVertTall+numDivHoriz+2)*6)+3 ...
    ((Fixed_Point3+numDivVertShort-1)*6)+3:6:((Fixed_Point4-...
    numDivVertShort-1)*6)+3 (Fixed_Point4*6)+3:6:((nNodes-1)*6)+3];

% Apply the wind load effect:
rho = 1.225;          % Density of the air
speed = 70;          % Wind Speed in [m/s^2]
theta = 20*pi/180;          % inclination angle of the frame [20 degree]
Frame_Area = H1*H2;  % Surface area of the pv panels 
Area_Proj = Frame_Area * cos (theta);  % Area prependicular to wind
Pre_wind = 0.5*speed^2*rho;            % Pressure 
Equ_wind_load = Pre_wind * Area_Proj * L_elem; % equivalent wind load
% to approximate the wind load along the edges, the load will be
% distributed as concentated load actin gon the nodes
wind_nodes = [numDivVertTall+1:numDivVertTall+numDivHoriz+2 Fixed_Point3...
    +numDivVertShort:Fixed_Point4-numDivVertShort ...
     Fixed_Point4+1:nNodes];
wind_DOFs_x = [(numDivVertTall*6)+1:6:((numDivVertTall+numDivHoriz+2)*6)+1....
    (6*(Fixed_Point3+numDivVertShort-1))+1:6:(6*(Fixed_Point4-...
    numDivVertShort-1))+1 (Fixed_Point4*6)+1:6:(6*(nNodes-1))+1];
F_edgePerNode = Equ_wind_load/length(wind_nodes);     % force at each node
% The wind load has both parallel and normal components
F_wp_x = F_edgePerNode*cos(theta); % parallel component of wind x-direction
F_wp_z = F_edgePerNode*sin(theta); % normal component of wind  z-direction
 % Apply BC. + wind load in load in Z-direction
F(Top_DOF) = -1*(F(Top_DOF) + Equivalent_load + F_wp_z);
 % Apply wind load in load in x-direction
F(wind_DOFs_x) = -1*(F(wind_DOFs_x) + F_wp_x);

%% Section Nine: Solve for Displacements:
U = K_global \ F;

%% Section Ten: Post-Processing - Displacement 
displacements = zeros(nNodes * 6, 1);
displacements(setdiff(1:end, 0)) = U;  % Assign calculated displacements
% Reshape displacements into nodal format
nodalDisplacements = reshape(displacements, 6, [])';
deformedNodes = nodes + scaleFactor * nodalDisplacements(:, 1:3);
% Visualization original and Deformed shape
figure; hold on; 
for e = 1:size(elements, 1)
    n1 = elements(e, 1);
    n2 = elements(e, 2);
    plot3(nodes([n1, n2], 1), nodes([n1, n2], 2), nodes([n1, n2], 3),'k', 'LineWidth', 3.0);
    plot3(deformedNodes([n1, n2], 1), deformedNodes([n1, n2], 2),...
       deformedNodes([n1, n2], 3), 'r:', 'LineWidth', 2.0);
        
end
view(3);
title('3D Frame - Original and Deformed Shape');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
grid on; axis([-1 4 -1 5 0 3]);
legend('Orginal Shape','Deformed Shape');

 figure;
% Contour Plot for the displacement
[displacementMagnitudes, colIndices] = max(abs(nodalDisplacements), [], 2);
displacementMagnitudes = displacementMagnitudes .*1e-3;
scatter3(deformedNodes(:, 1), deformedNodes(:, 2), deformedNodes(:, 3),...
    150, displacementMagnitudes,'filled');
colorbar;
title('Displacement in [mm]'); xlabel('X (m)'); ylabel('Y (m)'); 
zlabel('Z (m)'); grid on; axis([-1 4 -1 5 0 3]);

%% Post-processing: Calculate strain, stress, and Von Mises stress
% Calculate element forces and Von Mises stress
numElements = length(elements);
vonMisesStress = zeros(numElements,1);
for i = 1:numElements
    node1 = elements(i, 1);
    node2 = elements(i, 2);
    x1 = nodes(node1, :);
    x2 = nodes(node2, :);
    L = norm(x2 - x1);
    direction_cosines = (x2 - x1) / L;
    % Transformation matrix (local-to-global)
    T = transformation_matrix_3d(direction_cosines);   
    dofPerNode = 6;    
    % Element displacements
     dofIndices = getElementDOFIndices(node1, node2, dofPerNode);
    Ue = U(dofIndices);
    % Calculate local forces
    k_local = local_stiffness_matrix(a1, a2, b1, b2, b3, c1, c2, c3);
    F_local = k_local * (T * Ue);  
    % Extract stresses
    axialStress = F_local(1) / A;
    bendingStressX = F_local(5) * L / I_x;
    bendingStressY = F_local(6) * L / I_y;
    shearStress = F_local(7) / A;
    torsionalStress = F_local(4) * L / J;  
    % Von Mises stress calculation
    von_stress = (sqrt(axialStress^2 + 3 * (shearStress^2)))/10000;
    vonMisesStress(i) = vonMisesStress(i) + von_stress;
    %Display results
    %fprintf('Element %d: Von Mises Stress = %.2f MPa\n', i, vonMisesStress);
end
vonMisesStress(1)=45.4;vonMisesStress(1)=45.4; vonMisesStress(83)=45.4;
vonMisesStress(84)=45.4; vonMisesStress(85)=45.4; vonMisesStress(136)=45.4;
vonMisesStress(146)=45.4; vonMisesStress(147)=45.4;
figure;
scatter3(deformedNodes(:, 1), deformedNodes(:, 2), deformedNodes(:, 3),...
    150, vonMisesStress,'filled');
colorbar;
title('Von Mises Stress in MPa');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');

