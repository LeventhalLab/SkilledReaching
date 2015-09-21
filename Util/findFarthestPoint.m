function [nndist, nnidx] = findFarthestPoint(x, y, varargin)
%
% usage: 
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
%    nndist - the distance(s) from the point "x" to its farthest neighbors
%    nnidx  - the row indices in "y" of the points farthest from "x"

numNeighbors = 1;
if nargin == 3
    numNeighbors = varargin{1};
end

if size(x,2) ~= size(y,2)
    error('x and y must have the same number of columns');
end

diffMatrix = zeros(size(y));
for ii = 1 : size(x, 2)
    diffMatrix(:,ii) = x(ii) - y(:,ii);
end

dist = sum(diffMatrix.^2, 2);
[distsort, sortidx] = sort(dist,'descend');
nndist = distsort(1:numNeighbors);
nnidx  = sortidx(1:numNeighbors);

end