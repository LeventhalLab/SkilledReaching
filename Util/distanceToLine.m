function d = distanceToLine(Q1,Q2,Q0)
%
% function to find the shortest distance between a point and a line
%
% INPUTS:
%   Q1, Q2 are points that define the line
%   Q0 is the point to which we are trying to find the distance
%
% OUTPUTS:
%   d - Euclidean distance to the line

% make sure all are row vectors 
if size(Q1,1) == length(Q1)
    Q1 = Q1';
end
if size(Q2,1) == length(Q2)
    Q2 = Q2';
end
if size(Q1,1) == length(Q1)
    Q0 = Q0';
end

if length(Q1) ~= length(Q2) || ...
   length(Q2) ~= length(Q0)
   error('vectors must be the same length')
end

% 2D or 3D case
if length(Q1) == 2
    d = calc2Ddistance(Q1,Q2,Q0);
elseif length(Q1) == 3
    d = calc3Ddistance(Q1,Q2,Q0);
else
    error('must be 2D or 3D points')
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = calc2Ddistance(Q1,Q2,Q0)

d = abs(det([Q2-Q1;Q0-Q1]))/norm(Q2-Q1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = calc3Ddistance(Q1,Q2,Q0)

d = norm(cross(Q2-Q1,Q0-Q1))/norm(Q2-Q1);

end