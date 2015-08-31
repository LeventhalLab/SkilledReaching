function [validOverlap, overlapFract] = checkDigitOverlap_fromSide(viewMask, F, overlap_bbox, imSize, varargin)

% viewMask{1} contains masked images in the mirror view
% viewMask{2} contains masked images in the direct view
% F is the fundamental matrix going from center view to mirror view

minOverlap = 0.3;   % amount that each digit in the mirror view must overlap with the direct view

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'minoverlap',
            minOverlap = varargin{iarg + 1};
    end
end

F = F';   % now F goes from mirror view to center view
numObjects = size(viewMask{1},3);
validOverlap = false(numObjects, 1);
overlapFract = zeros(numObjects, 1);
for ii = 1 : numObjects
    
    mirrorMask = viewMask{1}(:,:,ii);
    centerMask = viewMask{2}(:,:,ii);
    if ~any(mirrorMask(:)) || ~any(centerMask(:))
        % this object was occluded in at least one of the views
        validOverlap(ii) = true;
        continue;
    end
    
    mirror_ext = bwmorph(viewMask{1}(:,:,ii),'remove');
    [y,x] = find(mirror_ext);
    y = y + overlap_bbox(1,2)-1;    % move coordinates into the full image from just the bounding box
    x = x + overlap_bbox(1,1)-1;

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
    projMask = projMask(overlap_bbox(2,2) : overlap_bbox(2,2) + overlap_bbox(2,4), ...
                        overlap_bbox(2,1) : overlap_bbox(2,1) + overlap_bbox(2,3));
    
    projectionOverlap = projMask & viewMask{2}(:,:,ii);
    
    numPts = length(find(viewMask{2}(:,:,ii)));
    numOverlapPts = length(find(projectionOverlap));
    
    overlapFract(ii) = numOverlapPts / numPts;
    if overlapFract(ii) > minOverlap
        validOverlap(ii) = true;
    end
end