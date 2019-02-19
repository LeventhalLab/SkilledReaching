function int_pt = findIntersection(line1,line2)
%
% function to calculate the intersection of two lines
%
% INPUTS:
%   line1, line2 - vectors [A,B,C] where Ax + By + C = 0
%       OR...
%       two 2x2 matrices containing x,y points that define two lines
%       OR...
%       one of each
%
% OUTPUTS:
%   int_pt - intersection point [x,y]

% parse input

int_pt = zeros(1,2);

if all(size(line1) == 2)
    % input 1 is a 2 x 2 array
    
else
    a = line1;
end
if all(size(line2) == 2)
    % input 2 is a 2 x 2 array
    
else
    b = line2;
end

int_pt(2) = (line2(3)/line2(1) - a(3)/a(1)) / ...
                (a(2)/a(1) - line2(2)/line2(1));

int_pt(1) = (-a(3) - a(2)*int_pt(2)) / a(1);
    
    
if length(line1) == 3 && length(line2) == 3
    % both inputs are [A,B,C] coefficients such that Ax + By + C = 0
    int_pt(2) = (line2(3)/line2(1) - line1(3)/line1(1)) / ...
                (line1(2)/line1(1) - line2(2)/line2(1));

    int_pt(1) = (-line1(3) - line1(2)*int_pt(2)) / line1(1);
    
elseif  && numel(line2) == 4
    % both inputs are (presumably) 2x2 arrays where each row is an [x,y]
    % pair defining one point on the line
    
else
    if length(line1) == 3