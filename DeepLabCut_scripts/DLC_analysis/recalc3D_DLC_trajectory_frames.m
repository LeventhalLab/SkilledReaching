function [final_direct_pts, final_mirror_pts, isEstimate] = recalc3D_DLC_trajectory_frames(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, imSize, frames_to_recalculate, boxCal, pawPref, varargin)
%
% INPUTS:
%   final_direct_pts, final_mirror_pts - number of body parts x number of frames x 2
%       array containing measured direct and mirror points that have been
%       shifted into their respective ROIs and undistorted
%   direct_p, mirror_p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   direct_bp, mirror_bp - cell arrays containing lists of body parts
%       descriptors
%   ROIs - 3 x 4 array where each row is a [left,top,width,height] vector
%       defining a rectangular region of interest. First row is the direct
%       view, second row is the left mirror view, third row is the right
%       mirror view
%   boxCal - structure with the following fields:
%       cameraParams - matlab camera parameters structure
%   pawPref - 'right' or 'left'
%   imSize - 2-element vector with frame height x width
%
% OUTPUTS:
%   dist_from_epipole - 
%   final_direct_pts
%	final_mirror_pts
%   isEstimate - m x n x 2 array of booleans, where m is the number of
%       bodyparts, n is the number of frames, and the last index indicates
%       whether it's the direct (1) or mirror (2) views. True indicates
%       that this bodypart's position was estimated; false indicates that
%       it was measured directly by DLC

% assume that direct and mirror body part labels are the same

% points_still_distorted = true;   % set to false if vids were undistorted prior to running through deeplabcut
maxDistFromNeighbor = 60;

for iarg = 1 : 2 : nargin - 11
    switch lower(varargin{iarg})
        case 'maxdistfromneighbor'
            maxDistFromNeighbor = varargin{iarg + 1};
    end
end

[final_direct_pts,final_mirror_pts,isEstimate] = estimateHiddenPoints(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, imSize, pawPref,frames_to_recalculate,'maxDistFromNeighbor',maxDistFromNeighbor);
numFrames = size(final_direct_pts,2);
if size(invalid_direct,2) > numFrames
    % sometimes invalid_direct/mirror has more frames than the video
    % because one video in a session was truncated. If so, use only up to
    % the number of frames in the current video for the analysis in this
    % function
    invalid_direct = invalid_direct(:,1:numFrames);
    invalid_mirror = invalid_mirror(:,1:numFrames);
end