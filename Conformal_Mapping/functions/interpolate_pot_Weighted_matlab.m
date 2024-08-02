function [pot_interp] = interpolate_pot_Weighted_matlab(Mdl, coordinate, valVector)

% Q=coordinate';
% [index, distance] = vl_kdtreequery(kdtree, X, Q, 'NumNeighbors', 10) ;
[IdxNN, distance] = knnsearch(Mdl,coordinate,'K',10);

temp_pot=0;  sumDist=0;
for i =1:10
    idx= IdxNN(i);
    temp_pot = temp_pot+ distance(i) * valVector(idx, 4);
    sumDist= distance(i)+ sumDist;
end

pot_interp = temp_pot/sumDist;