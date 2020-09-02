function [zci] = findZeroCrossings(x, varargin)
%
% INPUTS
%   x - vector of values in which to look for zero crossings
%
% VARARGIN
%   'crossingdirection' - 'any','increasing', or 'decreasing'; whether to
%       only take zero crossings going in one direction
%
% OUTPUTS
%   zci - zero crossing indices
%
crossingDirection = 'any';

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'crossingdirection'
        	crossingDirection = varargin{iarg + 1};
    end
end

zci = find(x(:).*circshift(x(:), [-1 0]) <= 0);

if strcmpi(crossingDirection,'increasing')
    zci = zci(x(zci) < 0);
end

if strcmpi(crossingDirection,'decreasing')
    zci = zci(x(zci) > 0);
end