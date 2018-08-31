function [pawTrajectory, bodyparts] = calc3D_DLC_trajectory(direct_pts, mirror_pts, direct_bp, mirror_bp, direct_p, mirror_p, ROIs, K, Pn, scaleFactor)
%
% INPUTS:
%   direct_pts, mirror_pts - number of body parts x number of frames x 2
%       array
%   direct_bp, mirror_bp - cell arrays containing lists of body parts
%       descriptors
%   direct_p, mirror_p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   ROIs - 2 x 4 array where each row is a [left,top,width,height] vector
%       defining a rectangular region of interest. First row is the direct
%       view, second row is the mirror view
%   K
%   Pn
%   scaleFactor
%
%   boxCal - box calibration structure with the following fields:
%       .E - essential matrix (3 x 3 x numViews) array where numViews is
%           the number of different mirror views (3 for now)
%       .F - fundamental matrix (3 x 3 x numViews) array where numViews is
%           the number of different mirror views (3 for now)
%       .Pn - camera matrices assuming the direct view is eye(4,3). 4 x 3 x
%           numViews array
%       .P - direct camera matrix (eye(4,3))
%       .cameraParams
%       .curDate - YYYYMMDD format date the data were collected
%       
% OUTPUTS:
%

% assume that direct and mirror body part labels are the same

numFrames = size(direct_pts, 2);

% match body parts between direct and mirror views
mirror_bpMatch_idx = zeros(length(direct_bp),1);
num_direct_bp = length(direct_bp);
for i_bp = 1 : num_direct_bp
    
    if isempty(strcmpi(mirror_bp, direct_bp{i_bp}))
        continue;
    end
    mirror_bpMatch_idx(i_bp) = find(strcmpi(mirror_bp, direct_bp{i_bp}));
    
end

[mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
[direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);

pawTrajectory = zeros(numFrames, 3, num_direct_bp);
P = eye(4,3);
for i_direct_bp = 1 : num_direct_bp
        
%     if direct_invalid_points(i_direct_bp) || ...
%        mirror_invalid_points(mirror_bpMatch_idx(i_direct_bp))
%         % either the direct view point or the mirror view point wasn't
%         % properly identified
% 
%         continue;
%     end

    cur_direct_pts = squeeze(direct_pts(i_direct_bp, :, :));
    cur_mirror_pts = squeeze(mirror_pts(mirror_bpMatch_idx(i_direct_bp), :, :));

    % adjust for the region of interest from which the cropped videos
    % were pulled
    cur_direct_pts(:,1) = cur_direct_pts(:,1) + ROIs(1,1) - 1;
    cur_direct_pts(:,2) = cur_direct_pts(:,2) + ROIs(1,2) - 1;
    cur_mirror_pts(:,1) = cur_mirror_pts(:,1) + ROIs(2,1) - 1;
    cur_mirror_pts(:,2) = cur_mirror_pts(:,2) + ROIs(2,2) - 1;

    direct_hom = [cur_direct_pts, ones(size(cur_direct_pts,1),1)];
    direct_norm = (K' \ direct_hom')';
    direct_norm = bsxfun(@rdivide,direct_norm(:,1:2),direct_norm(:,3));

    mirror_hom = [cur_mirror_pts, ones(size(cur_mirror_pts,1),1)];
    mirror_norm = (K' \ mirror_hom')';
    mirror_norm = bsxfun(@rdivide,mirror_norm(:,1:2),mirror_norm(:,3));

    [wpts, ~]  = triangulate_DL(direct_norm, mirror_norm, P, Pn);
    
    pawTrajectory(:, :, i_direct_bp) = wpts * scaleFactor;
end