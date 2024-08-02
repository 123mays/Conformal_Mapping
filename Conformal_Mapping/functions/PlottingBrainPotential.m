potential_ranges = [0.85, 0.85; 0.85, 0.9; 0.9, 0.999; 0.999, 1.0; 1.0, 1.5; 1.5, 2.0; 2.0, 2.5];
% potential_ranges = [0.7, 0.8; 0.995, 0.9995; 0.9999, 1.0; 1.0, 1.5; 1.5, 2.0; 2.0, 2.5];
colors = ['b', 'g', 'r', 'c', 'm', 'y', 'k'];

list_pts = [];
count = 1;

figure;
hold on;

for r = 1:size(potential_ranges, 1)
    lower_bound = potential_ranges(r, 1);
    upper_bound = potential_ranges(r, 2);
    count = 1;
    vals = zeros(sx*sy*sz, 3);
    
    for i = 1:sx
        for j = 1:sy/2
            for k = 1:sz/2
                if voxData(i, j, k, 3) > lower_bound && voxData(i, j, k, 3) <= upper_bound
                    vals(count, :) = [i, j, k];
                    count = count + 1;
                end
            end
        end
    end
    
    vals(count:end, :) = [];
    plot3(vals(:, 1), vals(:, 2), vals(:, 3), [colors(r), '.']);
end

hold off;
