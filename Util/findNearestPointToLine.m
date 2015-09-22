function [nndist, nnidx] = findNearestPointToLine(Q, Q0, varargin)
%
% from a collection of points, find the one that is closest to the line
% specified by Q
%
% usage: [nndist, nnidx] = findNearestPointToLine(Q, Q0, varargin)
%
% function to find the point(s) in y closest to a single point "x"
%
% INPUTS:
%    Q - 2 x 2 or 2 x 3 matrix containing points defining the line, where
%       each row is an [x,y,(z)] point
%    Q0 - an m x n matrix where each row is a different point in an
%       n (2 or 3)-dimensional space
%
% VARARGs:
%    optional 3rd argument indicates how many points to return - default is
%       one
%
% OUTPUTS:
%    nndist - the distance(s) from the point "x" to its nearest neighbors
%    nnidx  - the row indices in Q0 of the points closest to the line
%       defined by Q

numNeighbors = 1;
if nargin == 3
    numNeighbors = varargin{1};
end

if size(Q,2) ~= size(Q0,2)
    error('Q and Q0 must have the same number of columns');
end

d = zeros(size(Q0,1),1);
for ii = 1 : length(d)
    d(ii) = distanceToLine(Q(1,:),Q(2,:),Q0(ii,:));
end

[distsort, sortidx] = sort(d);
nndist = distsort(1:numNeighbors);
nnidx  = sortidx(1:numNeighbors);

end