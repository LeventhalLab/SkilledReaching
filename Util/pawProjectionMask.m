function mask = pawProjectionMask(mirrorMask, fundmat, imSize)
%
% usage:
%
% function to
%
% INPUTS:
%    mirrorMask - image mask from the mirror view
%    fundmat - fundamental matrix to transform mirror view into direct view
%    imSize - size of the direct view image
%
% OUTPUTS:
%    mask - mask showing region in which projection from the mirror could
%       exist in the direct view

[mirrorMaskRows,mirrorMaskCols] = find(squeeze(mirrorMask));
mirrorBotIdx = find(mirrorMaskRows == max(mirrorMaskRows),1);
mirrorTopIdx = find(mirrorMaskRows == min(mirrorMaskRows),1);
mirrorBottom = [mirrorMaskCols(mirrorBotIdx), mirrorMaskRows(mirrorBotIdx)];
mirrorTop    = [mirrorMaskCols(mirrorTopIdx), mirrorMaskRows(mirrorTopIdx)];

lines = epipolarLine(fundmat, [mirrorTop;mirrorBottom]);
pts   = lineToBorderPoints(lines, imSize);

polyCorners = zeros(size(pts,1)*2,2);
for ii = 1 : size(pts, 1)
    polyCorners(2*ii-1,:) = pts(ii,1:2);
    polyCorners(2*ii,:)   = pts(ii,3:4);
end

polyCenter = mean(polyCorners,1);
polyRef = [polyCorners(:,1) - polyCenter(1), polyCorners(:,2) - polyCenter(2)];   % corner points in a coordinate system centered on the average of the corners
polyAngles = angle(polyRef(:,1) + 1i*polyRef(:,2));
[~, sortIdx] = sort(polyAngles);
polyCorners = polyCorners(sortIdx,:);

mask = poly2mask(polyCorners(:,1), polyCorners(:,2), imSize(1), imSize(2));

end