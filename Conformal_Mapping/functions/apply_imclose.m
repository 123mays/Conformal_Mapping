%This function applies a morphological closing operation to each 2D slice of a 3D NIfTI image
function apply_imclose(niftiImage)
    se = strel('sphere', 2);
    [rows, cols, slices] = size(niftiImage);

    image_data = zeros(rows, cols, slices, 'like', niftiImage);

    parfor k = 1:slices
        % Pad the slice
        padded_slice = padarray(niftiImage(:, :, k), [2 2], 'replicate');
        % Apply imclose
        closed_slice = imclose(padded_slice, se);
        % Crop back to original size
        image_data(:, :, k) = closed_slice(3:end-2, 3:end-2);
    end
end
