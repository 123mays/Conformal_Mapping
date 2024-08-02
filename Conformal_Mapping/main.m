addpath(pwd);
addpath('./Conformal_Mapping/functions/');
clc;

Padding = [20, 20, 20];
potential_multiplier = 1;
length_threshold_max = 230; 
length_threshold_min = 35;
step_size = 500;
shapeCenter_woPad = [50, 50, 50];
isovalue = 0.5;     
eps=1e-4; % Accuracy of the computation lower it for increased accuracy = lowered from 1e-1 for more accuracy
stepSizeforStreamLines = 20; % Density of streamlines

% Paths to files
trkPath = '/Users/maysneiroukh/Documents/MATLAB/WhiteMatterClustering-2024/6616456/100k_whole_brain_tracts.trk';
niftiPath = '/Users/maysneiroukh/Documents/MATLAB/WhiteMatterClustering-2024/6616456/nodif_brain_mask.nii';

[image_data, voxDim, size_img] = load_nifti(niftiPath);


% binarize the image
idx_a = find(image_data > 0);
[I, J, K] = ind2sub(size_img, idx_a);
disp('Vertices');
vertices=[I, J, K];

apply_imclose(image_data);

% Initialize grid and padding parameters
[gridSize_wPadding, sx, sy, sz] = initialize_grid(size(image_data), Padding);

% Process vertices with padding
points = process_vertices(vertices, Padding);

voxData = create_data_structure(points, sx, sy, sz, potential_multiplier);

process_voxel_data; 

% Update shapeCenter with padding
shapeCenter = shapeCenter_woPad + Padding / 2;


% LaplaceSolver function
voxData = LaplaceSolver(voxData, shapeCenter, gridSize_wPadding, eps);

% ODE function
[streamlines] = ODESolve(voxData, boundVox, count_BoundVox, stepSizeforStreamLines, shapeCenter);
disp('done');

ComputePointsonSphere;

% Resampling streamlines to be in the (0,1) range and plotting the streamlines
ResampleStreamlines;

thetaVector = ComputeTheta(streamlines, stepSizeforStreamLines, shapeCenter);

CreateKDTree;

disp('Saved the KD Tree models')

MapTracks_indv_subj;

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


disp('Processing completed successfully');

