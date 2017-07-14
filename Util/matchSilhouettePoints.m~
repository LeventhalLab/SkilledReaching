function matchedPoints = matchSilhouettePoints(masks, boxCalibration, bboxes, tangentPoints, imSize)
%
% usage:
%
% INPUTS:
%   masks - cell array of paw masks. These masks could be small regions of
%       a larger image defined by bboxes (see below).
%       1 = direct view, 2 = mirror view
%   boxCalibration - standard box calibration structure
%   bboxes - location of windows containing the direct and mirror paw masks
%
% OUTPUTS:
%   matchedPoints - 

K = boxCalibration.cameraParams.IntrinsicMatrix;
P1 = eye(4,3);
mask_ext = cell(1,2);
full_mask = cell(1,2);
ext_pts = cell(1,2);

for iView = 1 : 2
    full_mask{iView} = false(imSize);
    full_mask{iView}(bboxes(iView,2):bboxes(iView,2) + bboxes(iView,4), ...
                     bboxes(iView,1):bboxes(iView,1) + bboxes(iView,3)) = masks{iView};
                     
    mask_ext{iView} = bwmorph(full_mask{iView},'remove');
    
    [y,x] = find(mask_ext{iView});
    s = regionprops(mask_ext{iView},'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
%     ext_pts{iView} = bsxfun(@plus,ext_pts{iView}, bboxes(iView,1:2));
end

% find the region in between the lines connecting the tangentPoints for the
% direct and mirror view blobs
full_tanPts = bsxfun(@plus,squeeze(tangentPoints(:,:,1)),bboxes(1,1:2));
direct_leftRegion = segregateImage(full_tanPts, ...
                            [round(imSize(1)/2),1], imSize);
direct_rightRegion = segregateImage(full_tanPts, ...
                            [round(imSize(1)/2),imSize(2)], imSize);

full_tanPts = bsxfun(@plus,squeeze(tangentPoints(:,:,2)),bboxes(2,1:2));
mirror_leftRegion = segregateImage(full_tanPts, ...
                            [round(imSize(1)/2),1], imSize);
mirror_rightRegion = segregateImage(full_tanPts, ...
                            [round(imSize(1)/2),imSize(2)], imSize);
overlapCheck = full_mask{2} & direct_leftRegion;
if any(overlapCheck(:))
    interiorRegion = direct_leftRegion & mirror_rightRegion;
    exteriorRegion = direct_rightRegion | mirror_leftRegion;
    fundmat = boxCalibration.F.left;
    P2 = boxCalibration.P.left;
    scale3D = boxCalibration.scale(1);
else
    interiorRegion = direct_rightRegion & mirror_leftRegion;
    exteriorRegion = direct_leftRegion | mirror_rightRegion;
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
    
    % A COUPLE OF IDEAS HERE: ADD INTERPOLATION TO MAKE THE POINT MATCHNG
    % SMOOTHER, OR MATCH POINTS GOING IN BOTH DIRECTIONS THEN SOMEHOW MELD
    % THE TWO TOGETHER
    
    switch length(intersect_idx)
        case 0
            % will have to find point closest to the tangent line in the
            % mirror view
        case 1
            matchedPoints(ii,:,2) = ext_pts{2}(intersect_idx,:);
        case 2
            % figure out which of the two intersecting points is on the
            % right side to match with the current direct view point
            tempMask = false(imSize);
            tempMask(ext_pts{1}(ii,2),ext_pts{1}(ii,1)) = true;
            overlapCheck = tempMask & interiorRegion;
            
            % calculate distance from each intersection point in the mirror
            % view to the index point in the direct view
            candidate_pts = ext_pts{2}(intersect_idx,:);
            candidate_dist = bsxfun(@minus,candidate_pts,ext_pts{1}(ii,:));
            candidate_dist = sqrt(sum(candidate_dist.^2,2));
            if any(overlapCheck(:))
                % take the candidate point closest to the current point
                matched_pt_idx = find(candidate_dist == min(candidate_dist));
            else
                % take the candidate point farthest from the current point
                matched_pt_idx = find(candidate_dist == max(candidate_dist));
            end
            matchedPoints(ii,:,2) = candidate_pts(matched_pt_idx,:);
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