function addpaths()
    % Get the full path of the current script
    scriptFullPath = mfilename('fullpath');
    [scriptDir, ~, ~] = fileparts(scriptFullPath);

    % Define the paths to all the files
    files = {
        'process_vertices.m'
        'load_nifti.m'
        'ConvertTrk2Cell.m'
        'generate_voxel_data.m'
        'initialize_grid.m'
        'save_voxel_data_as_nifti.m'
        'assign_potential_outside_points.m'
        'apply_imclose_parallel.m'
        'process_voxel_data.m'
        'create_data_structure.m'
        'ODESolve.m'
        'Laplace.Solver.m'
        'potgrad.m'
        'ComputePointsonSphere'
     
    };

    % Add the directory of each file to the MATLAB path
    for i = 1:length(files)
        addpath(scriptDir);
    end
end
