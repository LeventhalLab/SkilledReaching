function [new_mask] = connectBlobs(old_mask)
%
% usage: new_mask = multiRegionConvexHullMask(old_mask)
%
% function to take a logical image mask with one or more regions, and 
% create a new mask for the convex image of all regions combined
%
% INPUTS:
%    old_mask - logical matrix containing black/white masks with multiple
%       regions of the size m x n x p, where m is the image height, n is
%       the image width, and p is the number of masks
%
% OUTPUTS: 
%    new_mask - logical matrix the same size as old_mask that masks out the
%       convex image of all regions in old_mask combined
%

% first, find a polygon mask using the region centroids as the vertices

% updated 06/18/2015 so that the algorithm can handle multiple "layers" -
% that way if multiple objects overlap with each other, they are identified
% as separate "blobs" with more than one centroid - DL

s = regionprops(old_mask, 'Centroid');
numCentroids = length(s);

if numCentroids == 0 || numCentroids == 1
    new_mask = old_mask;
    return;
end

centroids = zeros(numCentroids,2);
for ii = 1 : numCentroids
    centroids(ii,:) = s(ii).Centroid;
end

if numCentroids == 2   % if only two connected regions
    % create a polygon by moving one pixel in x and y away from each
    % centroid to generate 4 vertices
    centroids = [centroids(1,1) + 1, centroids(1,2) + 1;...
                 centroids(1,1) - 1, centroids(1,2) - 1;...
                 centroids(2,1) - 1, centroids(2,2) - 1;...
                 centroids(2,1) + 1, centroids(1,2) + 1];
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
BW = imdilate(BW,SE);   % make sure the polygon is fat enough to not skip any points

new_mask = BW | old_mask;    % polygon containing centroids of vertices combined
                       % with the original masking image
      
s = regionprops(new_mask,'Centroid');
SE = strel('disk',1);
while length(s) > 1    % if the old regions are too colinear, might not combine to one blob, so dilate until they meet
    new_mask = imdilate(new_mask,SE);
    s = regionprops(new_mask,'Centroid');
end