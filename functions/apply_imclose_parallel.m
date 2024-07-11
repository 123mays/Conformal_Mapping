function voxData = apply_imclose_parallel(voxData, sx, sy, sz)
    % Apply imclose operation in parallel to each 2D slice along the third dimension
    se = strel('sphere', 2); % Structuring element
    mask = (voxData(:,:,:,1) > 1); % Assuming brain mask has values > 1
    
    % Initialize a new mask array to hold the results
    new_mask = false(size(mask));
    
    % Parallel processing of imclose on 2D slices
    parfor k = 1:sz
        new_mask(:,:,k) = imclose(mask(:,:,k), se);
    end
    
    % Update the voxData array with the new mask
    for k = 1:sz
        voxData(:,:,k,1) = voxData(:,:,k,1) .* new_mask(:,:,k);
    end
    size(new_mask)
end
