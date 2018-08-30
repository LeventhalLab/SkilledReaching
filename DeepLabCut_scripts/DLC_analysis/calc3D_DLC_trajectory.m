function pawTrajectory = calc3D_DLC_trajectory(direct_pts, mirror_pts, direct_bp, mirror_bp, ROIs, boxCal)
%
% INPUTS:
%   direct_pts, mirror_pts - number of body parts x number of frames x 2
%       array
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
for i_bp = 1 : length(direct_bp)
    
    mirror_bpMatch_idx(i_bp) = find