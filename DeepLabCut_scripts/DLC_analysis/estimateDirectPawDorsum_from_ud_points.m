function [final_directPawDorsum_pts, isEstimate] = estimateDirectPawDorsum_from_ud_points(direct_pts_ud, mirror_pts_ud, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, imSize, pawPref,varargin)
%
% estimate the location of the paw dorsum in the direct view given its
% location in the mirror view and the locations of associated points
%
% INPUTS:
%   direct_pts_ud - m x n x 2 array where m is the number of body parts and
%       n is the number of frames. Each (x,y) pair is an undistorted point,
%       where the point (1,1) is the upper left corner of the full frame
%       including mirror and direct views
%   mirror_pts_ud - same as direct_pts_ud for the mirror view
%   invalid_direct - num bodyparts x numFrames boolean array containing
%       whether each bodypart identified in each frame is "valid" (false)
%       or "invalid" (true) (i.e., low probability, not aligned with other
%       view)
%   invalid_mirror - same as invalid_direct for the mirror view
%   direct_bp - cell array containing the bodypart labels for the direct
%       view (from DLC)
%   mirror_bp - same as direct_bp for the mirror view
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
%   imSize - 2-element vector with frame height x width
%
% OUTPUTS:
%   final_directPawDorsum_pts - numFrames x 2 array where each row is an
%       (x,y) pair with updates locations of the paw dorsum in the direct
%       view
%   isEstimate - column vector with length numFrames indicates whether each
%       direct paw dorsum coordinate in final_directPawDorsum_pts was
%       estimated based on the location in the mirror view (true) or was
%       directly determined by DLC (false)

% look at all invalid direct view points
% 1) is the mirror view point valid? If so, can calculate an epipolar line
% along which the direct view paw dorsum must lie
%
% 2) which digit points are valid? can use them to figure out the general
% vicinity of where the paw dorsum should be

maxDistFromNeighbor = 60;  % how far the estimated point is allowed to be from its nearest identified neighbor

for iarg = 1 : 2 : nargin - 9
    switch lower(varargin{iarg})
        case 'maxdistfromneighbor'
            maxDistFromNeighbor = varargin{iarg + 1};
    end
end

switch pawPref
    case 'right'
        F = squeeze(boxCal.F(:,:,2));
    case 'left'
        F = squeeze(boxCal.F(:,:,3));
end
        
numFrames = size(direct_pts_ud,2);

% [direct_mcp_idx,direct_pip_idx,direct_digit_idx,direct_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(direct_bp,pawPref);
% [~,~,~,mirror_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(mirror_bp,pawPref);

% all_direct_digit_idx = [direct_mcp_idx;direct_pip_idx;direct_digit_idx];

if strcmp(pawPref,'left')
    direct_pp_idx=[1];
    direct_npn_idx=[2];
    mirror_pp_idx=[1];
    mirror_npn_idx=[2];
elseif strcmp(pawPref,'right')
    direct_pp_idx=[2];
    direct_npn_idx=[1];
    mirror_pp_idx=[2];
    mirror_npn_idx=[1];
else
    disp('there`s an error');
end

direct_nose_idx=[3];
direct_pellet_idx=[4];
mirror_nose_idx=[3];
mirror_pellet_idx=[4];

direct_pawdorsum_pts_ud = squeeze(direct_pts_ud(direct_pawdorsum_idx,:,:));
mirror_pawdorsum_pts_ud = squeeze(mirror_pts_ud(mirror_pawdorsum_idx,:,:));

invalid_directPawDorsum = invalid_direct(direct_pawdorsum_idx,:);
invalid_mirrorPawDorsum = invalid_mirror(mirror_pawdorsum_idx,:);

final_directPawDorsum_pts = NaN(numFrames,2);
isEstimate = false(numFrames,1);
for iFrame = 1 : numFrames
    
    if invalid_directPawDorsum(iFrame)
        % the reaching paw dorsum was probably not correctly identified in
        % the current frame
        
        validDirectPoints = squeeze(direct_pts_ud(~invalid_direct(all_direct_digit_idx,iFrame),iFrame,:));
        if iscolumn(validDirectPoints)
            validDirectPoints = validDirectPoints';
        end
        % was the paw dorsum reliably identified in the mirror view? If so,
        % can draw an epipolar line through it to constrain the location of
        % the direct view paw dorsum
        if ~invalid_mirrorPawDorsum(iFrame)
            % direct view paw dorsum is constrained to be on the epipolar
            % line through the mirror view point
            
            epiLine = epipolarLine(F,mirror_pawdorsum_pts_ud(iFrame,:));
        end

        % first look for valid mcp's, then valid pip's, then valid digit
        % tips
        foundValidPoints = false;

        validMCP = ~invalid_direct(direct_mcp_idx,iFrame);
        validPIP = ~invalid_direct(direct_pip_idx,iFrame);
        validDigits = ~invalid_direct(direct_digit_idx,iFrame);
        if (validMCP(2) && validMCP(3)) || (validMCP(1) && validMCP(4))
            digitPts = squeeze(direct_pts_ud(direct_mcp_idx,iFrame,:));
            validPts = validMCP;
            foundValidPoints = true;
        elseif (validPIP(2) && validPIP(3)) || (validPIP(1) && validPIP(4))
            digitPts = squeeze(direct_pts_ud(direct_pip_idx,iFrame,:));
            validPts = validPIP;
            foundValidPoints = true;
        elseif (validDigits(2) && validDigits(3)) || (validDigits(1) && validDigits(4))
            digitPts = squeeze(direct_pts_ud(direct_digit_idx,iFrame,:));
            validPts = validDigits;
            foundValidPoints = true;
        elseif any(validMCP)
            digitPts = squeeze(direct_pts_ud(direct_mcp_idx,iFrame,:));
            validPts = validMCP;
            foundValidPoints = true;
        elseif any(validPIP)
            digitPts = squeeze(direct_pts_ud(direct_pip_idx,iFrame,:));
            validPts = validPIP;
            foundValidPoints = true;
        elseif any(validDigits)
            digitPts = squeeze(direct_pts_ud(direct_digit_idx,iFrame,:));
            validPts = validDigits;
            foundValidPoints = true;
        end
        if foundValidPoints && ~invalid_mirrorPawDorsum(iFrame)
            digitsMidpoint = findDigitsMidpoint(digitPts,validPts);
        
            % does the epipolar line intersect the region bounded by the
            % identified points?
            if size(validDirectPoints,1) == 1    % only one valid point in the direct view
                intersectPoints = [];
            elseif size(validDirectPoints,1) == 2
                % only two valid points - not enough to describe a polygon
                intersectPoints = line_segment_intersect(epiLine,validDirectPoints);
            else
                boundary_idx = boundary(validDirectPoints);
                boundary_pts = validDirectPoints(boundary_idx,:);
                intersectPoints = lineConvexHullIntersect(epiLine,boundary_pts);
            end
            
            epiPts = lineToBorderPoints(epiLine, imSize);
            epiPts = [epiPts(1:2);epiPts(3:4)];
                
            if isempty(intersectPoints)
                
                [np,d] = findNearestPointOnLine(epiPts,digitsMidpoint);
                
                if d < maxDistFromNeighbor   % if the estimated point is too far from identified points, ignore it
                    % find the point on the epipolar line closest to the
                    % digits midpoint

                    final_directPawDorsum_pts(iFrame,:) = np;
                    isEstimate(iFrame) = true;
                end
            else
                [nndist2,nnidx2] = findNearestNeighbor(digitsMidpoint, intersectPoints);
                if nndist2 < maxDistFromNeighbor
                    np = intersectPoints(nnidx2,:);
                    final_directPawDorsum_pts(iFrame,:) = np;
                    isEstimate(iFrame) = true;
                end
            end
        end
            
    else
        % the reaching paw dorsum was reliably identified in the current
        % frame
        final_directPawDorsum_pts(iFrame,:) = direct_pawdorsum_pts_ud(iFrame,:);
    end
    
end