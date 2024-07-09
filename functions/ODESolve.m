function [streamlines] = ODESolve(voxData, boundVox, sizeBoundVox, stepSizeforStreamLines, shapeCenter)
    options = odeset('RelTol', 1e-3, 'AbsTol', [1e-6 1e-6 1e-6]);
    streamlines = cell(sizeBoundVox, 1);
    sphere1 = [shapeCenter(1) shapeCenter(2) shapeCenter(3) 5.0];

    for i = 1:stepSizeforStreamLines:sizeBoundVox
        vec = boundVox(i, :);
        tspan = [0 100];
        [t, streamvec] = ode113(@(t, y) potgrad(t, y, voxData, shapeCenter), tspan, vec, options);
        streamlines{i} = streamvec;
    end
end

addpath('./functions/potgrad.m');