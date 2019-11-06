function [pawTrajectory, bodyparts] = calc3Dpoints(final_direct_pts, final_mirror_pts, isEstimate, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, pawPref)

cameraParams = boxCal.cameraParams;
K = cameraParams.IntrinsicMatrix;

numFrames = size(final_direct_pts,2);

switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        scaleFactor = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        scaleFactor = mean(boxCal.scaleFactor(3,:));
end

[bodyparts,direct_bpMatch_idx,mirror_bpMatch_idx] = matchBodyPartIndices(direct_bp,mirror_bp);
numValid_bp = length(bodyparts);

pawTrajectory = zeros(numFrames, 3, numValid_bp);
P = eye(4,3);
for i_bp = 1 : numValid_bp

    % only make calculations for points that are valid
    valid_direct = ~invalid_direct(i_bp,:);valid_mirror = ~invalid_mirror(i_bp,:);
    estimate_direct = squeeze(isEstimate(i_bp,:,1));estimate_mirror = squeeze(isEstimate(i_bp,:,2));
    
    validPoints = (valid_direct & valid_mirror) | ...
                  (valid_direct & estimate_mirror) | ...
                  (valid_mirror & estimate_direct);
    
	% if there are no validPoints for this bodypart, skip this bodypart
    if ~any(validPoints)
        continue;
    end
    
    cur_direct_pts = squeeze(final_direct_pts(direct_bpMatch_idx(i_bp),validPoints, :));
    cur_mirror_pts = squeeze(final_mirror_pts(mirror_bpMatch_idx(i_bp),validPoints, :));
    
    cur_direct_pts(isnan(cur_direct_pts)) = 0;
    cur_mirror_pts(isnan(cur_mirror_pts)) = 0;
    
    if sum(validPoints) == 1    % only one validPoint, cur_pts arrays come out as column vectors instead of row vectors
        cur_direct_pts = cur_direct_pts';
        cur_mirror_pts = cur_mirror_pts';
    end

    direct_hom = [cur_direct_pts, ones(size(cur_direct_pts,1),1)];
    direct_norm = (K' \ direct_hom')';
    direct_norm = bsxfun(@rdivide,direct_norm(:,1:2),direct_norm(:,3));

    mirror_hom = [cur_mirror_pts, ones(size(cur_mirror_pts,1),1)];
    mirror_norm = (K' \ mirror_hom')';
    mirror_norm = bsxfun(@rdivide,mirror_norm(:,1:2),mirror_norm(:,3));

    [wpts, ~]  = triangulate_DL(direct_norm, mirror_norm, P, Pn);
    
    pawTrajectory(validPoints, :, i_bp) = wpts * scaleFactor;
end