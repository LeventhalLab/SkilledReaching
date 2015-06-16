function [new_mask,hullPoints] = multiRegionConvexHullMask(old_mask)
%
% usage: new_mask = multiRegionConvexHullMask(old_mask)
%
% function to take a logical image mask with one or more regions, and 
% create a new mask for the convex image of all regions combined
%
% INPUTS:
%    old_mask - logical matrix containing a black/white mask with multiple
%       regions
%
% OUTPUTS: 
%    new_mask - logical matrix the same size as old_mask that masks out the
%       convex image of all regions in old_mask combined
%    hullPoints - 
%

% first, find a polygon mask using the region centroids as the vertices
s = regionprops(old_mask, 'Centroid');

if isempty(s)
    new_mask = old_mask;
    return;
end

if length(s) == 1   % if only one connected 
    s = regionprops(old_mask, 'BoundingBox', 'ConvexImage', 'ConvexHull');
    new_mask = false(size(old_mask));
    hullLeft  = round(s(1).BoundingBox(1));
    hullRight = hullLeft + s(1).BoundingBox(3) - 1;
    hullTop   = round(s(1).BoundingBox(2));
    hullBot   = hullTop + s(1).BoundingBox(4) - 1;
    new_mask(hullTop:hullBot, hullLeft:hullRight) = s.ConvexImage;
    
    hullPoints = s(1).ConvexHull;
    return;
end

centroids = zeros(length(s),2);
for ii = 1 : length(s)
    centroids(ii,:) = s(ii).Centroid;
end

% arrange centroids in a clockwise direction
centroidCenter = mean(centroids,1);
% calculate angles between center point, first point, and the other points
centroidRef = [centroids(:,1) - centroidCenter(1), centroids(:,2) - centroidCenter(2)];   % corner points in a coordinate system centered on the average of the corners
centroidAngles = angle(centroidRef(:,1) + 1i*centroidRef(:,2));
[~, sortIdx] = sort(centroidAngles);
centroids = centroids(sortIdx,:);

BW = poly2mask(centroids(:,1), centroids(:,2), size(old_mask,1), size(old_mask, 2));
SE = strel('disk',2);
BW = imdilate(BW,SE);   % make sure the polygons

BW = BW | old_mask;    % polygon containing centroids of vertices combined
                       % with the original masking image

% now find convex image of the single connected region in the mask BW
% because regionprops returns a mask only inside the bounding box, need to
% translate that mask into an image the size of old_mask
s = regionprops(BW, 'BoundingBox', 'ConvexImage', 'ConvexHull');
new_mask = false(size(old_mask));
hullLeft  = round(s(1).BoundingBox(1));
hullRight = hullLeft + s(1).BoundingBox(3) - 1;
hullTop   = round(s(1).BoundingBox(2));
hullBot   = hullTop + s(1).BoundingBox(4) - 1;
new_mask(hullTop:hullBot, hullLeft:hullRight) = s.ConvexImage;

hullPoints = s(1).ConvexHull;
end