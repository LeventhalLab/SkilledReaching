function shadowMask = findShadowRegion(blobMask, viewPoint)
%
% function to find the region that is not visible on the other side of a
% blob from the point viewPoint
%
% INPUTS:
%   blobMask - mask of a single blob
%   viewPoint - point in the image from which the observer is looking
%
% OUTPUTS:
%   shadowMask - bw mask indicating the region obscured by blobMask when
%       looking from viewPoint
%

[tanPts,~] = findTangentToBlob(blobMask, viewPoint);

s = regionprops(blobMask,'centroid');

farSide = ~segregateImage(tanPts, viewPoint, size(blobMask));
shadow1 = segregateImage([viewPoint;tanPts(1,:)], s.Centroid, size(blobMask));
shadow2 = segregateImage([viewPoint;tanPts(2,:)], s.Centroid, size(blobMask));

shadowMask = farSide & shadow1 & shadow2;

shadowMask = shadowMask & ~blobMask;

