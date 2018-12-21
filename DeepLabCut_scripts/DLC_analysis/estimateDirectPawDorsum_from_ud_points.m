function [final_directPawDorsum_pts, isEstimate] = estimateDirectPawDorsum_from_ud_points(direct_pts_ud, mirror_pts_ud, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, frameSize, pawPref,varargin)
%
% estimate the location of the paw dorsum in the direct view given its
% location in the mirror view and the locations of associated points

% first find all valid direct view paw dorsum points

% look at all invalid direct view points
% 1) is the mirror view point valid? If so, can calculate an epipolar line
% along which the direct view paw dorsum must lie
%
% 2) which digit points are valid?

% figure out the index of the paw dorsum in the direct and mirror views

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

[direct_mcp_idx,direct_pip_idx,direct_digit_idx,direct_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(direct_bp,pawPref);
[~,~,~,mirror_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(mirror_bp,pawPref);

all_direct_digit_idx = [direct_mcp_idx;direct_pip_idx;direct_digit_idx];

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
        validTest = ~invalid_direct(direct_mcp_idx,iFrame);
        if any(validTest)   % at least one mcp was identified
            digitPts = squeeze(direct_pts_ud(direct_mcp_idx(validTest),iFrame,:));
            foundValidPoints = true;
        end
        if ~foundValidPoints
            validTest = ~invalid_direct(direct_pip_idx,iFrame);
            if any(validTest)   % at least one pip was identified
                digitPts = squeeze(direct_pts_ud(direct_pip_idx(validTest),iFrame,:));
                foundValidPoints = true;
            end
        end
        if ~foundValidPoints
            validTest = ~invalid_direct(direct_digit_idx,iFrame);
            if any(validTest)    % at least one digit tip was identified
                digitPts = squeeze(direct_pts_ud(direct_digit_idx(validTest),iFrame,:));
                foundValidPoints = true;
            end
        end
        if foundValidPoints && ~invalid_mirrorPawDorsum(iFrame)
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
            
            epiPts = lineToBorderPoints(epiLine, frameSize);
            epiPts = [epiPts(1:2);epiPts(3:4)];

            if size(digitPts,1) == numel(digitPts)
                % if digitPts is a column vector, convert to row vector
                digitPts = digitPts';
            end
                    
            % find index of digitPts that is closest to the epipolar line
            [nndist, nnidx] = findNearestPointToLine(epiPts, digitPts);
                
            if isempty(intersectPoints)
                % find the knuckle closest to the epipolar line

                if nndist < maxDistFromNeighbor   % if the estimated point is too far from identified points, ignore it
                    % find the point on the epipolar line closest to any of the
                    % identified digit points

                    np = findNearestPointOnLine(epiPts,digitPts(nnidx,:));
                    final_directPawDorsum_pts(iFrame,:) = np;
                    isEstimate(iFrame) = true;
                end
            else
                [nndist2,nnidx2] = findNearestNeighbor(digitPts(nnidx,:), intersectPoints);
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