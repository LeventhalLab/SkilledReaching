function [tangentPoints, tangentLines] = findTangentToEpipolarLine(mask, fundmat, bbox)
%
% INPUTS:
%
% OUTPUTS:

mask_ext = bwmorph(mask,'remove');
s = regionprops(mask,'Centroid');

[y,x] = find(mask_ext);
num_pts = length(x);

ext_pts = sortClockWise(s.Centroid,[x,y]);
ext_pts = bsxfun(@plus,ext_pts, bbox(1:2));

tangentPoints = zeros(2,2);
tangentLines  = zeros(2,3);

epiLines = epipolarLine(fundmat, ext_pts);

tangentPointsFound = 0;
for ii = 1 : num_pts

	lineValue = epiLines(ii,1) * ext_pts(:,1) + ...
                epiLines(ii,2) * ext_pts(:,2) + epiLines(ii,3);
            
	intersect_idx = detectZeroCrossings(lineValue);
    
    if length(intersect_idx) == 1
        tangentPointsFound = tangentPointsFound + 1;
        
        tangentPoints(tangentPointsFound,:) = ext_pts(ii,:);
        tangentLines(tangentPointsFound,:) = epiLines(ii,:);
    end
end