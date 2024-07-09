function [gridSize_wPadding, sx, sy, sz] = initialize_grid(gridSize, Padding)
    gridSize_wPadding = gridSize + Padding;
    sx = gridSize_wPadding(1); 
    sy = gridSize_wPadding(2); 
    sz = gridSize_wPadding(3);
end