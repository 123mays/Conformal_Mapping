list_pts = []
for i=1:1:124
    for j=1:1:124
        for k=1:1:92
            if voxData(i,j,k, 3) > 0.0 && voxData(i,j,k,3) < 0.8
                   list_pts=[list_pts, [i,j,k]];
            end
           
        end
    end
end

plot3(i,j,k, '.')