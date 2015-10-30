function perpCoeff = perpendicularLine(lineCoeff, linePt)
%
%
%
% INPUTS:
%   lineCoeff - coefficients that define the line [A,B,C] where
%       Ax + By + C = 0
%   linePt - 

perpCoeff = zeros(1,3);

if lineCoeff(1) == 0
    perpCoeff(2) = 0;
    perpCoeff(1) = 1;
    perpCoeff(3) = -linePt(1);
    return;
end

if lineCoeff(2) == 0
    perpCoeff(1) = 0;
    perpCoeff(2) = 1;
    perpCoeff(3) = -linePt(2);
    return;
end

m = -lineCoeff(1)/lineCoeff(2);    % slope of original line
perp_m = -1/m;

perpCoeff(2) = 1;
perpCoeff(1) = -perp_m;
perpCoeff(3) = -linePt(2) - perpCoeff(1) * linePt(1);