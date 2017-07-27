function edge3D = bordersTo3D(ext_pts, boxCalibration, bboxes, tangentPoints, imSize)
%
%
% NEED TO ADD IN A CHECK THAT WE DON'T IDENTIFY POINTS BELOW THE FLOOR, AND
% ELIMINATE ANY PAIRED POINTS THAT WOULD DO SO (WOULD LIKELY COME FROM
% DETECTING REFLECTIONS IN THE FLOOR)
%
%
% INPUTS:
%   masks - 2-element cell array - first index is the direct view, second
%       index is the mirror view
%   boxCalibration - boxCalibration structure
%   bboxes - 2 x 4 array, where each row is the bounding box for the direct
%       (1st row) and mirror (2nd row) views
%   tangentPoints - 
% OUTPUTS:
%   edge3D - m x 3 array where each row is a (x,y,z) coordinate of a
%       triangulated point in real world mm. The origin is at the camera
%       center; x is horizontal, y is vertical, z is depth

K = boxCalibration.cameraParams.IntrinsicMatrix;
P1 = eye(4,3);
full_mask = cell(1,2);
full_tanPts = zeros(2,2,2);
tanLineCoeff = zeros(2,3);
for iView = 1 : 2
%     full_mask{iView} = false(imSize);
%     full_mask{iView}(bboxes(iView,2):bboxes(iView,2) + bboxes(iView,4), ...
%                      bboxes(iView,1):bboxes(iView,1) + bboxes(iView,3)) = masks{iView};
%                      
%     mask_ext{iView} = bwmorph(full_mask{iView},'remove');
%     
%     [y,x] = find(mask_ext{iView});
%     s = regionprops(mask_ext{iView},'Centroid');
%     ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
%     ext_pts{iView} = bsxfun(@plus,ext_pts{iView}, bboxes(iView,1:2));
    full_tanPts(:,:,iView) = bsxfun(@plus,squeeze(tangentPoints(:,:,iView)),(bboxes(iView,1:2)-1));
    tanLineCoeff(iView,:) = lineCoeffFromPoints(squeeze(full_tanPts(:,:,iView)));
end
% ext_pts{2} = flipud(ext_pts{2});   % now these points are sorted in the clockwise direction

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
testMask = false(imSize);
testMask(ext_pts{2}(:,2),ext_pts{2}(:,1)) = true;
overlapCheck = testMask & direct_leftRegion;
if any(overlapCheck(:))
%     interiorRegion = direct_leftRegion & mirror_rightRegion;
%     exteriorRegion = direct_rightRegion | mirror_leftRegion;
    fundmat = squeeze(boxCalibration.srCal.F(:,:,1));
    P2 = squeeze(boxCalibration.srCal.P(:,:,1));
    scale3D = mean(boxCalibration.srCal.sf(:,1));
else
%     interiorRegion = direct_rightRegion & mirror_leftRegion;
%     exteriorRegion = direct_leftRegion | mirror_rightRegion;
    fundmat = squeeze(boxCalibration.srCal.F(:,:,2));
    P2 = squeeze(boxCalibration.srCal.P(:,:,2));
    scale3D = mean(boxCalibration.srCal.sf(:,2));
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
            
	[intersect_idx, isLocalExtremum] = detectCircularZeroCrossings(lineValue);
    % WORKING HERE - JUST CHANGED DETECTZEROCROSSINGS TO THE CIRCULAR
    % VERSION IN THE LINE ABOVE...

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
    
%     switch length(intersect_idx)
%         case 0,
        if ~any(intersect_idx)
            % no intersections - must be one of the tangent points that
            % match
            
            
            % TO DO HERE - TRY IGNORING POINTS THAT DON'T HAVE A MATCH IN
            % THE OTHER VIEW, AND SAVE THEM FOR LATER ONCE WE HAVE A
            % PARTIAL 3D RECONSTRUCTION?
            
            
            
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
                                               
        elseif all(intersect_idx & isLocalExtremum)
            matchedPoints(ii,:,2) = ext_pts{2}(intersect_idx,:);
        else
            % figure out which of the two intersecting points is on the
            % right side to match with the current direct view point
%             tempMask = false(imSize);
%             tempMask(ext_pts{1}(ii,2),ext_pts{1}(ii,1)) = true;
%             overlapCheck = tempMask & interiorRegion;
            
%             % calculate distance from each intersection point in the mirror
%             % view to the index point in the direct view
%             candidate_pts = ext_pts{2}(intersect_idx,:);
%             candidate_dist = bsxfun(@minus,candidate_pts,ext_pts{1}(ii,:));
%             candidate_dist = sqrt(sum(candidate_dist.^2,2));
%             if pt_on_near_side
%                 % take the candidate point closest to the current point
%                 matched_pt_idx = find(candidate_dist == min(candidate_dist));
%             else
%                 % take the candidate point farthest from the current point
%                 matched_pt_idx = find(candidate_dist == max(candidate_dist));
%             end
%             matchedPoints(ii,:,2) = candidate_pts(matched_pt_idx,:);
%         otherwise,
            % first, figure out which candidate points are correct side of
            % the tangent line
            candidate_pts = ext_pts{2}(intersect_idx,:);
            candidate_dist = bsxfun(@minus,candidate_pts,tangentIntersect_direct);
            candidate_dist = sqrt(sum(candidate_dist.^2,2));
            
            if pt_on_near_side
                validIdx = find(candidate_dist < tanLinesDist);
                if isempty(validIdx)
                    validIdx = find(candidate_dist == min(candidate_dist));
                end
            else
                validIdx = find(candidate_dist > tanLinesDist);
                if isempty(validIdx)
                    validIdx = find(candidate_dist == max(candidate_dist));
                end
            end
            
            % the candidate point farthest from the line connecting the
            % tangent points should be the true "edge" point
%             epiPts = lineToBorderPoints(epiLines(ii,:), imSize);
%             epiPts = reshape(epiPts,[2 2])';
            try
                [~,farthestPt_idx] = findFarthestPointFromLine(squeeze(full_tanPts(:,:,2)), candidate_pts(validIdx,:));
            catch
                keyboard
            end
            matchedPoints(ii,:,2) = candidate_pts(validIdx(farthestPt_idx),:);
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