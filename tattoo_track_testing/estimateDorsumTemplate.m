function dorsum3Dpts = estimateDorsumTemplate(dorsumMasks, mask_bbox, digitMarkers, trackingBoxParams)
%
% INPUTS:
%   dorsumMasks - 1x2 cell array containing the masks of the paw dorsum in
%       the direct (index 1) and mirror (index 2) views
%   
% OUTPUTS:

% first, estimate 4 corner points for the dorsum mask in each view

dorsumCornerPoints = zeros(4,2,2);    % 4 points by x,y by 2 views
for iView = 1 : 2
    edgeMask = bwmorph(dorsumMasks{iView},'remove');
    [y,x] = find(edgeMask);
    idxPt   = squeeze(digitMarkers(2,:,1,iView));
    pinkyPt = squeeze(digitMarkers(5,:,1,iView));
    
    % find the point in the dorsum mask closest to the proximal index
    % finger point
    [~,nnidx] = findNearestNeighbor(idxPt,[x,y]);
    dorsumCornerPoints(1,:,iView) = [x(nnidx),y(nnidx)];
    
    % find the point in the dorsum mask closest to the proximal pinky
    % finger point
    [~,nnidx] = findNearestNeighbor(pinkyPt,[x,y]);
    dorsumCornerPoints(2,:,iView) = [x(nnidx),y(nnidx)];
    
    % find the point in the dorsum mask farthest from the proximal index
    % finger point
    [~,nnidx] = findFarthestPoint(idxPt,[x,y]);
    dorsumCornerPoints(3,:,iView) = [x(nnidx),y(nnidx)];
    
    % find the point in the dorsum mask farthest from the proximal pinky
    % finger point
    [~,nnidx] = findFarthestPoint(pinkyPt,[x,y]);
    dorsumCornerPoints(4,:,iView) = [x(nnidx),y(nnidx)];
    
end