addpath(pwd);
addpaths();
addpath('./functions');
clc;

% Parameters
Padding = [20, 20, 20];
potential_multiplier = 1;
length_threshold_max = 230; % Example value, adjust as needed
length_threshold_min = 35;
step_size = 500;
shapeCenter_woPad = [50, 50, 50];
isovalue = 0.5;     % Isovalue for surface extraction
eps=1e-4; % Accuracy of the computation lower it for increased accuracy = lowered from 1e-1 for more accuracy
stepSizeforStreamLines = 20; % Density of streamlines; increase the number for faster computations

% Paths to files
trkPath = '/raid/Vikash/Tools/Mays/Conformal_Mapping/functions/WhiteMatterClustering-2024/6616456/100k_whole_brain_tracts.trk';
niftiPath = '/raid/Vikash/Tools/Mays/Conformal_Mapping/functions/WhiteMatterClustering-2024/6616456/nodif_brain_mask.nii';

% Load Nifti file without binarizingendPoints_strLines
[image_data, voxDim, size_img] = load_nifti(niftiPath);


% binarize the image
idx_a = find(image_data > 0);
[I, J, K] = ind2sub(size_img, idx_a);
disp('Vertices');
vertices=[I, J, K];


% Extract the surface
%[faces, vertices] = isosurface(image_data, isovalue);

% Initialize grid and padding parameters
[gridSize_wPadding, sx, sy, sz] = initialize_grid(size(image_data), Padding);

% Process vertices with padding
points = process_vertices(vertices, Padding);

% Create Data Structure
voxData = create_data_structure(points, sx, sy, sz, potential_multiplier);

% Apply imclose to fill the brain shape in parallel
voxData = apply_imclose_parallel(voxData, sx, sy, sz);

% Mark Boundary Voxels
%[voxData, boundVox, count_BoundVox] = process_voxel_data2(voxData, sx, sy, sz, potential_multiplier, gridSize_wPadding);
process_voxel_data2

% Update ShapeCenter
shapeCenter = shapeCenter_woPad + Padding / 2;

% Assign potential to outside points
voxData = assign_potential_outside_points(voxData, sx, sy, sz, potential_multiplier);

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
% saveas(gcf, fullfile(pwd, 'trk_QC.png'), 'png');
% saveas(gcf, fullfile(pwd, 'trk_QC.fig'));

Image = fullfile(pwd, 'trk_QC.png');

disp('Processing completed successfully');

% Call the LaplaceSolver function
voxData = LaplaceSolver(voxData, shapeCenter, gridSize_wPadding, eps);

% Apply ODESolver function
%[streamlines] = ODESolver(voxData, boundVox, count_BoundVox, stepSizeforStreamLines, shapeCenter);

%ComputePointsonSphere;

% Create 2D Contour Map Visualization
create_2d_contour_map(voxData, sx, sy, sz);

function create_2d_contour_map(voxData, sx, sy, sz)
    % Choose the plane to slice (for example, the middle slice in z-direction)
    slice_index = round(sz / 2);
    
    % Extract the potential values from the processed voxel data
    potential_slice = squeeze(voxData(:, :, slice_index, 3));

    % Define the contour levels
    contour_levels = linspace(min(potential_slice(:)), max(potential_slice(:)), 20);

    % Create a figure for the 2D contour map
    figure;
    hold on;

    % Plot the filled contour map
    contourf(potential_slice, contour_levels, 'LineColor', 'none');

    % Add colorbar and labels
    colorbar;
    colormap(jet);
    caxis([min(contour_levels) max(contour_levels)]);
    title('2D Contour Map of Potential Layers');
    xlabel('X');
    ylabel('Y');
    axis equal;
    hold off;
end

function [streamlines] = ODESolver(voxData, boundVox, sizeBoundVox, stepSizeforStreamLines, shapeCenter)
    options = odeset('RelTol', 1e-3, 'AbsTol', [1e-6 1e-6 1e-6]);
    streamlines = cell(sizeBoundVox, 1);

    for i = 1:stepSizeforStreamLines:sizeBoundVox
        vec = boundVox(i, :);
        tspan = [0 100];
        [t, streamvec] = ode113(@(t, y) potgrad(t, y, voxData, shapeCenter), tspan, vec, options);
        streamlines{i} = streamvec;
    end
end

function [voxData, boundVox, count_BoundVox] = process_voxel_data(voxData, sx, sy, sz, potential_multiplier)
    temp_flag_val = 10;

    % Helper function to mark boundaries
    function voxData = mark_boundaries(voxData, sx, sy, sz, temp_flag_val)
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

    % Initial boundary marking and processing
    voxData = mark_boundaries(voxData, sx, sy, sz, temp_flag_val);
    count_BoundVox = 0;
    boundVox = [];
    potential_val = 1.0;

    for layer = 1:10  % Increase to 10 layers for more detail
        for i = 1:sx
            for j = 1:sy
                for k = 1:sz
                    if voxData(i, j, k, 2) == 100
                        voxData(i, j, k, 1) = 3;
                        voxData(i, j, k, 2) = 10;
                        voxData(i, j, k, 3) = potential_val * potential_multiplier;
                        count_BoundVox = count_BoundVox + 1;
                        boundVox = [boundVox; [i, j, k]];
                    end
                end
            end
        end
        % Increase the potential for the next layer
        potential_val = potential_val + 0.1;  % Smaller increments for more layers
        voxData = mark_boundaries(voxData, sx, sy, sz, temp_flag_val);
    end
end
