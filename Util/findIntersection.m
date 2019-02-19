function [int_pt,isPtInSegment] = findIntersection(line1,line2)
%
% function to calculate the intersection of two lines
%
% INPUTS:
%   line1, line2 - vectors [A,B,C] where Ax + By + C = 0
%       OR...
%       two 2x2 matrices containing x,y points that define two lines
%       OR...
%       a 4-element vector of (x1,y1,x2,y2)
%       OR...
%       any combination of the above
%
% OUTPUTS:
%   int_pt - intersection point [x,y]

% parse input

int_pt = zeros(1,2);
isPtInSegment = false(2,1);

if all(size(line1) == 2) || length(line1) == 4
    % input 1 is a 2 x 2 array or a 4-element vector
    a = pointsToLine(line1);
    isLine1_a_segment = true;
else
    a = line1;
    isLine1_a_segment = false;
end
if all(size(line2) == 2) || length(line2) == 4
    % input 2 is a 2 x 2 array
    b = pointsToLine(line2);
    isLine2_a_segment = true;
else
    b = line2;
    isLine2_a_segment = false;
end

int_pt(2) = (b(3)/b(1) - a(3)/a(1)) / ...
                (a(2)/a(1) - b(2)/b(1));

int_pt(1) = (-a(3) - a(2)*int_pt(2)) / a(1);
    
if isLine1_a_segment
    % is int_pt between the endpoints that define line1?
    if length(line1) == 4
        line1 = [line1(1,:);line1(2,:)];
    end
    if (int_pt(1) >= line1(1,1) && int_pt(1) <= line1(2,1)) && ... % x is between the two x coordinates
       (int_pt(2) >= line1(1,2) && int_pt(2) <= line1(2,2))   % y is between the 2 y coordinates (probably overkill; just x is sufficient, I think)
        isPtInSegment(1) = true;
    end
end
            
if isLine2_a_segment
    % is int_pt between the endpoints that define line2?
    if length(line2) == 4
        line2 = [line2(1,:);line2(2,:)];
    end
    if (int_pt(1) >= line2(1,1) && int_pt(1) <= line2(2,1)) && ... % x is between the two x coordinates
       (int_pt(2) >= line2(1,2) && int_pt(2) <= line2(2,2))   % y is between the 2 y coordinates (probably overkill; just x is sufficient, I think)
        isPtInSegment(2) = true;
    end
end
            
    
