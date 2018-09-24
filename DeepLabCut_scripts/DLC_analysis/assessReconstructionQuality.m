function pawTrackingAssessment = assessReconstructionQuality(pawTrajectory, direct_pt, mirror_pt, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, ROIs, boxCal, pawPref)
%
% INPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart

%   direct_pt, mirror_pt - m x 2 matrices
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
%   pawTrackingAssessment - structure with the following fields:

% calculate percentage of high probability points in mirror/direct views
% labeled invalid
p_cutoff = 0.9;
high_p_direct = direct_p > p_cutoff;
high_p_mirror = mirror_p > p_cutoff;

[mirror_invalid_points, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p);
[direct_invalid_points, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p);
            
high_p_direct_invalid = high_p_direct & direct_invalid_points;
high_p_mirror_invalid = high_p_mirror & mirror_invalid_points;

% calculate distance between reconstructed points and originally identified
% points in the direct and mirror views
numFrames = size(pawTrajectory, 1);

switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        sf = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        sf = mean(boxCal.scaleFactor(3,:));
end
for iFrame = 1 : numFrames
    for i_bodypart = 1 : length(bodyparts)
        
        currentPt = squeeze(pawTrajectory(iFrame,:,i_bodypart));