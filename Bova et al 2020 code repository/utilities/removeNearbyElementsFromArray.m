function Y = removeNearbyElementsFromArray(X, minSeparation)
%
% function to extract elements from an array that are at least
% minSeparation away from all other elements
%
% INPUTS
%   X - matrix containing elements from which to extract all values that
%       are not too close to other values
%   minSeparation - minimum difference in values to accept (i.e., if 2
%       values are separated by 2 and minSeparation is 3, only the lower
%       value will be preserved in Y)
%
% OUTPUTS
%   Y - vector containing elements of X that are far greater than
%       minSeparation apart from each other
%

if isempty(X)
    Y = [];
    return;
end
Xunique = unique(X(:),'sorted');

Xdiff = diff(Xunique);

spacingTooSmall = Xdiff < minSeparation;
if isrow(spacingTooSmall)
    spacingTooSmall = [false,spacingTooSmall];
else
    spacingTooSmall = [false;spacingTooSmall];
end

Y = Xunique(~spacingTooSmall);


