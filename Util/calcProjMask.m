function projMask = calcProjMask(mask, F, bbox, imSize)
%
% INPUTS:
%   mask - logical array containing the object mask in one view
%   F - fundamental matrix
%   bbox - 1 x 4 vector containing bounding box of mask within its
%       original image
%   imSize - 1 x 2 vector containing the height and width of the image

outline = bwmorph(mask,'remove');
[y,x] = find(outline);
y = y + bbox(2)-1;    % move coordinates into the full image from just the bounding box
x = x + bbox(1)-1;
    
epiLines = epipolarLine(F, [x,y]);
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

projMask = poly2mask(extreme_x,extreme_y,imSize(1),imSize(2));