% main.m

addpath(pwd);

% Parameters
Padding = [20, 20, 20];
potential_multiplier = 1;
length_threshold_max = 230; % Example value, adjust as needed
length_threshold_min = 35; 
step_size = 500; 
shapeCenter_woPad = [50, 50, 50]; %couldn't find the file to determine the actual value
isovalue = 0.5; % Isovalue for surface extraction

% Paths to files
trkPath = '/Users/maysneiroukh/Documents/MATLAB/WhiteMatterClustering-2024/6616456/100k_whole_brain_tracts.trk';
niftiPath = '/Users/maysneiroukh/Documents/MATLAB/WhiteMatterClustering-2024/6616456/b0_LAI.nii.gz';
outputPath = 'binarized_image_with_boundaries.nii';


% Load and binarize Nifti file
[binary_image, voxDim] = load_and_binarize_nifti(niftiPath, 0.5);

% Extract the surface
[faces, vertices] = isosurface(binary_image, isovalue);

% Initialize grid and padding parameters
[gridSize_wPadding, sx, sy, sz] = initialize_grid(size(binary_image), Padding);

% Process vertices with padding
points = process_vertices(vertices, Padding);

% Create Data Structure
voxData = create_data_structure(points, sx, sy, sz, potential_multiplier);

% Mark Boundary Voxels
[voxData, boundVox] = mark_boundary_voxels(voxData, sx, sy, sz, potential_multiplier);

% Update ShapeCenter
shapeCenter = shapeCenter_woPad + Padding / 2;

% Assign potential to outside points
voxData = assign_potential_outside_points(voxData, sx, sy, sz, potential_multiplier);

% Save the binarized image back to a Nifti file
save_binarized_image(niftiPath, binary_image, outputPath);

% Save the voxel data with boundaries
save_voxel_data_as_nifti(voxData, 'voxel_data_with_boundaries.nii');

% Load Track File
[header, tracks] = trk_read(trkPath);
trk_length_vector = trk_length(tracks);
filtered_tracks_idx = find(trk_length_vector < length_threshold_max & trk_length_vector > length_threshold_min);
tracks_filtered = tracks(filtered_tracks_idx);

% Convert tracks to cell array
track_cell_result = ConvertTrk2Cell(tracks_filtered, Padding, voxDim);

% Plot Figure
figure();
hold on;
grid on;
plot3(boundVox(:, 1), boundVox(:, 2), boundVox(:, 3), '.');
plot3(shapeCenter(1), shapeCenter(2), shapeCenter(3), 'r*');
for k = 1:step_size:length(track_cell_result)
    a = track_cell_result{k};
    plot3(a(:, 1), a(:, 2), a(:, 3));
end

view([90, 0, 0]);
xlabel('x');
zlabel('z');
ylabel('y');

% Save figures in the current directory
saveas(gcf, fullfile(pwd, 'trk_QC.png'), 'png');
saveas(gcf, fullfile(pwd, 'trk_QC.fig'));

Image = fullfile(pwd, 'trk_QC.png');

disp('Processing completed successfully');

%Functions 


function [binary_image, voxDim] = load_and_binarize_nifti(niftiPath, threshold)
    nii = load_nii(niftiPath);
    image_data = nii.img;
    binary_image = image_data > threshold;
    voxDim = nii.hdr.dime.pixdim(2:4);
end

function [gridSize_wPadding, sx, sy, sz] = initialize_grid(gridSize, Padding)
    gridSize_wPadding = gridSize + Padding;
    sx = gridSize_wPadding(1); 
    sy = gridSize_wPadding(2); 
    sz = gridSize_wPadding(3);
end

function points = process_vertices(vertices, Padding)
    points = round(vertices + Padding / 2); % Ensure points are integers
end

function voxData = create_data_structure(points, sx, sy, sz, potential_multiplier)
    TotalNumberOfPoints = size(points, 1);
    voxData = ones(sx, sy, sz, 5);
    for i = 1:TotalNumberOfPoints
        x = points(i, 1); 
        y = points(i, 2); 
        z = points(i, 3);
        if x > 0 && y > 0 && z > 0 && x <= sx && y <= sy && z <= sz
            voxData(x, y, z, 1) = 2;
            voxData(x, y, z, 2) = 10;
            voxData(x, y, z, 3) = rand() * potential_multiplier;
        end
    end
end

function [voxData, boundVox] = mark_boundary_voxels(voxData, sx, sy, sz, potential_multiplier)
    temp_flag_val = 10;
    voxData = MarkBoundaryVer4(voxData, sx, sy, sz, temp_flag_val);
    boundVox = [];
    for i = 1:sx
        for j = 1:sy
            for k = 1:sz
                if voxData(i, j, k, 2) == 100
                    voxData(i, j, k, 1) = 3;
                    voxData(i, j, k, 2) = 10;
                    voxData(i, j, k, 3) = 1.0 * potential_multiplier;
                    boundVox = [boundVox; [i, j, k]];
                end
            end
        end
    end

    flags = [3, 4];
    multipliers = [1.5, 2.0];
    for f = 1:length(flags)
        flag = flags(f);
        voxData = MarkBoundaryVer4(voxData, sx, sy, sz, temp_flag_val);
        for i = 1:sx
            for j = 1:sy
                for k = 1:sz
                    if voxData(i, j, k, 2) == 100
                        voxData(i, j, k, 1) = flag + 1;
                        voxData(i, j, k, 2) = 10;
                        voxData(i, j, k, 3) = multipliers(f) * potential_multiplier;
                    end
                end
            end
        end
    end
end

function voxData = assign_potential_outside_points(voxData, sx, sy, sz, potential_multiplier)
    for i = 1:sx
        for j = 1:sy
            for k = 1:sz
                if voxData(i, j, k, 1) == 1
                    voxData(i, j, k, 3) = 5 * potential_multiplier;
                end
            end
        end
    end
end

function save_binarized_image(niftiPath, binary_image, outputFileName)
    nii = load_nii(niftiPath);
    nii.img = binary_image;
    save_nii(nii, outputFileName);
end

function save_voxel_data_as_nifti(voxData, outputFileName)
    % Create a new NIfTI structure for the voxel data
    nii = make_nii(voxData(:,:,:,1));
    % Save the NIfTI file
    save_nii(nii, outputFileName);
end

function voxData = MarkBoundaryVer4(voxData, sx, sy, sz, temp_flag_val)
    mask = (voxData(:,:,:,2) == temp_flag_val);
    for i = 1:sx
        for j = 1:sy
            k_vals = find(mask(i,j,:));
            if ~isempty(k_vals)
                Lia = false(sz, 1);
                Lia(k_vals) = true;
                boundary_up = find(diff(Lia) == 1) + 1;
                boundary_down = find(diff(Lia) == -1);
                voxData(i,j,boundary_up,2) = 100;
                voxData(i,j,boundary_down,2) = 100;
            end
        end
    end
    for i = 1:sx
        for k = 1:sz
            j_vals = find(mask(i,:,k));
            if ~isempty(j_vals)
                Lia = false(sy, 1);
                Lia(j_vals) = true;
                boundary_up = find(diff(Lia) == 1) + 1;
                boundary_down = find(diff(Lia) == -1);
                voxData(i,boundary_up,k,2) = 100;
                voxData(i,boundary_down,k,2) = 100;
            end
        end
    end
    for j = 1:sy
        for k = 1:sz
            i_vals = find(mask(:,j,k));
            if ~isempty(i_vals)
                Lia = false(sx, 1);
                Lia(i_vals) = true;
                boundary_up = find(diff(Lia) == 1) + 1;
                boundary_down = find(diff(Lia) == -1);
                voxData(boundary_up,j,k,2) = 100;
                voxData(boundary_down,j,k,2) = 100;
            end
        end
    end
end

function track_cell_result = ConvertTrk2Cell(tracks, Padding, voxDim)
    tracks_cell = cell(length(tracks), 1);
    for i = 1:1:length(tracks)
        track_i = tracks(i);
        % Pad and convert to voxel coordinates
        b = zeros(track_i.nPoints, 3);
        for j = 1:track_i.nPoints
            b(j, :) = track_i.matrix(j, :) ./ voxDim + Padding / 2;
        end
        tracks_cell{i} = b;
    end
    track_cell_result = tracks_cell;
end
