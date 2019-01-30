function [pawTrajectory, bodyparts, final_direct_pts, final_mirror_pts, isEstimate] = calc3D_DLC_trajectory_20181204(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, ROIs, boxCal, pawPref, imSize, varargin)
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
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
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

for iarg = 1 : 2 : nargin - 10
    switch lower(varargin{iarg})
        case 'maxdistfromneighbor'
            maxDistFromNeighbor = varargin{iarg + 1};
    end
end


cameraParams = boxCal.cameraParams;

switch pawPref
    case 'right'
        ROIs = ROIs(1:2,:);
        Pn = squeeze(boxCal.Pn(:,:,2));
        scaleFactor = mean(boxCal.scaleFactor(2,:));
%         F = squeeze(boxCal.F(:,:,2));
    case 'left'
        ROIs = ROIs([1,3],:);
        Pn = squeeze(boxCal.Pn(:,:,3));
        scaleFactor = mean(boxCal.scaleFactor(3,:));
%         F = squeeze(boxCal.F(:,:,3));
end
K = cameraParams.IntrinsicMatrix;

numFrames = size(final_direct_pts, 2);

% maxDistFromEpipole = 10;   % how far away from the epipole can the line
                           % connecting the matched direct and mirror
                           % points be before the algorithm says there must
                           % be a mismatch?


[final_direct_pts,final_mirror_pts,isEstimate] = estimateHiddenPoints(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref,'maxDistFromNeighbor',maxDistFromNeighbor);

% WORKING HERE - PROBLEM WITH THROWING OUT THE WRONG POINTS WHEN THE
% OPPOSITE PAW COMES THROUGH THE SLOT AND IS MISTAKEN FOR THE "CORRECT"
% REACHING PAW
% match body parts between direct and mirror views
% mirror_bpMatch_idx = [];
% direct_bpMatch_idx = [];
% num_direct_bp = length(direct_bp);
% numValid_bp = 0;
% bodyparts = {};
% for i_bp = 1 : num_direct_bp
%     
%     if isempty(strcmpi(mirror_bp, direct_bp{i_bp}))
%         continue;
%     end
%     numValid_bp = numValid_bp + 1;
%     mirror_bpMatch_idx(numValid_bp) = find(strcmpi(mirror_bp, direct_bp{i_bp}));
%     direct_bpMatch_idx(numValid_bp) = i_bp;
%     bodyparts{numValid_bp} = direct_bp{i_bp};
% end
[bodyparts,direct_bpMatch_idx,mirror_bpMatch_idx] = matchBodyPartIndices(direct_bp,mirror_bp);
numValid_bp = length(bodyparts);

pawTrajectory = zeros(numFrames, 3, numValid_bp);
% dist_from_epipole = zeros(numFrames, numValid_bp);
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
%     cur_direct_pts = squeeze(final_direct_pts(direct_bpMatch_idx(i_bp), :, :));
%     cur_mirror_pts = squeeze(final_mirror_pts(mirror_bpMatch_idx(i_bp), :, :));
    
%     dist_from_epipole(:,i_bp) = distanceToLine(cur_direct_pts,cur_mirror_pts,epipole);

    direct_hom = [cur_direct_pts, ones(size(cur_direct_pts,1),1)];
    direct_norm = (K' \ direct_hom')';
    direct_norm = bsxfun(@rdivide,direct_norm(:,1:2),direct_norm(:,3));

    mirror_hom = [cur_mirror_pts, ones(size(cur_mirror_pts,1),1)];
    mirror_norm = (K' \ mirror_hom')';
    mirror_norm = bsxfun(@rdivide,mirror_norm(:,1:2),mirror_norm(:,3));

    [wpts, ~]  = triangulate_DL(direct_norm, mirror_norm, P, Pn);
    
    pawTrajectory(validPoints, :, i_bp) = wpts * scaleFactor;
end