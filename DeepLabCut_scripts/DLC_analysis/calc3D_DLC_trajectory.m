function [pawTrajectory, bodyparts, dist_from_epipole, final_directPawDorsum_pts, isDirectPawDorsumEstimate] = calc3D_DLC_trajectory(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, ROIs, boxCal, pawPref, imSize, varargin)
%
% INPUTS:
%   direct_pts, mirror_pts - number of body parts x number of frames x 2
%       array
%   direct_bp, mirror_bp - cell arrays containing lists of body parts
%       descriptors
%   direct_p, mirror_p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   ROIs - 3 x 4 array where each row is a [left,top,width,height] vector
%       defining a rectangular region of interest. First row is the direct
%       view, second row is the left mirror view, third row is the right
%       mirror view
%   boxCal - structure with the following fields:
%       cameraParams - matlab camera parameters structure
%   Pn - camera matrix for the mirror view that shows the paw dorsum
%   F - the fundamental matrix for the mirror view that shows the paw
%       dorsum
%   scaleFactor - mean computed scaling factor for the mirror view that
%       shows the paw dorsum
%
%       
% OUTPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array

% assume that direct and mirror body part labels are the same

points_still_distorted = true;   % set to false if vids were undistorted prior to running through deeplabcut
cameraParams = boxCal.cameraParams;

switch pawPref
    case 'right'
        ROIs = ROIs(1:2,:);
        Pn = squeeze(boxCal.Pn(:,:,2));
        scaleFactor = mean(boxCal.scaleFactor(2,:));
        F = squeeze(boxCal.F(:,:,2));
    case 'left'
        ROIs = ROIs([1,3],:);
        Pn = squeeze(boxCal.Pn(:,:,3));
        scaleFactor = mean(boxCal.scaleFactor(3,:));
        F = squeeze(boxCal.F(:,:,3));
end
K = cameraParams.IntrinsicMatrix;

numFrames = size(direct_pts, 2);

% maxDistFromEpipole = 10;   % how far away from the epipole can the line
                           % connecting the matched direct and mirror
                           % points be before the algorithm says there must
                           % be a mismatch?

% for iarg = 1 : 2 : nargin - 10
%     switch lower(varargin{iarg})
%         case 'maxdistfromepipole'
%             maxDistFromEpipole = varargin{iarg + 1};
%     end
% end

[~,epipole] = isEpipoleInImage(F,imSize);

[final_direct_pts,final_mirror_pts,isEstimate] = estimateHiddenPoints(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref);
[final_directPawDorsum_pts, isDirectPawDorsumEstimate] = estimateDirectPawDorsum(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref);

[~,~,~,direct_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(direct_bp,pawPref);

% match body parts between direct and mirror views
mirror_bpMatch_idx = [];
direct_bpMatch_idx = [];
num_direct_bp = length(direct_bp);
numValid_bp = 0;
bodyparts = {};
for i_bp = 1 : num_direct_bp
    
    if isempty(strcmpi(mirror_bp, direct_bp{i_bp}))
        continue;
    end
    numValid_bp = numValid_bp + 1;
    mirror_bpMatch_idx(numValid_bp) = find(strcmpi(mirror_bp, direct_bp{i_bp}));
    direct_bpMatch_idx(numValid_bp) = i_bp;
    bodyparts{numValid_bp} = direct_bp{i_bp};
end

pawTrajectory = zeros(numFrames, 3, numValid_bp);
dist_from_epipole = zeros(numFrames, numValid_bp);
P = eye(4,3);
for i_bp = 1 : numValid_bp

    if direct_bpMatch_idx(i_bp) == direct_pawdorsum_idx
        cur_direct_pts = final_directPawDorsum_pts;
    else
        cur_direct_pts = squeeze(direct_pts(direct_bpMatch_idx(i_bp), :, :));
        % adjust for the region of interest from which the cropped videos
        % were pulled
        cur_direct_pts(cur_direct_pts==0) = NaN;
        cur_direct_pts(:,1) = cur_direct_pts(:,1) + ROIs(1,1) - 1;
        cur_direct_pts(:,2) = cur_direct_pts(:,2) + ROIs(1,2) - 1;
    end
    cur_mirror_pts = squeeze(mirror_pts(mirror_bpMatch_idx(i_bp), :, :));
    cur_mirror_pts(cur_mirror_pts==0) = NaN;

    % adjust for the region of interest from which the cropped videos
    % were pulled
    cur_mirror_pts(:,1) = cur_mirror_pts(:,1) + ROIs(2,1) - 1;
    cur_mirror_pts(:,2) = cur_mirror_pts(:,2) + ROIs(2,2) - 1;
    
    % undistort points
    if points_still_distorted
        for ii = 1 : size(cur_direct_pts,1)
            if ~isnan(cur_direct_pts(ii,1))
                if direct_bpMatch_idx(i_bp) ~= direct_pawdorsum_idx   % already undistorted if using paw dorsum estimates
                    cur_direct_pts(ii,:) = undistortPoints(cur_direct_pts(ii,:),cameraParams);
                end
            end
            if ~isnan(cur_mirror_pts(ii,1))
                cur_mirror_pts(ii,:) = undistortPoints(cur_mirror_pts(ii,:),cameraParams);
            end
        end
    end
        
    
    dist_from_epipole(:,i_bp) = distanceToLine(cur_direct_pts,cur_mirror_pts,epipole);

    direct_hom = [cur_direct_pts, ones(size(cur_direct_pts,1),1)];
    direct_norm = (K' \ direct_hom')';
    direct_norm = bsxfun(@rdivide,direct_norm(:,1:2),direct_norm(:,3));

    mirror_hom = [cur_mirror_pts, ones(size(cur_mirror_pts,1),1)];
    mirror_norm = (K' \ mirror_hom')';
    mirror_norm = bsxfun(@rdivide,mirror_norm(:,1:2),mirror_norm(:,3));

    [wpts, ~]  = triangulate_DL(direct_norm, mirror_norm, P, Pn);
    
    pawTrajectory(:, :, i_bp) = wpts * scaleFactor;
end