function theta = pointsAngle2(X)
%
% INPUTS
%   X - 2 x 2 array where each row is an (x,y) pair
%
% OUTPUTS
%   theta - angle of each row of pointsAngle with respect to the horizontal

cplx = diff(X(:,2)) - diff(X(:,1)) * 1i;   % subtract y difference because positive y is down

theta = angle(cplx);