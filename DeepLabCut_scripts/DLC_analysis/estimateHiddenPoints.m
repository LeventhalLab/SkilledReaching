function [final_direct_pts,final_mirror_pts,isEstimate] = estimateHiddenPoints(direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, boxCal, ROIs, imSize, pawPref)

vidPath = '/Volumes/Tbolt_01/Skilled Reaching/R0186/R0186_20170813a';
video = VideoReader(fullfile(vidPath,'R0186_20170813_12-09-21_002.avi'));

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

numPawParts = length(direct_mcp_idx) + length(direct_pip_idx) + length(direct_digit_idx) + length(direct_pawdorsum_idx);

invalid_direct = find_invalid_DLC_points(direct_pts, direct_p);
invalid_mirror = find_invalid_DLC_points(mirror_pts, mirror_p);
isEstimate = false(size(direct_pts,1),size(direct_pts,2),2);

final_direct_pts = reconstructUndistortedPoints(direct_pts,ROIs(1,:),boxCal.cameraParams);
final_mirror_pts = reconstructUndistortedPoints(mirror_pts,ROIs(2,:),boxCal.cameraParams);

for iFrame = 1 : numFrames
    
    % work on digits first
    for i_pawPart = 1 : length(direct_mcp_idx)
        direct_part_idx = direct_mcp_idx(i_pawPart);
        mirror_part_idx = mirror_mcp_idx(i_pawPart);
        
        if (invalid_direct(direct_part_idx,iFrame) && invalid_mirror(mirror_part_idx,iFrame)) || ...
           (~invalid_direct(direct_part_idx,iFrame) && ~invalid_mirror(mirror_part_idx,iFrame))
            % either both points were found or both points were not found
            % with high certainty; nothing to do
            continue;
        end
        % figure out whether the mirror or direct view point was identified
        if invalid_direct(direct_part_idx,iFrame)
            % the mirror point was identified
            known_pt = squeeze(final_mirror_pts(mirror_part_idx,iFrame,:))';
            
            other_pts = squeeze(final_direct_pts(direct_mcp_idx,iFrame,:));
            other_pts = other_pts(~invalid_direct(direct_mcp_idx,iFrame),:);
        else
            known_pt = squeeze(final_direct_pts(mirror_part_idx,iFrame,:))';
            
            other_pts = squeeze(final_mirror_pts(mirror_mcp_idx,iFrame,:));
            other_pts = other_pts(~invalid_mirror(mirror_mcp_idx,iFrame),:);
        end
        if isempty(other_pts)
            continue;   % no nearest point to match with. probably will update this later to allow other points to be used...
        end
        epiLine = epipolarLine(F,known_pt);
        epiBorderPts = lineToBorderPoints(epiLine, imSize);
        epiBorderPts = [epiBorderPts(1:2);epiBorderPts(3:4)];
        
        
        % find index of other_pts that is closest to the epipolar line
        [~, nnidx] = findNearestPointToLine(epiBorderPts, other_pts);
        
        % find the point on the epipolar line closest to any of the
        % identified digit points
        np = findNearestPointOnLine(epiBorderPts,other_pts(nnidx,:));
            
        % WORKING HERE...
        % FIND PAW POINT IN THE VIEW WHERE THE POINT OF INTEREST WASN'T
        % FOUND THAT'S CLOSEST TO THE EPIPOLAR LINE THAT IS OF THE SAME
        % TYPE (I.E., IF AN MCP, FIND ANOTHER MCP POINT, ETC)
    end
    
    for i_pawPart = 1 : length(direct_pip_idx)
        direct_part_idx = direct_pip_idx(i_pawPart);
        mirror_part_idx = mirror_pip_idx(i_pawPart);
    end
    
    for i_pawPart = 1 : length(direct_digit_idx)
        direct_part_idx = direct_digit_idx(i_pawPart);
        mirror_part_idx = mirror_digit_idx(i_pawPart);
    end

        
        
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function points_ud = reconstructUndistortedPoints(pts,ROI,cameraParams)

points_ud = zeros(size(pts));
for i_coord = 1 : 2
    points_ud(:,:,i_coord) = pts(:,:,i_coord) + ROI(i_coord) - 1;
end

for i_part = 1 : size(points_ud,1)
    points_ud(i_part,:,:) = undistortPoints(squeeze(points_ud(i_part,:,:)),cameraParams);
end

end