function [reproj_error,high_p_invalid] = assessReconstructionQuality(pawTrajectory, direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, ROIs, boxCal, pawPref)
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
%   pawPref - 
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

% calculate percentage of high probability points in mirror/direct views
% labeled invalid
p_cutoff = 0.9;
high_p_direct = direct_p > p_cutoff;
high_p_mirror = mirror_p > p_cutoff;

K = boxCal.cameraParams.IntrinsicMatrix;
numFrames = size(pawTrajectory, 1);

[mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
[direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);
            
high_p_invalid = false(length(bodyparts), numFrames, 2);
high_p_invalid(:,:,1) = high_p_direct & direct_invalid_points;
high_p_invalid(:,:,2) = high_p_mirror & mirror_invalid_points;

% calculate distance between reconstructed points and originally identified
% points in the direct and mirror views


switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        sf = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        sf = mean(boxCal.scaleFactor(3,:));
end

reproj_error = NaN(length(bodyparts),numFrames, 2, 2);    % for each frame, difference in x,y coordinates between the
                                        % the 3-D reprojection and the
                                        % originally identified points in
                                        % the direct (last index 1) and
                                        % mirror (last index 2) views
for i_bodypart = 1 : length(bodyparts)
    for iFrame = 1 : numFrames
        
        bpName = bodyparts{i_bodypart};
        direct_bp_idx = strcmpi(direct_bp, bpName);
        mirror_bp_idx = strcmpi(mirror_bp, bpName);
        
        currentPt = squeeze(pawTrajectory(iFrame,:,i_bodypart));
        if all(currentPt == 0)
            continue;   % point wasn't triangulated due to uncertainty in at least one view
        end
        
        currentPt = currentPt / sf;
        % reproject this point into the direct view
        currPt_direct = projectPoints_DL(currentPt, boxCal.P);
        currPt_direct = unnormalize_points(currPt_direct,K);

        % reproject this point into the mirror view
        currPt_mirror = projectPoints_DL(currentPt, Pn);
        currPt_mirror = unnormalize_points(currPt_mirror,K);
        
        % adjust mirror points for the region of interest location used to
        % extract the DLC test videos
        measured_direct_pt = squeeze(direct_pts(direct_bp_idx,iFrame,:))';
        measured_direct_pt = measured_direct_pt + ROIs(1,1:2) - 1;
        measured_direct_pt = undistortPoints(measured_direct_pt, boxCal.cameraParams);
        
        measured_mirror_pt = squeeze(mirror_pts(mirror_bp_idx,iFrame,:))';
        measured_mirror_pt = measured_mirror_pt + ROIs(2,1:2) - 1;
        measured_mirror_pt = undistortPoints(measured_mirror_pt, boxCal.cameraParams);
        
        reproj_error(i_bodypart, iFrame,:,1) = currPt_direct - measured_direct_pt;
        reproj_error(i_bodypart, iFrame,:,2) = currPt_mirror - measured_mirror_pt;
    end
end