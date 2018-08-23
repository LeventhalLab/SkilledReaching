function [new_directChecks, new_mirrorChecks] = assign_csv_points_to_checkerboards(directBorderMask, mirrorBorderMask, newPoints)

num_newPoints = size(newPoints, 1);
numBoards = size(directBorderMask,3);   % this is one binary array instead of the cell structure that holds one array for each different image
new_directChecks = NaN(prod(anticipatedBoardSize-1), 2, numBoards);
new_mirrorChecks = NaN(prod(anticipatedBoardSize-1), 2, numBoards);

for i_pt = 1 : num_newPoints
    
    
    
end


end