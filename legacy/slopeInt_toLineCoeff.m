function lineCoeff = slopeInt_toLineCoeff(m,b)
%
% function to convert slope-intercept coefficients of a line to standard
%   matlab line coefficients
%
% INPUTS:
%   m - slope of the line
%   b - y-intercept of the line
%
% OUTPUTS: 
%   lineCoeff - vector [A,B,C] where Ax + By + C = 0

if isnan(m)   % presumed vertical line
    lineCoeff = [1 0 0];    % line is indeterminate
    return;
end
    
if m == 0
    lineCoeff(1) = 0;
    lineCoeff(2) = 1;
else
    lineCoeff(1) = 1;
    lineCoeff(2) = -lineCoeff(1) / m;
end
lineCoeff(3) = -lineCoeff(2) * b;