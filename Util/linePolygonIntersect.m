function intersectPoints = linePolygonIntersect(linePoints,polyPoints,varargin)
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

% find points within distTolerance of the line
min_x = min(polyPoints(:,1));
max_x = max(polyPoints(:,1));
min_y = min(polyPoints(:,2));
max_y = max(polyPoints(:,2));

intersectPoints = zeros(0,2);

iterations = 0;
for ii = round(min_x) : round(max_x)
    iterations = iterations + 1;
    if iterations > 1000
        iterations
        keyboard
    end
    iterations2 = 0;
    for jj = round(min_y) : round(max_y)
            iterations2 = iterations2 + 1;
            if iterations2 > 1000
                iterations2
                keyboard
            end
        lineVal = ii * lineCoeff(1) + jj * lineCoeff(2) + lineCoeff(3);
        
        if inpolygon(ii,jj,polyPoints(:,1),polyPoints(:,2)) && abs(lineVal) < distTolerance
            intersectPoints = [intersectPoints;ii,jj];
        end
    end
end


