function [fpdist, fpidx] = findFarthestPoint(x, y, varargin)
%
% function to find the point(s) in y farthest from a single point "x"
%
% INPUTS:
%    x - a single n-dimensional point
%    y - an m x n matrix where each row is a different point in an
%       n-dimensional space
%
% VARARGs:
%    optional 3rd argument indicates how many points to return - default is
%       one
%
% OUTPUTS:
%    fpdist - the distance(s) from the point "x" to its farthest neighbors
%    fpidx  - the row indices in "y" of the points farthest from "x"

numNeighbors = 1;
if nargin == 3
    numNeighbors = varargin{1};
end

if size(x,2) ~= size(y,2)
    error('x and y must have the same number of columns');
end

dist = zeros(size(y,1),1);
for ii = 1 : length(dist)
    dist(ii) = norm(y(ii,:) - x);
end

[distsort, sortidx] = sort(dist,'descend');
fpdist = distsort(1:numNeighbors);
fpidx  = sortidx(1:numNeighbors);

end