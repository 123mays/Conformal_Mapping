%function [voxData, boundVox, count_BoundVox] = process_voxel_data2(voxData, sx, sy, sz, potential_multiplier, gridSize_wPadding)
%% Mark Boundary Voxels
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz, temp_flag_val);
count_BoundVox=0;
boundVox=[];
for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                 voxData(i,j,k,1) = 3;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 1.0*potential_multiplier;
                 count_BoundVox = count_BoundVox+1;
                 boundVox=[boundVox; [i,j,k]];
            end
        end
    end
end
%%% Changing ShapeCenter here 
% shapeCenter = shapeCenter_woPad + Padding/2;

% % For the moment not layering the potentials 
flag = 3;
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz, temp_flag_val);

for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                voxData(i,j,k,1) = 4;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 1.5*potential_multiplier;
            end
        end
    end
end


flag = 4;
temp_flag_val=10;
voxData = MarkBoundaryVer4(voxData, sx, sy,sz,temp_flag_val );
test3=[];
for i = 1:gridSize_wPadding(1)
    for j = 1: gridSize_wPadding(2)
        for k = 1: gridSize_wPadding(3)
            if (voxData(i,j,k,2) == 100)
                voxData(i,j,k,1) = 5;
                voxData(i,j,k,2) = 10;
                voxData(i,j,k,3) = 2.0*potential_multiplier;
                test3=[test3; [i,j,k]];
            end
        end
    end
end

% Assign potential to outSidePoints

for i=1:sx
    for j =1:sy
        for k=1:sz
            if (voxData(i,j,k, 1) ==1)
                voxData(i,j,k,3)=5*potential_multiplier;
            end
        end
    end
end