function lineCoeff = lineCoeffFromPoints(linePoints)
%
% function to calculate line coefficients A,B,C (see OUTPUTS below) for the
% line that passes through the points linePoints
%
% INPUTS:
%    linePoints - 2 x 2 array, each row is an x,y pair designating a point
%
% OUTPUTS:
%    lineCoeff - 1 x 3 vector [A,B,C] such that Ax + By + C = 0
%

lineCoeff(1) = -diff(linePoints(:,2));
lineCoeff(2) = diff(linePoints(:,1));
lineCoeff(3) = -lineCoeff(1)*linePoints(1,1) - lineCoeff(2)*linePoints(1,2);