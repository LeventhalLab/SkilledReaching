function int_pt = line_segment_intersect(line1,seg)
%
% function to calculate the intersection of two lines
%
% INPUTS:
%   line1 - vectors [A,B,C] where Ax + By + C = 0
%   seg - line segment defined by two end points - either a 4 x 1 vector
%       [x1,y1,x2,y2] or a 2 x 2 array [x1,y1;x2,y2]
%
% OUTPUTS:
%   int_pt - intersection point [x,y]

if length(seg) == 4
    seg = [seg(1:2);seg(3:4)];
end
line2 = lineFromEndpoints(seg);
int_pt = findIntersection(line1,line2);

% check that the x-value of int_pt is between the x-values for seg
temp = sort(seg(:,1));

if int_pt(1) < temp(1) || int_pt(1) > temp(2)
    int_pt = [];
end
