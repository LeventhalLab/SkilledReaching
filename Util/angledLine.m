function angledLineCoeff = angledLine(lineCoeff, linePt, theta)
%
% function 
%
% INPUTS:
%   lineCoeff - coefficients that define the line [A,B,C] where
%       Ax + By + C = 0
%   linePt - [x,y] pair through which the angled line must pass
%   theta - 
%       positive theta - clockwise rotation (when x points right and y 
%       points down); negative theta is for counter-clockwise rotations

epsilon = 0.001;

% first, check that linePt lies on the line defined by lineCoeff
testValue = lineCoeff(1) * linePt(1) + lineCoeff(2) * linePt(2) + lineCoeff(3);
if testValue > epsilon
    error('linePt must lie on the line defined by lineCoeff');
end

% translate the line so that linePt is moved to the origin
if lineCoeff(2) ~= 0    % line isn't vertical
    x = linePt(1) + 100;   % 100 is totally arbitrary
    y = (-lineCoeff(1) * x - lineCoeff(3)) / lineCoeff(2);
    
    x = x - linePt(1);
    y = y - linePt(2);
else
    x = 0;
    y = 100;
end

rotMatrix = [cos(theta), -sin(theta)
             sin(theta),  cos(theta)];
         
rotPt = (rotMatrix * [x;y])';

% now translate back
rotPt = rotPt + linePt;

angled_points = [linePt;rotPt];
    
angledLineCoeff = lineCoeffFromPoints(angled_points);

% perpCoeff = zeros(1,3);
% 
% if lineCoeff(1) == 0
%     perpCoeff(2) = 0;
%     perpCoeff(1) = 1;
%     perpCoeff(3) = -linePt(1);
%     return;
% end
% 
% if lineCoeff(2) == 0
%     perpCoeff(1) = 0;
%     perpCoeff(2) = 1;
%     perpCoeff(3) = -linePt(2);
%     return;
% end
% 
% m = -lineCoeff(1)/lineCoeff(2);    % slope of original line
% perp_m = -1/m;
% 
% perpCoeff(2) = 1;
% perpCoeff(1) = -perp_m;
% perpCoeff(3) = -linePt(2) - perpCoeff(1) * linePt(1);
% 
% 
% 
% imSize = [1000,1000];    % just needs to be big enough to hold the lines
% perpEdgePts = lineToBorderPoints(perpCoeff, imSize);
% perpEdgePts = reshape(perpEdgePts,[2,2])';
% 
% 
%          
% perpEdgePts_shift = bsxfun(@minus,perpEdgePts, linePt);    % shifted to origin
% perpEdgePts_rot = rotMatrix * perpEdgePts_shift';
% 
% angled_pts = bsxfun(@plus,perpEdgePts_rot, linePt);
% 
% angledLineCoeff = lineCoeffFromPoints(angled_pts);