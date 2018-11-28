function lineCoeff = lineFromEndpoints(endPoints)
%
% INPUTS
%   endPoints: line endpoints specified either as a 4-element vector
%       [x1,y1,x2,y2] or a 2 x 2 matrix [x1,y1;x2,y2]
%
% OUTPUTS
%   lineCoeff: 3 element vector [A,B,C] such that Ax + By + C = 0

if length(endPoints) == 4
    endPoints = [endPoints(1:2);endPoints(3:4)];
end

A = (endPoints(1,2)-endPoints(2,2)) / (endPoints(1,1)-endPoints(2,1));
B = -1;
C = endPoints(1,2) - A * endPoints(1,1);

lineCoeff = [A,B,C];