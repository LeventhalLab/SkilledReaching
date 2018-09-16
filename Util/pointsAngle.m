function theta = pointsAngle(X)

% INPUTS
%   X - 2 x 2 array where each row is an (x,y) pair

cplx = diff(X(:,1)) + diff(X(:,2)) * 1i;

theta = angle(cplx);