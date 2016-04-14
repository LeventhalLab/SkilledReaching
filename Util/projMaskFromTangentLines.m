function projMask = projMaskFromTangentLines(mask, fundMat, bbox, imSize)
%
% function to take an image mask that is part of a full image, and figure
% out where its possible projection is in an alternative view (e.g., mirror
% vs direct view)
%
% INPUTS:
%   mask - bw image segment containing a mask of the object of interest. OK
%       to have more than one mask - algorithm will take the convex hull to
%       compute its projection
%   fundMat - fundamental matrix going from the current camera view to an
%       alternative camera view (for paw tracking, mirror vs direct view)
%   bbox - 4-element vector [x,y,w,h], where (x,y) is the top left
%       coordinate of the bounding box, w and h are width and height,
%       respectively. This is the bounding box from which mask is taken
%       from a full image
%   imSize - [h,w], where h and w are the height and width of the full
%       image, respectively
%
% OUTPUTS:
%   projMask - projection of mask into the full image

if ~any(mask(:))
    projMask = false(imSize);
    return;
end

convMask = bwconvhull(mask,'union');
[~, tlines] = findTangentToEpipolarLine(convMask, fundMat, bbox);

borderpts = lineToBorderPoints(tlines, imSize);
polyPts_x = [borderpts(1,1),borderpts(1,3),borderpts(2,3),borderpts(2,1),borderpts(1,1)];
polyPts_y = [borderpts(1,2),borderpts(1,4),borderpts(2,4),borderpts(2,2),borderpts(1,2)];

projMask = poly2mask(polyPts_x,polyPts_y,imSize(1),imSize(2));
