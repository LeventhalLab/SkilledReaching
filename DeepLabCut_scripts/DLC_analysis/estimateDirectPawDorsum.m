function [DirectPawDorsum_pts, isEstimate] = estimateDirectPawDorsum(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs)
%
% estimate the location of the paw dorsum in the direct view given its
% location in the mirror view and the locations of associated points

% first find all valid direct view paw dorsum points

% look at all invalid direct view points
% 1) is the mirror view point valid? If so, can calculate an epipolar line
% along which the direct view paw dorsum must lie
%
% 2) which digit points are valid?