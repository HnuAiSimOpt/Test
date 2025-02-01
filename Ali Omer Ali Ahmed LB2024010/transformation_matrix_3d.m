% Transformation matrix for 3D frame
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