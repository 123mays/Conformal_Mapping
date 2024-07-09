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

    for layer = 1:5  % Increase to 10 layers for more detail
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
        potential_val = potential_val + 0.7;  % Smaller increments for more layers
        voxData = mark_boundaries(voxData, sx, sy, sz, temp_flag_val);
    end
end
