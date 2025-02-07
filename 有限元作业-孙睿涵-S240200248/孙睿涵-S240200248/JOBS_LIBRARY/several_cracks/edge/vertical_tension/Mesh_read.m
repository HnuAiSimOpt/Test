cBCNod = [];
cBCCrd = [];

switch mesh_FileType  
    case 'gmsh'  
        [mNdCrd,mLNodS,vElPhz,cBCNod] = ...
            LoadMesh_gmsh(mesh_FilePath,mesh_ElemType);
    otherwise
        error('Unknown mesh file type: "',mesh_FileType,'"')
end
if 0  
    warning('overriding boundary nodes');
    cBCNod = cell(8,1);
    
    L = max(mNdCrd(:,1)) - min(mNdCrd(:,1));
    H = max(mNdCrd(:,2)) - min(mNdCrd(:,2)); tol=max(L,H)*1e-12;
    
    cBCNod{1} = find( abs(mNdCrd(:,2)-min(mNdCrd(:,2))) < tol );
    cBCNod{2} = find( abs(mNdCrd(:,1)-max(mNdCrd(:,1))) < tol );
    cBCNod{3} = find( abs(mNdCrd(:,2)-max(mNdCrd(:,2))) < tol );
    cBCNod{4} = find( abs(mNdCrd(:,1)-min(mNdCrd(:,1))) < tol );
    
    cBCNod{5} = cBCNod{1}( abs(mNdCrd(cBCNod{1},1)-min(mNdCrd(cBCNod{1},1))) < tol );
    cBCNod{6} = cBCNod{1}( abs(mNdCrd(cBCNod{1},1)-max(mNdCrd(cBCNod{1},1))) < tol );
    cBCNod{7} = cBCNod{3}( abs(mNdCrd(cBCNod{3},1)-max(mNdCrd(cBCNod{3},1))) < tol );
    cBCNod{8} = cBCNod{3}( abs(mNdCrd(cBCNod{3},1)-min(mNdCrd(cBCNod{3},1))) < tol );
    
end
if 0
    warning('smoothing mesh');
    mNdCrd = MeshSmooth(mNdCrd,mLNodS,[1,2;2,3;3,1]);
end