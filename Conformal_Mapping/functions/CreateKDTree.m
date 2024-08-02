potVector=ones(numOfVoxels, 4);
count=1;
%% Create Pot Vector
numStreamLines=length(streamlines_uniq_resampled);
NewStreamLinePoints=zeros(101*numStreamLines, 3);

PotVector=zeros(101*numStreamLines,1);

k_start=1;
for i=1:numStreamLines
     k_end=k_start+100;
     a=streamlines_uniq_resampled{i};

      if size(a, 1) == 101 
        PotVector(k_start:k_end) = 1.01:-0.01:0.01;
        NewStreamLinePoints(k_start:k_end, :) = a;
    else
        new_size = size(a, 1);
        PotVector(k_start:k_start + new_size - 1) = linspace(1.01, 0.01, new_size);
        NewStreamLinePoints(k_start:k_start + new_size - 1, :) = a;
        k_end = k_start + new_size - 1; 
    end  

     k_start = k_end+1;
end

% get rid of any pre-allocated extra space in NewStreamLinePoints and PotVector
NewStreamLinePoints = NewStreamLinePoints(1:k_end, :);
PotVector = PotVector(1:k_end, :);


NewStreamLines_vector=[NewStreamLinePoints PotVector];
unique_newStreamlines=unique(NewStreamLines_vector, 'rows');
Y_temp=NewStreamLines_vector(:,1:3);
Mdl_PotVector = KDTreeSearcher(Y_temp);

disp('Built KD-Tree - PotVector');

% Build theta_phi vector
thetaVector_unique=unique(thetaVector, 'rows');
X_temp=thetaVector_unique(:,1:3);
Mdl_ThetaVector = KDTreeSearcher(X_temp);
disp('Built KD-Tree - ThetaVector');


output_dir = '/Users/maysneiroukh/Documents/MATLAB/Conformal_Mapping/functions/';
mdl_theta_vector_file = strcat(output_dir, 'Mdl_ThetaVector.mat');
mdl_pot_vector_file = strcat(output_dir, 'Mdl_PotVector.mat');
results_models=strcat(output_dir, 'Models.mat');

%save(mdl_theta_vector_file);
%save(mdl_pot_vector_file);

save(results_models);