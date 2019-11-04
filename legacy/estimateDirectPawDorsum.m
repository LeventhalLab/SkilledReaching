function [final_directPawDorsum_pts, isEstimate] = estimateDirectPawDorsum(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs, frameSize, pawPref)
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

switch pawPref
    case 'right'
        F = squeeze(boxCal.F(:,:,2));
    case 'left'
        F = squeeze(boxCal.F(:,:,3));
end
        
numFrames = size(direct_pts,2);

[direct_mcp_idx,direct_pip_idx,direct_digit_idx,direct_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(direct_bp,pawPref);
[~,~,~,mirror_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(mirror_bp,pawPref);

% direct_pawdorsum_idx = findStringMatchinCellArray(direct_bp, [pawPref 'pawdorsum']);
% mirror_pawdorsum_idx = findStringMatchinCellArray(mirror_bp, [pawPref 'pawdorsum']);

invalid_direct = find_invalid_DLC_points(direct_pts, direct_p);
invalid_mirror = find_invalid_DLC_points(mirror_pts, mirror_p);

direct_pawdorsum_pts = squeeze(direct_pts(direct_pawdorsum_idx,:,:));
direct_pawdorsum_pts = direct_pawdorsum_pts + ...
    repmat(ROIs(1,1:2),numFrames,1) - 1;
direct_pawdorsum_pts_ud = undistortPoints(direct_pawdorsum_pts, boxCal.cameraParams);

mirror_pawdorsum_pts = squeeze(mirror_pts(mirror_pawdorsum_idx,:,:));
mirror_pawdorsum_pts = mirror_pawdorsum_pts + ...
    repmat(ROIs(2,1:2),numFrames,1) - 1;
mirror_pawdorsum_pts_ud = undistortPoints(mirror_pawdorsum_pts, boxCal.cameraParams);

invalid_directPawDorsum = invalid_direct(direct_pawdorsum_idx,:);
invalid_mirrorPawDorsum = invalid_mirror(mirror_pawdorsum_idx,:);

final_directPawDorsum_pts = NaN(numFrames,2);
isEstimate = false(numFrames,1);
for iFrame = 1 : numFrames
    
    if invalid_directPawDorsum(iFrame)
        % the reaching paw dorsum was probably not correctly identified in
        % the current frame
        
        % was the paw dorsum reliably identified in the mirror view? If so,
        % can draw an epipolar line through it to constrain the location of
        % the direct view paw dorsum
        if ~invalid_mirrorPawDorsum(iFrame)
            % direct view paw dorsum is constrained to be on the epipolar
            % line through the mirror view point
            
            epiLine = epipolarLine(F,mirror_pawdorsum_pts_ud(iFrame,:));
        end

        % are the two middle digit direct points valid?
        foundValidPoints = false;
        validTest = ~invalid_direct(direct_mcp_idx,iFrame);
        if any(validTest)   % at least one mcp was identified
            digitPts = squeeze(direct_pts(direct_mcp_idx,iFrame,:));
            foundValidPoints = true;
        end
        if ~foundValidPoints
            validTest = ~invalid_direct(direct_pip_idx,iFrame);
            if sum(validTest) > 1   % at least one pip was identified
                digitPts = squeeze(direct_pts(direct_pip_idx,iFrame,:));
                foundValidPoints = true;
            end
        end
        if ~foundValidPoints
            validTest = ~invalid_direct(direct_digit_idx,iFrame);
            if sum(validTest) > 1   % at least one digit tip was identified
                digitPts = squeeze(direct_pts(direct_digit_idx,iFrame,:));
                foundValidPoints = true;
            end
        end
        if foundValidPoints && ~invalid_mirrorPawDorsum(iFrame)
            % find the knuckle closest to the epipolar line
            
            % adjust digitPts for the ROI and camera distortion
            digitPts = digitPts + repmat(ROIs(1,1:2),size(digitPts,1),1) - 1;
            digitPts = undistortPoints(digitPts, boxCal.cameraParams);
            
            epiPts = lineToBorderPoints(epiLine, frameSize);
            epiPts = [epiPts(1:2);epiPts(3:4)];
            
            % find index of digitPts that is closest to the epipolar line
            [~, nnidx] = findNearestPointToLine(epiPts, digitPts);
            
            % find the point on the epipolar line closest to any of the
            % identified digit points
            np = findNearestPointOnLine(epiPts,digitPts(nnidx,:));
            final_directPawDorsum_pts(iFrame,:) = np;
            
            isEstimate(iFrame) = true;
        end
            
    else
        % the reaching paw dorsum was reliably identified in the current
        % frame
        final_directPawDorsum_pts(iFrame,:) = direct_pawdorsum_pts_ud(iFrame,:);
    end
    
end