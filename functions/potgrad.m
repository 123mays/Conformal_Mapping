function dvecdt = potgrad(t, y, voxData, shapeCenter)
    y_round = round(y);
    xVal = y_round(1);
    yVal = y_round(2);
    zVal = y_round(3);
    
    [sx, sy, sz, ~] = size(voxData);
    
    dist = norm(([xVal, yVal, zVal] - shapeCenter), 2);
    if dist < 3
        dvecdt = zeros(3, 1);
    else
        count = 1;
        lhsmat = ones(27, 8);
        rhsVec = ones(27, 1);
        for i = -1:1
            for j = -1:1
                for k = -1:1
                    if (xVal + i > 0) && (xVal + i <= sx) && ...
                       (yVal + j > 0) && (yVal + j <= sy) && ...
                       (zVal + k > 0) && (zVal + k <= sz)
                        rhsVec(count, 1) = voxData(xVal + i, yVal + j, zVal + k, 3);
                        lhsmat(count, :) = [(xVal + i) * (yVal + j) * (zVal + k), (xVal + i) * (yVal + j), (yVal + j) * (zVal + k), ...
                                            (zVal + k) * (xVal + i), (xVal + i), (yVal + j), (zVal + k), 1];
                    else
                        rhsVec(count, 1) = 0; % or some other appropriate value
                        lhsmat(count, :) = [0, 0, 0, 0, 0, 0, 0, 1]; % Ensure consistency
                    end
                    count = count + 1;
                end
            end
        end
        
        paramVec = pinv(lhsmat) * rhsVec;
        
        potgradVec(1, 1) = (paramVec(1) * y(2) * y(3) + paramVec(2) * y(2) + paramVec(4) * y(3) + paramVec(5));
        potgradVec(2, 1) = (paramVec(1) * y(1) * y(3) + paramVec(2) * y(1) + paramVec(3) * y(3) + paramVec(6));
        potgradVec(3, 1) = (paramVec(1) * y(1) * y(2) + paramVec(3) * y(2) + paramVec(4) * y(1) + paramVec(7));
        
        gradGain = -1 / norm(potgradVec, 2);
        dvecdt = gradGain * potgradVec;
    end
end
