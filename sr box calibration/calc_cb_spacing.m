function [d_horiz,d_vert] = calc_cb_spacing(wpts,cb_size)
%
% usage: [d_horiz,d_vert] = calc_cb_spacing(wpts,cb_size)
%
% INPUTS:
%   wpts - world points (but really, could be in any coordinates), where
%       each row is an [x,y,(z)] point. Can be 2-D, 3-D, homogeneous or
%       inhomogeneous coordinates. Assumes points are ordered such that the
%       first row is followed by the second row is followed by the third
%       row (all in order)
%   cb_size - 2-element vector [numRows, numColumns]. The input should be
%       the number of points, not the number of squares. That is, the
%       number of points in a row is one less than the number of squares in
%       the row
%
% OUTPUTS:
%   d_horiz - vector containing all the distances between points adjacent
%       to each other in the horizontal direction
%   d_vert - vector containing all the distances between points adjacent
%       to each other in the vertical direction

d_horiz = zeros((cb_size(1) * (cb_size(2)-1)),1);
d_vert = zeros((cb_size(1)-1) * cb_size(2),1);

d_horiz_idx = 0;
d_vert_idx = 0;

numRows = cb_size(1);
numCols = cb_size(2);
for iRow = 1 : numRows
    for iCol = 1 : numCols
        % calculate distance between horizontal adjacent points
        if iCol < numCols
            d_horiz_idx = d_horiz_idx + 1;
            cb_idx1 = (iRow-1)*numCols + iCol;
            cb_idx2 = (iRow-1)*numCols + iCol + 1;
            
            d_horiz(d_horiz_idx) = norm(wpts(cb_idx1,:) - wpts(cb_idx2,:));
        end
        % calculate distance between vertical adjacent points
        if iRow < numRows
            d_vert_idx = d_vert_idx + 1;
            cb_idx1 = (iRow-1)*numCols + iCol;
            cb_idx2 = (iRow)*numCols + iCol;
        
            try
                d_vert(d_vert_idx) = norm(wpts(cb_idx1,:) - wpts(cb_idx2,:));
            catch
                keyboard
            end
        end
        
    end
end