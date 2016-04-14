function int_pt = findIntersection(line1,line2)
%
% function to calculate the intersection of two lines
%
% INPUTS:
%   line1, line2 - vectors [A,B,C] where Ax + By + C = 0
%
% OUTPUTS:
%   int_pt - intersection point [x,y]

int_pt = zeros(1,2);

int_pt(2) = (line2(3)/line2(1) - line1(3)/line1(1)) / ...
            (line1(2)/line1(1) - line2(2)/line2(1));

int_pt(1) = (-line1(3) - line1(2)*int_pt(2)) / line1(1);