function [new_mask,hullPoints] = multiRegionConvexHullMask(old_masks)
%
% usage: new_mask = multiRegionConvexHullMask(old_mask)
%
% function to take a logical image mask with one or more regions, and 
% create a new mask for the convex image of all regions combined
%
% INPUTS:
%    old_masks - logical matrix containing black/white masks with multiple
%       regions of the size m x n x p, where m is the image height, n is
%       the image width, and p is the number of masks
%
% OUTPUTS: 
%    new_mask - logical matrix the same size as old_mask that masks out the
%       convex image of all regions in old_mask combined
%    hullPoints - 
%

% first, find a polygon mask using the region centroids as the vertices

% updated 06/18/2015 so that the algorithm can handle multiple "layers" -
% that way if multiple objects overlap with each other, they are identified
% as separate "blobs" with more than one centroid - DL

numCentroids = 0;
old_mask = false(size(old_masks,1),size(old_masks,2));
for ii = 1 : size(old_masks, 3)
    s = regionprops(squeeze(old_masks(:,:,ii)), 'Centroid');
    for jj = 1 : length(s)
        numCentroids = numCentroids + 1;
        if numCentroids == 1
            centroids = s(jj).Centroid;
        else
            centroids = [centroids;s(jj).Centroid];
        end
    end
    old_mask = old_mask | squeeze(old_masks(:,:,ii));
end 

if numCentroids == 0
    new_mask = old_mask;
    return;
end

if numCentroids == 1   % if only one connected region
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

if numCentroids == 2   % if only two connected regions
    % create a polygon by moving one pixel in x and y away from each
    % centroid to generate 4 vertices
    centroids = [centroids(1,1) + 1, centroids(1,2) + 1;...
                 centroids(1,1) - 1, centroids(1,2) - 1;...
                 centroids(2,1) - 1, centroids(2,2) - 1;...
                 centroids(2,1) + 1, centroids(1,2) + 1];
           
%     % arrange corners in a clockwise direction
%     cornerCenter = mean(corners,1);
%     % calculate angles between center point, first point, and the other points
%     cornerRef = [corners(:,1) - cornerCenter(1), corners(:,2) - cornerCenter(2)];   % corner points in a coordinate system centered on the average of the corners
%     cornerAngles = angle(cornerRef(:,1) + 1i*cornerRef(:,2));
%     [~, sortIdx] = sort(cornerAngles);
%     corners = corners(sortIdx,:);
% 
% 
% 
%     s = regionprops(old_mask, 'BoundingBox', 'ConvexImage', 'ConvexHull');
%     new_mask = false(size(old_mask));
%     hullLeft  = round(s(1).BoundingBox(1));
%     hullRight = hullLeft + s(1).BoundingBox(3) - 1;
%     hullTop   = round(s(1).BoundingBox(2));
%     hullBot   = hullTop + s(1).BoundingBox(4) - 1;
%     new_mask(hullTop:hullBot, hullLeft:hullRight) = s.ConvexImage;
%     
%     hullPoints = s(1).ConvexHull;
%     return;
end

% now if there are 3 or more centroids, create a polygon using each
% centroid as a vertex, merge with the old_mask's and find the convex hull

% arrange centroids in a clockwise direction
centroidCenter = mean(centroids,1);
% calculate angles between center point, first point, and the other points
centroidRef = [centroids(:,1) - centroidCenter(1), centroids(:,2) - centroidCenter(2)];   % corner points in a coordinate system centered on the average of the corners
centroidAngles = angle(centroidRef(:,1) + 1i*centroidRef(:,2));
[~, sortIdx] = sort(centroidAngles);
centroids = centroids(sortIdx,:);

BW = poly2mask(centroids(:,1), centroids(:,2), size(old_mask,1), size(old_mask, 2));
SE = strel('disk',2);
BW = imdilate(BW,SE);   % make sure the polygon is fat enough to not skip any points

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