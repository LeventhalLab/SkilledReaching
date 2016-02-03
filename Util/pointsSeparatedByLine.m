function [idx_pos, idx_neg, idx_zero] = pointsSeparatedByLine(lineCoeff, pts, varargin)
%
% function to find points that are on either side of a line (or exactly on
% it)
%
% INPUTS:
%   lineCoeff - line coefficients in a 3-element vector [A,B,C] such that
%       Ax + By + C = 0
%   pts - m x 2 array of (x,y) pairs
%
% OUTPUTS:
%   idx_pos - indices of points for which Ax+By+C > 0
%   idx_neg - indices of points for which Ax+By+C < 0
%   idx_zero - indices of points for which Ax+By+C = 0 (points on the line)

zeroTol = 1e-10;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'zerotol',
            zeroTol = varargin{iarg + 1};
    end
end

% if pts is 2 x m instead of m x 2, use the transpose
if size(pts,2) ~= 2 && size(pts,1) == 2
    pts = pts';
end

lineVal = lineCoeff(1) * pts(:,1) + lineCoeff(2) * pts(:,2) + lineCoeff(3);

idx_zero = (abs(lineVal) < zeroTol);
idx_pos = (lineVal > 0) & ~idx_zero;
idx_neg = (lineVal < 0) & ~idx_zero;

idx_zero = find(idx_zero);
idx_pos = find(idx_pos);
idx_neg = find(idx_neg);