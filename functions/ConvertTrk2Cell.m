function track_cell_result = ConvertTrk2Cell(tracks, Padding, voxDim)
    tracks_cell = cell(length(tracks), 1);
    for i = 1:1:length(tracks)
        track_i = tracks(i);
        % Pad and convert to voxel coordinates
        b = zeros(track_i.nPoints, 3);
        for j = 1:track_i.nPoints
            b(j, :) = track_i.matrix(j, :) ./ voxDim + Padding / 2;
        end
        tracks_cell{i} = b;
    end
    track_cell_result = tracks_cell;
end
