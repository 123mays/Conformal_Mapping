function [theta_interp, phi_interp] = interpolate_Weighted_matlab(Mdl, coordinate, valVector)
%function potential_interp = interpolate_Weighted(kdtree)
% Q=coordinate';
% [index, distance] = vl_kdtreequery(kdtree, X, Q, 'NumNeighbors', 4) ;
[IdxNN, distance] = knnsearch(Mdl,coordinate,'K',10);

temp_theta=0; temp_phi=0; sumDist=0;
for i =1:10
    idx= IdxNN(i);
    
    temp_theta = temp_theta+ distance(i) * valVector(idx, 4);
    temp_phi = temp_phi+ distance(i) * valVector(idx, 5);
    sumDist= distance(i)+ sumDist;
end

theta_interp= temp_theta/sumDist;
phi_interp = temp_phi/sumDist;