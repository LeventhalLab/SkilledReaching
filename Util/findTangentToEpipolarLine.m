function [tangentPoints, tangentLines] = findTangentToEpipolarLine(mask, fundmat, bbox)
%
% INPUTS:
%   mask -
%   fundmat - 
%   bbox - 
%
% OUTPUTS:

mask_ext = bwmorph(mask,'remove');
s = regionprops(mask,'Centroid');

[y,x] = find(mask_ext);
num_pts = length(x);

ext_pts = sortClockWise(s.Centroid,[x,y]);
ext_pts = bsxfun(@plus,ext_pts, bbox(1:2)-1);

tangentPoints = zeros(2,2);
tangentLines  = zeros(2,3);

epiLines = epipolarLine(fundmat, ext_pts);

tangentPointsFound = 0;
for ii = 1 : num_pts

	lineValue = epiLines(ii,1) * ext_pts(:,1) + ...
                epiLines(ii,2) * ext_pts(:,2) + epiLines(ii,3);
            
	[intersect_idx, isLocalExtremum] = detectCircularZeroCrossings(lineValue);
    
%     if length(intersect_idx) == 1
    if all(isLocalExtremum(intersect_idx))
        tangentPointsFound = tangentPointsFound + 1;
        
        tangentPoints(tangentPointsFound,:) = ext_pts(ii,:);
        tangentLines(tangentPointsFound,:) = epiLines(ii,:);
    end
end

while tangentPointsFound > 2
    % more than one edge point lies on one of the tangent epipolar lines
    % find the ones that are redundant and get rid of them
    
    linesDiff = diff(tangentLines,1);
    linesDist = sqrt(sum(linesDiff.^2,2));
    
    minDistIdx = find(linesDist == min(linesDist));
    
    tangentLines = removeRow(tangentLines, minDistIdx);
    tangentPoints = removeRow(tangentPoints, minDistIdx);
    
    tangentPointsFound = tangentPointsFound - 1;
end