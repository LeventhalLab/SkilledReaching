function [pawTrajectory, bodyparts, final_direct_pts, final_mirror_pts, isEstimate] = ...
    calc3D_DLC_trajectory(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, pawPref, imSize, varargin)
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
%   pawPref - 'right' or 'left'
%   imSize - 2-element vector with frame height x width
%
% VARARGS:
%   maxdistfromneighbor - maximum allowable distance betweeen points that
%       should be near each other (i.e., on the same paw)
%
% OUTPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFrames x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   final_direct_pts - num bodyparts x num frames x 2 array where each num
%       frames x 2 subarray contains (x,y) coordinate pairs. This includes
%       estimates of point locations based on the epipolar projection from
%       the mirror view
%	final_mirror_pts - same as final_direct_pts for the mirror view
%   isEstimate - m x n x 2 array of booleans, where m is the number of
%       bodyparts, n is the number of frames, and the last index indicates
%       whether it's the direct (1) or mirror (2) views. True indicates
%       that this bodypart's position was estimated; false indicates that
%       it was measured directly by DLC

% assume that direct and mirror body part labels are the same

% allowable distance for adjacent parts of the same paw to be separated. If
% separation is too great, at least one of the points was probably
% misidentified
maxDistFromNeighbor = 60;

for iarg = 1 : 2 : nargin - 9
    switch lower(varargin{iarg})
        case 'maxdistfromneighbor'
            maxDistFromNeighbor = varargin{iarg + 1};
    end
end

% intrinsic camera parameters
cameraParams = boxCal.cameraParams;

switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        scaleFactor = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        scaleFactor = mean(boxCal.scaleFactor(3,:));
end
K = cameraParams.IntrinsicMatrix;

[final_direct_pts,final_mirror_pts,isEstimate] = ...
    estimateHiddenPoints(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, imSize, pawPref,'maxDistFromNeighbor',maxDistFromNeighbor);
numFrames = size(final_direct_pts,2);
if size(invalid_direct,2) > numFrames
    % sometimes invalid_direct/mirror has more frames than the video
    % because one video in a session was truncated. If so, use only up to
    % the number of frames in the current video for the analysis in this
    % function
    invalid_direct = invalid_direct(:,1:numFrames);
    invalid_mirror = invalid_mirror(:,1:numFrames);
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
    
    if sum(validPoints) == 1    % only one validPoint, cur_pts arrays come out as column vectors instead of row vectors
        cur_direct_pts = cur_direct_pts';
        cur_mirror_pts = cur_mirror_pts';
    end

    % convert to homogeneous, then normalized points. see Hartley and
    % Zisserman's textbook on computer stereo vision
    direct_hom = [cur_direct_pts, ones(size(cur_direct_pts,1),1)];
    direct_norm = (K' \ direct_hom')';
    direct_norm = bsxfun(@rdivide,direct_norm(:,1:2),direct_norm(:,3));

    mirror_hom = [cur_mirror_pts, ones(size(cur_mirror_pts,1),1)];
    mirror_norm = (K' \ mirror_hom')';
    mirror_norm = bsxfun(@rdivide,mirror_norm(:,1:2),mirror_norm(:,3));

    [wpts, ~]  = triangulate_DL(direct_norm, mirror_norm, P, Pn);
    
    pawTrajectory(validPoints, :, i_bp) = wpts * scaleFactor;
end