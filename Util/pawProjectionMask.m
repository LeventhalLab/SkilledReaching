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

mirror_ext = bwmorph(mirrorMask,'remove');
[y,x] = find(mirror_ext);

epiLines = epipolarLine(fundmat, [x,y]);
epi_pts = lineToBorderPoints(epiLines, imSize);

% find extreme coordinates on each side of the image
% find the highest edge point on each side
extreme_x = zeros(5,1);
extreme_y = zeros(5,1);

idx = find(epi_pts(:,2) == min(epi_pts(:,2)));
idx = idx(1);   % in case there's more than one line with the same extreme point
extreme_x(1) = epi_pts(idx,1);
extreme_x(5) = epi_pts(idx,1);
extreme_y(1) = epi_pts(idx,2);
extreme_y(5) = epi_pts(idx,2);

idx = find(epi_pts(:,2) == max(epi_pts(:,2)));
idx = idx(1);   % in case there's more than one line with the same extreme point
extreme_x(2) = epi_pts(idx,1);
extreme_y(2) = epi_pts(idx,2);

idx = find(epi_pts(:,4) == max(epi_pts(:,4)));
idx = idx(1);   % in case there's more than one line with the same extreme point
extreme_x(3) = epi_pts(idx,3);
extreme_y(3) = epi_pts(idx,4);

idx = find(epi_pts(:,4) == min(epi_pts(:,4)));
idx = idx(1);   % in case there's more than one line with the same extreme point
extreme_x(4) = epi_pts(idx,3);
extreme_y(4) = epi_pts(idx,4);


mask = poly2mask(extreme_x,extreme_y,imSize(1),imSize(2));

end