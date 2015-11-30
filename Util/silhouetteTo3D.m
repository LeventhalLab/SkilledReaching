function edge3D = silhouetteTo3D(masks, boxCalibration, bboxes, tangentPoints, imSize, fullPawMasks)
%
% INPUTS:
%   masks - 2-element cell array - first index is the direct view, second
%       index is the mirror view
%   boxCalibration - boxCalibration structure
%   bboxes - 2 x 4 array, where each row is the bounding box for the direct
%       (1st row) and mirror (2nd row) views
%   tangentPoints - 
% OUTPUTS:
% 
K = boxCalibration.cameraParams.IntrinsicMatrix;
P1 = eye(4,3);
mask_ext = cell(1,2);
full_mask = cell(1,2);
ext_pts = cell(1,2);
full_tanPts = zeros(2,2,2);
tanLineCoeff = zeros(2,3);
for iView = 1 : 2
    full_mask{iView} = false(imSize);
    full_mask{iView}(bboxes(iView,2):bboxes(iView,2) + bboxes(iView,4), ...
                     bboxes(iView,1):bboxes(iView,1) + bboxes(iView,3)) = masks{iView};
                     
    mask_ext{iView} = bwmorph(full_mask{iView},'remove');
    
    [y,x] = find(mask_ext{iView});
    s = regionprops(mask_ext{iView},'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
%     ext_pts{iView} = bsxfun(@plus,ext_pts{iView}, bboxes(iView,1:2));
    full_tanPts(:,:,iView) = bsxfun(@plus,squeeze(tangentPoints(:,:,iView)),bboxes(iView,1:2));
    tanLineCoeff(iView,:) = lineCoeffFromPoints(squeeze(full_tanPts(:,:,iView)));
end
ext_pts{2} = flipud(ext_pts{2});   % now these points are sorted in the clockwise direction

% find the region in between the lines connecting the tangentPoints for the
% direct and mirror view blobs

% direct_lineCoeff = lineCoeffFromPoints(full_tanPts);
direct_leftRegion = segregateImage(full_tanPts, ...
                            [round(imSize(1)/2),1], imSize);
% direct_rightRegion = segregateImage(full_tanPts, ...
%                             [round(imSize(1)/2),imSize(2)], imSize);

% mirror_lineCoeff = lineCoeffFromPoints(full_tanPts);
% mirror_leftRegion = segregateImage(full_tanPts, ...
%                             [round(imSize(1)/2),1], imSize);
% mirror_rightRegion = segregateImage(full_tanPts, ...
%                             [round(imSize(1)/2),imSize(2)], imSize);
overlapCheck = full_mask{2} & direct_leftRegion;
if any(overlapCheck(:))
%     interiorRegion = direct_leftRegion & mirror_rightRegion;
%     exteriorRegion = direct_rightRegion | mirror_leftRegion;
    fundmat = boxCalibration.F.left;
    P2 = boxCalibration.P.left;
    scale3D = boxCalibration.scale(1);
else
%     interiorRegion = direct_rightRegion & mirror_leftRegion;
%     exteriorRegion = direct_leftRegion | mirror_rightRegion;
    fundmat = boxCalibration.F.right;
    P2 = boxCalibration.P.right;
    scale3D = boxCalibration.scale(2);
end

epiLines = epipolarLine(fundmat, ext_pts{1});   % start with the direct view
% epiPts   = lineToBorderPoints(epiLines, imSize);

numDirectEdgePoints = size(epiLines,1);
matchedPoints = zeros(numDirectEdgePoints,2,2);
matchedPoints(:,:,1) = ext_pts{1};

for ii = 1 : numDirectEdgePoints
    
	lineValue = epiLines(ii,1) * ext_pts{2}(:,1) + ...
                epiLines(ii,2) * ext_pts{2}(:,2) + epiLines(ii,3);
% 	lineValue_direct = epiLines(ii,1) * ext_pts{1}(:,1) + ...
%                 epiLines(ii,2) * ext_pts{1}(:,2) + epiLines(ii,3);
            
	intersect_idx = detectZeroCrossings(lineValue);
    

    % find location of intersection between current epipolar line and the
    % line connecting the tangent points in the mirror and direct views
    tangentIntersect_mirror = findIntersection(epiLines(ii,:),tanLineCoeff(2,:));
    tangentIntersect_direct = findIntersection(epiLines(ii,:),tanLineCoeff(1,:));
    tanLinesDist = norm(tangentIntersect_mirror - tangentIntersect_direct);
    
    % is the current point on the near side or far side of the tangent line
    % in the direct view?
    direct_pt_to_mirror_tan = norm(ext_pts{1}(ii,:) - tangentIntersect_mirror);
    if direct_pt_to_mirror_tan < tanLinesDist
        % current point is on near side
        pt_on_near_side = true;
    else
        % current point is on far side
        pt_on_near_side = false;
    end
    
    % A COUPLE OF IDEAS HERE: ADD INTERPOLATION TO MAKE THE POINT MATCHNG
    % SMOOTHER, OR MATCH POINTS GOING IN BOTH DIRECTIONS THEN SOMEHOW MELD
    % THE TWO TOGETHER
    
    switch length(intersect_idx)
        case 0,
            % no intersections - must be one of the tangent points that
            % match
            epiPts = lineToBorderPoints(epiLines(ii,:), imSize);
            epiPts = reshape(epiPts,[2 2])';
%             dist_to_tan_points = zeros(1,2);
%             for itanPt = 1 : 2
%                 dist_to_tan_points(itanPt) = distanceToLine(epiPts(1:2), epiPts(3:4), ...
%                                                             squeeze(full_tanPts(itanPt,:,2)));
%             end
%             nearestTanPt_idx = (dist_to_tan_points == min(dist_to_tan_points));
            [~,nearestTanPt_idx] = findNearestPointToLine(epiPts, squeeze(full_tanPts(:,:,2)));
            matchedPoints(ii,:,2) = full_tanPts(nearestTanPt_idx,:,2);
                                               
        case 1,
            matchedPoints(ii,:,2) = ext_pts{2}(intersect_idx,:);
        case 2,
            % figure out which of the two intersecting points is on the
            % right side to match with the current direct view point
%             tempMask = false(imSize);
%             tempMask(ext_pts{1}(ii,2),ext_pts{1}(ii,1)) = true;
%             overlapCheck = tempMask & interiorRegion;
            
            % calculate distance from each intersection point in the mirror
            % view to the index point in the direct view
            candidate_pts = ext_pts{2}(intersect_idx,:);
            candidate_dist = bsxfun(@minus,candidate_pts,ext_pts{1}(ii,:));
            candidate_dist = sqrt(sum(candidate_dist.^2,2));
            if pt_on_near_side
                % take the candidate point closest to the current point
                matched_pt_idx = find(candidate_dist == min(candidate_dist));
            else
                % take the candidate point farthest from the current point
                matched_pt_idx = find(candidate_dist == max(candidate_dist));
            end
            matchedPoints(ii,:,2) = candidate_pts(matched_pt_idx,:);
        otherwise,
            % first, figure out which candidate points are correct side of
            % the tangent line
            candidate_pts = ext_pts{2}(intersect_idx,:);
            candidate_dist = bsxfun(@minus,candidate_pts,tangentIntersect_direct);
            candidate_dist = sqrt(sum(candidate_dist.^2,2));
            
            if pt_on_near_side
                validIdx = find(candidate_dist < tanLinesDist);
            else
                validIdx = find(candidate_dist > tanLinesDist);
            end
            
            % the candidate point farthest from the line connecting the
            % tangent points should be the true "edge" point
%             epiPts = lineToBorderPoints(epiLines(ii,:), imSize);
%             epiPts = reshape(epiPts,[2 2])';
            [~,farthestPt_idx] = findFarthestPointFromLine(squeeze(full_tanPts(:,:,2)), candidate_pts(validIdx,:));
            matchedPoints(ii,:,2) = candidate_pts(farthestPt_idx,:);
    end
    
end

% for ii = 1 : numMirrorEdgePoints
%     % MATCH POINTS GOING IN BOTH DIRECTIONS THEN SOMEHOW MELD
%     % THE TWO TOGETHER
%     
% end
direct_pts_norm = normalize_points(squeeze(matchedPoints(:,:,1)), K);
mirror_pts_norm = normalize_points(squeeze(matchedPoints(:,:,2)), K);

[points3d,~,~] = triangulate_DL(direct_pts_norm, ...
                                mirror_pts_norm, ...
                                P1, P2);
                            
edge3D = points3d * scale3D;

% how to make sure the gaps get filled in in the 3D reconstruction by
% making the point matching algorithm cleaner?

end