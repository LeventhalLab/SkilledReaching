function projMask = projMaskFromTangentLines(mask, fundMat, bbox, imSize)
%
% INPUTS:
%
% OUTPUTS:
%

s = regionprops(mask,'centroid');

if length(s) ~= 1
    error('image must exactly only one blob')
end

[~, tlines] = findTangentToEpipolarLine(mask, fundMat, bbox);

borderpts = lineToBorderPoints(tlines, imSize);
polyPts_x = [borderpts(1,1),borderpts(1,3),borderpts(2,3),borderpts(2,1),borderpts(1,1)];
polyPts_y = [borderpts(1,2),borderpts(1,4),borderpts(2,4),borderpts(2,2),borderpts(1,2)];

projMask = poly2mask(polyPts_x,polyPts_y,imSize(1),imSize(2));
