function d = distanceToLine(Q1,Q2,Q0)
%
% function to find the shortest distance between a point and a line
%
% INPUTS:
%   Q1, Q2 are points that define the line. These could be vectors defining
%       single points or matrices where each row defines a point
%   Q0 is the point to which we are trying to find the distance
%
% OUTPUTS:
%   d - Euclidean distance(s) to the line

% make sure all are row vectors 
if isvector(Q1)
    if size(Q1,1) == length(Q1)
        Q1 = Q1';
    end
end
if isvector(Q2)
    if size(Q2,1) == length(Q2)
        Q2 = Q2';
    end
end
if isvector(Q0)
    if size(Q0,1) == length(Q0)
        Q0 = Q0';
    end
else
    error('Q0 must be a single point')
end

if any(size(Q1) ~= size(Q2))
    error('Q1 and Q2 must be the same size')
end

if size(Q1,2) ~= length(Q0)
    error('Q1, Q2, and Q0 must have the same number of columns')
end

if size(Q1,2) ~= 2 &&  size(Q1,2) ~= 3
    error('must be 2D or 3D points')
end

d = zeros(size(Q1,1),1);
for iPoint = 1 : size(Q1,1)

    % 2D or 3D case
    if size(Q1,2) == 2
        d(iPoint) = calc2Ddistance(Q1(iPoint,:),Q2(iPoint,:),Q0);
    elseif size(Q1,2) == 3
        d(iPoint) = calc3Ddistance(Q1(iPoint,:),Q2(iPoint,:),Q0);
    end

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