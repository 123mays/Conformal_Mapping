function Parallelized_MapTracks_indv_subj(data_dir, grp, part_num)
    
    addpaths; 

    output_dir = '/Users/maysneiroukh/Documents/MATLAB/Conformal_Mapping/functions/';

    sample_size = 1;
    streamlinesFile = strcat(output_dir, 'streamlines.mat');
    Mdl_file = strcat(output_dir, 'Models.mat');

    % Load required files
    load(streamlinesFile, 'streamlines_uniq_resampled'); 
    load(Mdl_file, 'Mdl_ThetaVector', 'thetaVector_unique', 'Mdl_PotVector', 'NewStreamLines_vector');
    disp('Loaded streamlines');

    if ~exist(output_dir, 'dir')
        mkdir(output_dir)
    end

    trk_cell_file = strcat(output_dir, 'track_cell_result.mat');
    load(trk_cell_file, 'track_cell_result');  
    combine_tracks_cell = track_cell_result;

    % Initialize the Mapped_tracks cell array
    Mapped_tracks = cell(length(combine_tracks_cell), 1);

    parfor i = 1:sample_size:length(combine_tracks_cell)
        a = combine_tracks_cell{i};
        mapped_tracks_i = zeros(length(a), 3); 

        for j = 1:length(a)
            coordinate = a(j, :);
            [theta_interp, phi_interp] = interpolate_Weighted_matlab(Mdl_ThetaVector, coordinate, thetaVector_unique);
            [pot_interp] = interpolate_pot_Weighted_matlab(Mdl_PotVector, coordinate, NewStreamLines_vector);
            mapped_tracks_i(j, :) = [theta_interp, phi_interp, pot_interp];
        end

        Mapped_tracks{i} = mapped_tracks_i;
    end

    save(strcat(output_dir, 'Mapped_tracks.mat'), 'Mapped_tracks');
end
