function cdiff = circDiff(y1,y2,minVal,maxVal)
%
% function to calculate the smallest circular difference between an array 
% and a single value, or two arrays of the same size. 
%
% usage: cdiff = circDiff(y1,y2,minVal,maxVal)
%
% INPUTS:
%   y1, y2 - either two arrays of the same size, one array and one scalar,
%       or two scalars
%   minVal, maxVal - interval over which the circular values exist. For
%       example, minVal = 0 and maxVal = 1 would mean that the value 1.5
%       maps to 0.5, and that the difference between 0.1 and 0.9 is 0.2
%
% OUTPUTS:
%

if size(y1) ~= size(y2)
    if length(y1) ~= 1 && length(y2) ~= 1
        error('y1 and y2 must be the same size')
    end
end

y1_scaled = (y1 / (maxVal-minVal)) * 2 * pi;
y1_scaled = wrapTo2Pi(y1_scaled);

y2_scaled = (y2 / (maxVal-minVal)) * 2 * pi;
y2_scaled = wrapTo2Pi(y2_scaled);

y_diff = abs(y1_scaled - y2_scaled);
y_diff = min(y_diff, 2*pi - y_diff);

cdiff = (wrapTo2Pi(y_diff) * (maxVal-minVal)) / (2*pi);