list_pts = [];
count = 1;
vals = zeros(sx*sy*sz,3);
for i=1:1:sx
    for j=1:1:sy
        for k=1:1:sz
            
            if voxData(i, j, k, 3) > 0.8 && voxData(i, j, k, 3) < 0.9
               vals(count, :) = [i, j, k];
               %list_pts = [list_pts;[i,j,k]];
               count = count + 1;
            end
        end
    end
end
vals(count:sx*sy*sz,:)=[];
hold on;
plot3(vals(:,1), vals(:,2), vals(:,3), 'r.');