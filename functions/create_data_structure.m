function voxData = create_data_structure(points, sx, sy, sz, potential_multiplier)
    TotalNumberOfPoints = size(points, 1);
    voxData = ones(sx, sy, sz, 5);
    for i = 1:TotalNumberOfPoints
        x = points(i, 1) ;
        y = points(i, 2) ;
        z = points(i, 3);
        if x > 0 && y > 0 && z > 0 && x <= sx && y <= sy && z <= sz
            voxData(x, y, z, 1) = 2;
            voxData(x, y, z, 2) = 10;
            voxData(x, y, z, 3) = rand() * potential_multiplier;
        end
    end
end