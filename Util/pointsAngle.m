function theta = pointsAngle(X)
%
% INPUTS
%   X - 2 x 2 array where each row is an (x,y) pair
%
% OUTPUTS
%   theta - angle of each row of pointsAngle with respect to the horizontal

cplx = diff(X(:,1)) - diff(X(:,2)) * 1i;   % subtract y difference because positive y is down

theta = angle(cplx);