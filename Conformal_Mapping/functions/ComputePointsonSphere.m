sphere1 = [shapeCenter(1) shapeCenter(2) shapeCenter(3) 5.0];
streamlines_uniq = cell(length(streamlines), 1);
endPoints_strLines = [];

for i = 1:stepSizeforStreamLines:length(streamlines)
    streamLines_i = streamlines{i};
    shapeCenter_rep = repmat(shapeCenter, length(streamLines_i), 1);
    distvec = euclidean(streamLines_i, shapeCenter_rep);
    distvec_diag = diag(distvec);
    dist_idx = find(distvec_diag > 5);
    
    % Ensure end_idx does not exceed the length of streamLines_i
    if ~isempty(dist_idx)
        end_idx = dist_idx(end);
    else
        end_idx = length(streamLines_i);
    end
    
    % Check if end_idx is within valid range
    if end_idx <= length(streamLines_i)
        a_start = streamLines_i(end_idx, :);
        
        % Handle case where end_idx is the last point
        if end_idx < length(streamLines_i)
            a_end = streamLines_i(end_idx + 1, :);
        else
            % Duplicate the last point for a_end if at the end
            a_end = a_start;
        end

        diff_dx = a_end - a_start;
        line = [a_start(1) a_start(2) a_start(3) diff_dx(1) diff_dx(2) diff_dx(3)];
        
        pt = intersectLineSphere(line, sphere1);
        streamLines_uniq = [streamLines_i((1:end_idx), :); pt(1, :)];
        endPoints_strLines = [endPoints_strLines; pt(1, :)];
        streamlines_uniq{i} = streamLines_uniq;
    else
        continue;
    end
end
%% Euclidean function 
function [euclid3D] = euclidean(p, c)
    % Error check
    [rp, cp] = size(p);
    [rc, cc] = size(c);
    if rp ~= rc
        usage();
        error('Point arrays must be of equal size');
    end
    if cc ~= 3 || cp ~= 3
        usage();
        error('Must be 3D point sets');
    end

    % Calculate 3D distance between two 3D point sets
    euclid3D = zeros(size(p, 1), 1);
    for i = 1:size(p, 1)
        euclid3D(i, :) = sqrt((c(i, 1) - p(i, 1))^2 + (c(i, 2) - p(i, 2))^2 + (c(i, 3) - p(i, 3))^2);
    end

    clearvars -except 'euclid3D' 'p' 'c';
end
