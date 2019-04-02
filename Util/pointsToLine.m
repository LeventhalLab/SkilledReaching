function lineOut = pointsToLine(X)
%
% function to convert two (x,y) pairs to line coefficients such that 
% Ax + By + C = 0
%
% INPUTS:
%   X - either a 2 x 2 array where each row is an (x,y) pair, or a
%       4-element vector of (x1,y1,x2,y2)
%
% OUTPUTS:
%   lineOut - [A,B,C] triple such that Ax + By + C = 0 is a line that
%       passes through both points in X

A = 1;

if all(size(X)==2)
    pt1 = X(1,:);
    pt2 = X(2,:);
elseif length(X) == 4
    pt1 = X(1:2);
    pt2 = X(3:4);
end

B = (pt2(1)-pt1(1))/(pt1(2)-pt2(2));

C = -pt1(1) - B * pt1(2);

lineOut = [A,B,C];