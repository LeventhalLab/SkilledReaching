function [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, final_direct_pts, final_mirror_pts, direct_p, mirror_p, invalid_direct, invalid_mirror, direct_bp, mirror_bp, bodyparts, boxCal, pawPref, varargin)
%
% INPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   direct_pts, mirror_pts - num_bodyparts x num_frames x 2 matrices
%       containing (x,y) coordinates of each bodypart in each frame
%   direct_p, mirror_p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   direct_bp, mirror_bp - 
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   isPointValid - 2-element cell array containing boolean vectors 
%       indicating whether each body part was deemed a valid point (true = 
%       valid). 1st array is for direct view, second array for mirror
%       view
%   ROIs - 2 x 4 array containing the ROI boundaries of the videos
%       input to DLC (note, these are distorted - prior to undistortion)
%       frames. Each row is [left, top, width, height]. First row for
%       direct view, second row for mirror view relevant to the reaching
%       paw (left mirror for right paw and vice versa)
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
%   pawPref - 'left' or 'right'
%
%
% VARARGS:
%   pcutoff - p-value to use as a cutoff for high vs low probability points
%
% OUTPUTS:
%   reproj_error - num_bodyparts x numFrames x 2 x 2 array where
%       reproj_error(bodypart,frame,:,1) is the difference in x,y
%       coordinates between the reprojected 3D point and originally
%       measured direct view poiint. reproj_error(bodypart,frame,:,2) is
%       the same for the mirror view
%   high_p_invalid - num_bodyparts x numFrames x 2 boolean array where true
%       entries indicate that DLC thought the point was identified with
%       high probability but the find_invalid_DLC_points function declared
%       it invalid
%   low_p_valid - num_bodyparts x numFrames x 2 boolean array where true
%       entries indicate that DLC thought the point was identified with
%       low probability but the find_invalid_DLC_points function declared
%       it valid

% calculate percentage of high probability points in mirror/direct views
% labeled invalid
p_cutoff = 0.9;

for iarg = 1 : 2 : nargin - 12
    switch lower(varargin{iarg})
        case 'pcutoff'
            p_cutoff = varargin{iarg + 1};
    end
end

high_p_direct = direct_p > p_cutoff;
high_p_mirror = mirror_p > p_cutoff;

numFrames = size(pawTrajectory, 1);
num_bp = size(pawTrajectory,3);
% [mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
% [direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);
            
high_p_invalid = false(length(bodyparts), numFrames, 2);
high_p_invalid(:,:,1) = high_p_direct & invalid_direct;
high_p_invalid(:,:,2) = high_p_mirror & invalid_mirror;

low_p_valid = false(length(bodyparts), numFrames, 2);
low_p_valid(:,:,1) = ~high_p_direct & ~invalid_direct;
low_p_valid(:,:,2) = ~high_p_mirror & ~invalid_mirror;

% calculate distance between reconstructed points and originally identified
% points in the direct and mirror views
K = boxCal.cameraParams.IntrinsicMatrix;
switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        sf = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        sf = mean(boxCal.scaleFactor(3,:));
end
unscaled_trajectory = pawTrajectory / sf;
reproj_error = zeros(num_bp,numFrames,2);

for i_bp = 1 : num_bp
    
    bpName = bodyparts{i_bp};
    direct_bp_idx = strcmpi(direct_bp, bpName);
    mirror_bp_idx = strcmpi(mirror_bp, bpName);

    current3D = squeeze(unscaled_trajectory(:,:,i_bp));
    
    direct_proj = projectPoints_DL(current3D, boxCal.P);
    direct_proj = unnormalize_points(direct_proj,K);
    cur_direct_pts = squeeze(final_direct_pts(direct_bp_idx,:,:));
    direct_error = direct_proj - cur_direct_pts;
    
    mirror_proj = projectPoints_DL(current3D, Pn);
    mirror_proj = unnormalize_points(mirror_proj,K);
    cur_mirror_pts = squeeze(final_mirror_pts(mirror_bp_idx,:,:));
    mirror_error = mirror_proj - cur_mirror_pts;
    
    reproj_error(i_bp,:,1) = sqrt(sum(direct_error.^2,2));
    reproj_error(i_bp,:,2) = sqrt(sum(mirror_error.^2,2));
end
    
% reproj_error = calculatePawReprojectionErrors(pawTrajectory, direct_pts, mirror_pts, bodyparts, direct_bp, mirror_bp, pawPref, boxCal, ROIs);

