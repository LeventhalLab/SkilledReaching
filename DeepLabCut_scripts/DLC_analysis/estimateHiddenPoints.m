function [final_direct_pts,final_mirror_pts,isEstimate] = estimateHiddenPoints(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref)

% vidPath = '/Volumes/Tbolt_01/Skilled Reaching/R0186/R0186_20170813a';
% video = VideoReader(fullfile(vidPath,'R0186_20170813_12-09-21_002.avi'));

switch pawPref
    case 'right'
        F = squeeze(boxCal.F(:,:,2));
    case 'left'
        F = squeeze(boxCal.F(:,:,3));
end

numFrames = size(direct_pts,2);

[direct_mcp_idx,direct_pip_idx,direct_digit_idx,direct_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(direct_bp,pawPref);
[mirror_mcp_idx,mirror_pip_idx,mirror_digit_idx,mirror_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(mirror_bp,pawPref);
% can work on the other body parts later; for now, just concerned with the
% reaching paw

allDirectParts_idx = [direct_mcp_idx;direct_pip_idx;direct_digit_idx;direct_pawdorsum_idx];
allMirrorParts_idx = [mirror_mcp_idx;mirror_pip_idx;mirror_digit_idx;mirror_pawdorsum_idx];

% numPawParts = length(direct_mcp_idx) + length(direct_pip_idx) + length(direct_digit_idx) + length(direct_pawdorsum_idx);

invalid_direct = find_invalid_DLC_points(direct_pts, direct_p);
invalid_mirror = find_invalid_DLC_points(mirror_pts, mirror_p);
isEstimate = false(size(direct_pts,1),size(direct_pts,2),2);

final_direct_pts = reconstructUndistortedPoints(direct_pts,ROIs(1,:),boxCal.cameraParams);
final_mirror_pts = reconstructUndistortedPoints(mirror_pts,ROIs(2,:),boxCal.cameraParams);

numDigits = length(direct_mcp_idx);
for iFrame = 1 : numFrames
    
    allDirectPts = squeeze(final_direct_pts(allDirectParts_idx,iFrame,:));
    allMirrorPts = squeeze(final_mirror_pts(allMirrorParts_idx,iFrame,:));
    
    validDirectPoints = allDirectPts(~invalid_direct(allDirectParts_idx,iFrame),:);
    validMirrorPoints = allMirrorPts(~invalid_mirror(allMirrorParts_idx,iFrame),:);
    
    directCVboundary_idx = boundary(validDirectPoints);
    mirrorCVboundary_idx = boundary(validMirrorPoints);
    
    directCVboundary_pts = validDirectPoints(directCVboundary_idx,:);
    mirrorCVboundary_pts = validMirrorPoints(mirrorCVboundary_idx,:);
    % work on digits first
    for i_digitPart = 1 : 3
        switch i_digitPart
            case 1
                direct_indices = direct_mcp_idx;
                mirror_indices = mirror_mcp_idx;
                
                direct_nextKnuckle_indices = direct_pip_idx;
                mirror_nextKnuckle_indices = mirror_pip_idx;
            case 2
                direct_indices = direct_pip_idx;
                mirror_indices = mirror_pip_idx;
                
                direct_nextKnuckle_indices = direct_digit_idx;
                mirror_nextKnuckle_indices = mirror_digit_idx;
            case 3
                direct_indices = direct_digit_idx;
                mirror_indices = mirror_digit_idx;
                
                direct_nextKnuckle_indices = direct_pip_idx;
                mirror_nextKnuckle_indices = mirror_pip_idx;
        end
        
        for i_digit = 1 : numDigits

            direct_part_idx = direct_indices(i_digit);
            mirror_part_idx = mirror_indices(i_digit);

            if (invalid_direct(direct_part_idx,iFrame) && invalid_mirror(mirror_part_idx,iFrame)) || ...
               (~invalid_direct(direct_part_idx,iFrame) && ~invalid_mirror(mirror_part_idx,iFrame))
                % either both points were found or both points were not found
                % with high certainty; nothing to do
                continue;
            end
            % figure out whether the mirror or direct view point was identified
            if invalid_direct(direct_part_idx,iFrame)
                % the mirror point was identified
                allPawPoints = validDirectPoints;
                known_pt = squeeze(final_mirror_pts(mirror_part_idx,iFrame,:))';

                other_knuckle_pts = squeeze(final_direct_pts(direct_indices,iFrame,:));
                other_knuckle_pts = other_knuckle_pts(~invalid_direct(direct_indices,iFrame),:);
                
                % find the point marked at the next knuckle on the same
                % digit
                if ~invalid_direct(direct_nextKnuckle_indices(i_digit),iFrame)
                    nextKnucklePt = squeeze(final_direct_pts(direct_nextKnuckle_indices(i_digit),iFrame, :));
                    if size(nextKnucklePt,1) == 2
                        nextKnucklePt = nextKnucklePt';
                    end
                else
                    nextKnucklePt = [];
                end
            else
                % the direct point was identified
                allPawPoints = validMirrorPoints;
                known_pt = squeeze(final_direct_pts(mirror_part_idx,iFrame,:))';

                other_knuckle_pts = squeeze(final_mirror_pts(mirror_indices,iFrame,:));
                other_knuckle_pts = other_knuckle_pts(~invalid_mirror(mirror_indices,iFrame),:);
                
                % find the point marked at the next knuckle on the same
                % digit
                if ~invalid_mirror(mirror_nextKnuckle_indices(i_digit),iFrame)
                    nextKnucklePt = squeeze(final_mirror_pts(mirror_nextKnuckle_indices(i_digit),iFrame, :));
                    if size(nextKnucklePt,1) == 2
                        nextKnucklePt = nextKnucklePt';
                    end
                else
                    nextKnucklePt = [];
                end
            end
            if isempty(other_knuckle_pts) && isempty(nextKnucklePt)
                continue;   % no nearest point to match with. probably will update this later to allow other points to be used...
            end

%             epiLine = epipolarLine(F,known_pt);
            np = estimatePawPart(known_pt, other_knuckle_pts, nextKnucklePt, allPawPoints, F, imSize);
%             np = estimatePawPart(known_pt, other_pts, F, imSize);
        
            if invalid_direct(direct_part_idx,iFrame)
                % the mirror point was identified
                final_direct_pts(direct_part_idx,iFrame,:) = np;
                isEstimate(direct_part_idx,iFrame,1) = true;   % direct point for this body part in this frame is estimated
            else
                % the direct point was identified
                final_mirror_pts(mirror_part_idx,iFrame,:) = np;
                isEstimate(mirror_part_idx,iFrame,2) = true;   % mirror point for this body part in this frame is estimated
            end

    end
    
%     for i_pawPart = 1 : length(direct_pip_idx)
% 
% %         direct_part_idx = direct_pip_idx(i_pawPart);
% %         mirror_part_idx = mirror_pip_idx(i_pawPart);
%     end
%     
%     for i_pawPart = 1 : length(direct_digit_idx)
% 
%     end
%     direct_part_idx = direct_indices(i_pawPart);
%     mirror_part_idx = mirror_indices(i_pawPart);
        
    end
    
end

[final_directPawDorsum_pts, isPawDorsumEstimate] = ...
    estimateDirectPawDorsum_from_ud_points(final_direct_pts, final_mirror_pts, invalid_direct, invalid_mirror, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref);
final_direct_pts(direct_pawdorsum_idx,:,:) = final_directPawDorsum_pts;
isEstimate(direct_pawdorsum_idx,:,1) = isPawDorsumEstimate;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function np = estimatePawPart(known_pt, other_knuckle_pts, nextKnucklePt, allPawPoints, F, imSize)

boundary_idx = boundary(allPawPoints);
boundary_pts = allPawPoints(boundary_idx,:);

epiLine = epipolarLine(F,known_pt);
intersectPoints = linePolygonIntersect(epiLine,boundary_pts);

if isempty(intersectPoints)
    % first option is to find a point within the boundary of identified
    % points for this view under the assumption that the paw itself is
    % occluding the view of the digit of interest
    epiBorderPts = lineToBorderPoints(epiLine, imSize);
    epiBorderPts = [epiBorderPts(1:2);epiBorderPts(3:4)];
    
    if isempty(other_knuckle_pts)
        % first option is to find the point on the epipolar line closest to
        % the next digit over; if that isn't available, find the point on
        % the epipolar line closest to the next knuckle up the same digit
        [~, nnidx] = findNearestPointToLine(epiBorderPts, nextKnucklePt);
        np = findNearestPointOnLine(epiBorderPts,nextKnucklePt(nnidx,:));
    else
        [~, nnidx] = findNearestPointToLine(epiBorderPts, other_knuckle_pts);
        np = findNearestPointOnLine(epiBorderPts,other_knuckle_pts(nnidx,:));
    end

else
    if isempty(nextKnucklePt)
        % the epipolar line intersects the polygon defined by the points
        % that were found in the other view, but the point for the next
        % knuckle on the same digit wasn't found either. Look for the
        % closest point in the intersection of the epipolar line with the
        % same knuckle on one of the other digits
        
        % find index of other_pts that is closest to the epipolar line
        epiBorderPts = lineToBorderPoints(epiLine, imSize);
        epiBorderPts = [epiBorderPts(1:2);epiBorderPts(3:4)];

        [~, nnidx] = findNearestPointToLine(epiBorderPts, other_knuckle_pts);
        np = findNearestPointOnLine(epiBorderPts,other_knuckle_pts(nnidx,:));
    else
        % the epipolar line intersects the polygon defined by the points
        % that were found in the other view. look for the intersection
        % point closest to the next knuckle on the same digit
        [~,nnidx] = findNearestNeighbor(nextKnucklePt, intersectPoints);
        np = intersectPoints(nnidx,:);
    end
end

end