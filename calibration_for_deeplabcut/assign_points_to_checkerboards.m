function [ directLeftPoints, directRightPoints, directTopPoints, leftMirrorPoints, rightMirrorPoints, topMirrorPoints ] = ...
    assign_points_to_checkerboards( X, directViewLeftIdx, directViewRightIdx, directViewTopIdx, leftMirrorIdx, rightMirrorIdx, topMirrorIdx )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% INPUTS
%   X - m x 2 array of (x,y) pairs from the image
%   yyyIdx - row indices within X that belong to the relevant view
%
% OUTPUTS
%   yyyPoints - m x 2 array of (x,y) pairs for the relevant view

if ~isempty(directViewLeftIdx)
    directLeftPoints = X(directViewLeftIdx,:);
else
    directLeftPoints = [];
end

if ~isempty(directViewRightIdx)
    directRightPoints = X(directViewRightIdx,:);
else
    directRightPoints = [];
end

if ~isempty(directViewTopIdx)
    directTopPoints = X(directViewTopIdx,:);
else
    directTopPoints = [];
end

if ~isempty(leftMirrorIdx)
    leftMirrorPoints = X(leftMirrorIdx,:);
else
    leftMirrorPoints = [];
end

if ~isempty(rightMirrorIdx)
    rightMirrorPoints = X(rightMirrorIdx,:);
else
    rightMirrorPoints = [];
end

if ~isempty(topMirrorIdx)
    topMirrorPoints = X(topMirrorIdx,:);
else
    topMirrorPoints = [];
end

end

