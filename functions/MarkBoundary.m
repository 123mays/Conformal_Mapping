function voxData = MarkBoundary(voxData, sx, sy, sz, temp_flag)
% Mark boundaries in the x-direction
for i = 1:sx
    for j = 1:sy
        fill_vals = find(voxData(i, j, :, 2) == temp_flag);
        if ~isempty(fill_vals)
            Lia = ismember(1:sz, fill_vals);
            boundary_indices = find(diff(Lia));
            voxData(i, j, boundary_indices, 2) = 100;
        end
    end
end

% Mark boundaries in the y-direction
for i = 1:sx
    for k = 1:sz
        fill_vals = find(voxData(i, :, k, 2) == temp_flag);
        if ~isempty(fill_vals)
            Lia = ismember(1:sy, fill_vals);
            boundary_indices = find(diff(Lia));
            voxData(i, boundary_indices, k, 2) = 100;
        end
    end
end

% Mark boundaries in the z-direction
for j = 1:sy
    for k = 1:sz
        fill_vals = find(voxData(:, j, k, 2) == temp_flag);
        if ~isempty(fill_vals)
            Lia = ismember(1:sx, fill_vals);
            boundary_indices = find(diff(Lia));
            voxData(boundary_indices, j, k, 2) = 100;
        end
    end
end
end
