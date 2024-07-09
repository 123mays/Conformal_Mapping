function voxData = LaplaceSolver(voxData, shapeCenter, gridSize_wPadding, eps)
    % Initialize shape center point
    voxData(shapeCenter(1), shapeCenter(2), shapeCenter(3), 3) = 0;
    voxData(shapeCenter(1), shapeCenter(2), shapeCenter(3), 2) = 1;
    voxData(shapeCenter(1), shapeCenter(2), shapeCenter(3), 1) = 10;

    % Identify the count of voxels with a specific value (2)
    mask = (voxData(:,:,:,1) == 2);
    count = nnz(mask);

    % Preallocate potential vector and inner voxel indices
    potvec = zeros(count, 1);
    innerVox = zeros(count, 3);
    
    % Fill potential vector and inner voxel indices
    idx = 1;
    for i = 1:gridSize_wPadding(1)
        for j = 1:gridSize_wPadding(2)
            for k = 1:gridSize_wPadding(3)
                if voxData(i, j, k, 1) == 2
                    potvec(idx) = voxData(i, j, k, 3);
                    innerVox(idx, :) = [i, j, k];
                    idx = idx + 1;
                end
            end
        end
    end

    % Iterative solver
    maxError = 100;
    count = 0;
    prepotVec = potvec;
    while maxError > eps
        for i = 1:size(innerVox, 1)
            x = innerVox(i, 1);
            y = innerVox(i, 2);
            z = innerVox(i, 3);
            temp = (voxData(x-1, y, z, 3) + voxData(x+1, y, z, 3) + ...
                    voxData(x, y-1, z, 3) + voxData(x, y+1, z, 3) + ...
                    voxData(x, y, z-1, 3) + voxData(x, y, z+1, 3)) / 6;
            potvec(i) = temp;
            voxData(x, y, z, 3) = temp;
        end
        diff = prepotVec - potvec;
        maxError = norm(diff, 2);
        disp(['Iteration = ' num2str(count)]);
        disp(['Error = ' num2str(maxError)]);
        count = count + 1;
        prepotVec = potvec;
    end
end
