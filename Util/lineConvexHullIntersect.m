function intersectPoints = lineConvexHullIntersect(linePoints,polyPoints,varargin)
%
% function that returns a set of points along the intersection of a line
% with a polygon
%
% INPUTS
%   linePoints: either 2 endpoints that define a line as a 4-element vector
%       ([x1,y1,x2,y2]) or a 2 x 2 array ([x1,y1;x2,y2]), OR as a 3-element
%       vector [A,B,C] such that Ax + By + C = 0
%   polyPoints: m x 2 array containing the vertices of the polygon as (x,y)
%       pairs
%
% VARARGS
%   distTolerance: distance points can be from the line and be considered
%       "on" it
%
% OUTPUTS
%   intersectPoints: m x 2 array containing points within distTolerance
%       (default 1) pixels of the line defined by linePoints
%

distTolerance = 1;

if numel(linePoints) == 4     % line defined by end points
    lineCoeff = lineFromEndpoints(linePoints);
else
    lineCoeff = linePoints;
end

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'disttolerance'
            distTolerance = varargin{iarg + 1};
    end
end

cvHull_idx = convhull(polyPoints);
cvHull_pts = polyPoints(cvHull_idx,:);
% find points within distTolerance of the line
min_x = min(cvHull_pts(:,1));
max_x = max(cvHull_pts(:,1));
min_y = min(cvHull_pts(:,2));
max_y = max(cvHull_pts(:,2));

intersectPoints = zeros(0,2);
for ii = round(min_x) : round(max_x)
    
    for jj = round(min_y) : round(max_y)
        
        lineVal = ii * lineCoeff(1) + jj * lineCoeff(2) + lineCoeff(3);
        
        if inpolygon(ii,jj,cvHull_pts(:,1),cvHull_pts(:,2)) && abs(lineVal) < distTolerance
            intersectPoints = [intersectPoints;ii,jj];
        end
    end
end


