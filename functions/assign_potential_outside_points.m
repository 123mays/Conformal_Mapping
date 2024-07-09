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