function [direct_mask_b, mirror_mask_b] = matchSilhouettes(direct_mask, mirror_mask, fundmat, bboxes, imSize)
%
% INPUTS:
%
% OUTPUTS:
%

tangentPoints = zeros(2,2,2);    % mxnxp where m is number of points, n is (x,y), p is the view index (1 for direct, 2 for mirror)
tangentLines = zeros(2,3,2);     % mxnxp where m is number of points, n is (A,B,C), p is the view index (1 for direct, 2 for mirror)
epiPts = zeros(2,4,2);           % mxnxp where m is number of points, n is (x1,y1,x2,y2), p is the view index (1 for direct, 2 for mirror)
matchLineIdx = zeros(2,2);       % mxn where m is upper vs lower line (idx 1 for upper, 2 for lower), n is the view idx (1 = direct, 2 = mirror)

interiorMask = zeros(1,2);       % first element is whether the direct or mirror (1 or 2 respectively) views are intersected by the other view's upper tangent line;
                                 % second element is whether the direct or mirror (1 or 2 respectively) views are intersected by the other view's lower tangent line
mask_ext = cell(1,2);
ext_pts = cell(1,2);

mask_ext{1} = bwmorph(direct_mask,'remove');
mask_ext{2} = bwmorph(mirror_mask,'remove');

for iView = 1 : 2
    [y,x] = find(mask_ext{iView});
    s = regionprops(mask_ext{iView},'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
    ext_pts{iView} = bsxfun(@plus,ext_pts{iView}, bboxes(iView,1:2));
end

[tangentPoints(:,:,1), tangentLines(:,:,1)] = findTangentToEpipolarLine(direct_mask, fundmat, bboxes(1,:));
[tangentPoints(:,:,2), tangentLines(:,:,2)] = findTangentToEpipolarLine(mirror_mask, fundmat', bboxes(2,:));

iView = 1;
otherViewIdx = 3 - iView;

epiPts(:,:,iView) = lineToBorderPoints(tangentLines(:,:,iView), imSize);
matchLineIdx(1,iView) = find(epiPts(:,2,iView) == min(epiPts(:,2,iView)));
matchLineIdx(2,iView) = find(epiPts(:,2,iView) == max(epiPts(:,2,iView)));

for ii = 1 : 2    % upper and lower tangent lines for each view

    lineValue = tangentLines(matchLineIdx(ii,iView),1,iView) * ext_pts{otherViewIdx}(:,1) + ...
                tangentLines(matchLineIdx(ii,iView),2,iView) * ext_pts{otherViewIdx}(:,2) + ...
                tangentLines(matchLineIdx(ii,iView),3,iView);

    intersect_idx = detectZeroCrossings(lineValue);
    switch length(intersect_idx)
        case 0,    % this tangent line from one view does not intersect the blob in the other view
            interiorMask(ii) = iView;
        case 1,    % this tangent line from one view is also a tangent line in the other view
            interiorMask(ii) = 0;
        case 2,    % this tangent line from one view cuts through the blob in the other view
            interiorMask(ii) = otherViewIdx;
    end
        
            
        
end

% check the upper tangent lines first to see which intersects the other
% blob



end