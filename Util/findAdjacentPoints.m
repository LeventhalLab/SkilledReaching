function [pts, idx] = findAdjacentPoints(ptList, centerPt, connectivity)
%
% INPUTS:
%   ptList - m x 2 array, where m is the number of points, and each row is
%       an (x,y) pair
%   centerPt - a single 2 element (x,y) pair
%
% OUTPUTS:
%   pts - m x 2 array, where m is the number of points, and each row is
%       the (x,y) location of a point adjacent to centerPt
%   idx - indices within ptList of pts


switch connectivity
    case 4,
        maxDist = 1;
    case 8,
        maxDist = sqrt(2);
    otherwise
        maxDist = sqrt(2);   % default connectivity is 8-point
end

if length(centerPt) == size(centerPt,1)
    % change column vector to row vector
    centerPt = centerPt';
end

xy_diff = bsxfun(@minus, ptList, centerPt);
dist_from_centerPt = sqrt(sum(xy_diff.^2,2));

idx = (dist_from_centerPt > 0) & ...    % ignore points that exactly match centerPt
      (dist_from_centerPt <= maxDist);
  
pts = ptList(idx,:);