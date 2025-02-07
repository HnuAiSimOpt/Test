%初始化
mesh_FileRoot = [job_srcdir,'/Input_Mesh'];
mesh_FileType = 'gmsh';

mesh_FileName = [];
mesh_FilePath = [];

mesh_FilePath = [mesh_FileRoot,'/',mesh_FileName];

if ~exist(mesh_FilePath,'file')
    error('ErrorUserInput:meshFileNotFound',...
        'Unable to find mesh file.\n')
end

