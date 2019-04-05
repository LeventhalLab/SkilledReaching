function [partEndPts,partEndPtFrame,partFinalEndPts,partFinalEndPtFrame,endPts,endPtFrame,final_endPts,final_endPtFrame,pawPartsList,reachFrameIdx] = ...
    findReachEndpoint_20190319(pawTrajectory, bodyparts,pawPref,paw_through_slot_frame,isEstimate,varargin)
%
% find the reach endpoint frames for the initial reach
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFrame x 3
%       matrix contains x,y,z points for each bodypart. For this function,
%       assume the origin is at the pellet, not the camera lens
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   pawPref - 'left' or 'right'
%   paw_through_slot_frame - 
%   isEstimate - num bodyparts x numFrames x 2 array indicating whether
%       each trajectory point was detected by DLC (false) or estimated
%       later (true). isEstimate(:,:,1) is for the direct view,
%       isEstimate(:,:,2) is for the mirror view
%
% VARARGS
%   smoothsize - size of the smoothing window used for finding
%       zero-crossings of the z-position of the paw
%   slot_z - location of the front panel of the reaching box with respect
%       to the pellet location
%
% OUTPUTS
%   partEndPts - m x 3 matrix where m is the number of paw parts and each
%       row is the (x,y,z) point where z-coordinate reaches a local minimum
%       after the trigger frame. NaN for frames where the paw part isn't
%       visible in both views
%   partEndPtFrame - vector of length m (number of paw parts) containing
%       the frame number at which each paw part reversed z-direction after
%       the trigger frame
%   partFinalEndPts - same as partEndPts, but for the last time there is a
%       zero velocity crossing instead of the first
%   partFinalEndPtFrame - same as partEndPtFrame, but finds the last time
%       this happened instead of the first time it happened
%   endPts - same as partEndPts, but contains the coordinates at endPtFrame
%       for each body part
%   endPtFrame - single frame at which the paw as a whole is believed to
%       change directions. Currently calculated as the maximum frame at
%       which any of the last 3 digits (exclude index since often occluded)
%       changes direction
%   final_endPts - same as endPts, but for the last reach instead of the
%       first
%   final_endPtFrame - same as endPtFrame, but for the last reach instead
%       of the first
%   pawPartsList - the list of paw parts in the same order as for the
%       numeric arrays above


% NEXT THING TO DO: COUNT THE NUMBER OF REACHES BY COUNTING THE NUMBER OF
% ZERO CROSSINGS BETWEEN THE FIRST AND LAST REACH


smoothSize = 3;
slot_z = 25;   % guess w.r.t. the pellet, but now have a way to find the
               % slot z-coordinate earlier in the process

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

min_z_diff_pre_reach = 1;     % minimum number of millimeters the paw must have moved since the previous reach to count as a new reach
min_z_diff_post_reach = 0.5;     
maxFramesPriorToAdvance = 10;   % if the paw extends further within this many frames after a local minimum, don't count it as a reach
pts_to_extract = 10;  % look pts_to_extract frames on either side of each z
% local minimum, and see if z changed greater than min_z_for reach within that window

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'smoothsize'
            smoothSize = varargin{iarg + 1};
        case 'slot_z'
            slot_z = varargin{iarg + 1};
        case 'min_z_diff_pre_reach'
            min_z_diff_pre_reach = varargin{iarg + 1};
        case 'min_z_diff_post_reach'
            min_z_diff_post_reach = varargin{iarg + 1};
        case 'maxframespriortoadvance'
            maxFramesPriorToAdvance = varargin{iarg + 1};
        case 'pts_to_extract'
            pts_to_extract = varargin{iarg + 1};
            
    end
end

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

pawDorsum_z = squeeze(pawTrajectory(:,3,pawDorsumIdx));

numPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);

pawPartsList = cell(1,numPawParts);
curPartIdx = 0;
allPawPartsIdx = zeros(numPawParts,1);
for ii = 1 : length(mcpIdx)
    curPartIdx = curPartIdx + 1;
    pawPartsList{curPartIdx} = bodyparts{mcpIdx(ii)};
    allPawPartsIdx(curPartIdx) = mcpIdx(ii);
end
for ii = 1 : length(pipIdx)
    curPartIdx = curPartIdx + 1;
    pawPartsList{curPartIdx} = bodyparts{pipIdx(ii)};
    allPawPartsIdx(curPartIdx) = pipIdx(ii);
end
for ii = 1 : length(digIdx)
    curPartIdx = curPartIdx + 1;
    pawPartsList{curPartIdx} = bodyparts{digIdx(ii)};
    allPawPartsIdx(curPartIdx) = digIdx(ii);
end
% for ii = 1 : length(pawDorsumIdx)
    curPartIdx = curPartIdx + 1;
%     pawPartsList{curPartIdx} = bodyparts{pawDorsumIdx(ii)};
%     allPawPartsIdx(curPartIdx) = pawDorsumIdx(ii);
    pawPartsList{curPartIdx} = bodyparts{pawDorsumIdx};
    allPawPartsIdx(curPartIdx) = pawDorsumIdx;
% end

if isnan(paw_through_slot_frame)
    % something happened that it couldn't find a clean movement of the paw
    % through the reaching slot earlier
    partEndPtFrame = NaN(numPawParts,1);
    endPtFrame = NaN;
    final_endPtFrame = NaN;
    partEndPts = zeros(numPawParts,3);
    endPts = zeros(numPawParts,3);
    final_endPts = zeros(numPawParts,3);
    partFinalEndPts = NaN(numPawParts,3);
    partFinalEndPtFrame = NaN(numPawParts,1);
    reachFrameIdx = cell(numPawParts,1);
    return
end

numFrames = size(pawTrajectory,1);
% find the first local minimum in the z-dimension after reach onset
xyz_coords = pawTrajectory(:,:,allPawPartsIdx);
xyz_smooth = zeros(size(xyz_coords));
% find all frames where one of the points was estimated (maybe good enough
% to use just the mirror frame?), and exclude them
pawPartEstimates = squeeze(isEstimate(allPawPartsIdx,:,1)) | squeeze(isEstimate(allPawPartsIdx,:,2));
for iPart = 1 : numPawParts
    if ~(allPawPartsIdx(iPart) == pawDorsumIdx)
        % allow the paw dorsum to be an estimate
        xyz_coords(pawPartEstimates(iPart,:)',:,iPart) = NaN;
    end
    xyz_part = squeeze(xyz_coords(:,:,iPart));
    xyz_smooth(:,:,iPart) = smoothdata(xyz_part,1,'movmean',smoothSize);
%     for iAxis = 1 : 3
%         xyz_smooth(:,iAxis,iPart) = pchip(1:numFrames,squeeze(xyz_part(:,iAxis)),1:numFrames);
%     end
end
z_smooth = squeeze(xyz_smooth(:,3,:));
y_smooth = squeeze(xyz_smooth(:,2,:));
z_reach = z_smooth;
z_reach(z_reach > slot_z) = NaN;
y_reach = y_smooth;
y_reach(isnan(z_reach)) = NaN;
% z_smooth = smoothdata(z_coords,1,'movmean',smoothSize);
localMins = islocalmin(z_reach, 1);
% localMins = localMins & z_smooth < slot_z;    % only count zero velocity points in front of the reaching slot

% find the first time the paw moves behind the slot after paw_through_slot_frame
% first_paw_return = findFirstPawReturnFrame(pawDorsum_z,z_smooth,paw_through_slot_frame,slot_z);

triggerFrame = paw_through_slot_frame; % probably not necessary
partEndPts = zeros(numPawParts,3);
partFinalEndPts = zeros(numPawParts,3);
partEndPtFrame = zeros(numPawParts,1);
partFinalEndPtFrame = zeros(numPawParts,1);
reachFrameIdx = cell(numPawParts,1);
extraFramesToExtract = pts_to_extract+1;
for iPart = 1 : numPawParts
    
    if any(localMins(triggerFrame+1:end,iPart))
        startFrame = max(triggerFrame-extraFramesToExtract,1);
        reachFrameMarkers = find_reaches(localMins(startFrame:end,iPart),z_reach(startFrame:end,iPart),y_reach(startFrame:end,iPart),min_z_diff_pre_reach,min_z_diff_post_reach,maxFramesPriorToAdvance,extraFramesToExtract,pts_to_extract);
        if any(reachFrameMarkers)
            partEndPtFrame(iPart) = startFrame-1 + find(reachFrameMarkers,1);
            partFinalEndPtFrame(iPart) = startFrame-1 + find(reachFrameMarkers,1,'last');
            partEndPts(iPart,:) = squeeze(xyz_smooth(partEndPtFrame(iPart),:,iPart));
            partFinalEndPts(iPart,:) = squeeze(xyz_smooth(partFinalEndPtFrame(iPart),:,iPart));
            reachFrameIdx{iPart} = startFrame-1 + find(reachFrameMarkers);
        else
            partEndPtFrame(iPart) = NaN;
            partFinalEndPtFrame(iPart) = NaN;
            partEndPts(iPart,:) = NaN(1,3);
            partFinalEndPts(iPart,:) = NaN(1,3);
            reachFrameIdx{iPart} = [];
        end
%         partEndPtFrame(iPart) = triggerFrame + find(localMins(triggerFrame+1:end,iPart),1);
%         partFinalEndPtFrame(iPart) = triggerFrame + find(localMins(triggerFrame+1:end,iPart),1,'last');
        % make sure we don't take a reach end point that occurs after the
        % paw has been retracted back behind the slot
%         if partEndPtFrame(iPart) > first_paw_return
%             partEndPtFrame(iPart) = first_paw_return;
%         end
%         try
%         partEndPts(iPart,:) = squeeze(xyz_smooth(partEndPtFrame(iPart),:,iPart));
%         catch
%             keyboard
%         end
%         partFinalEndPts(iPart,:) = squeeze(xyz_smooth(partFinalEndPtFrame(iPart),:,iPart));
    end
    if all(partEndPts(iPart,:) == 0)
        partEndPtFrame(iPart) = NaN;
        partFinalEndPtFrame(iPart) = NaN;
        partEndPts(iPart,:) = NaN(1,3);
        partFinalEndPts(iPart,:) = NaN(1,3);
    end
    
end
    
% now come up with an overall endpoint frame
% first choice is the latest frame for one of the digit tips to reach its furthest extension
% exclude the first digit, which is often obscured. also exclude 4th digit
% (pinky) which sometimes moves independently of the rest of the digits
endPtFrame = min(partEndPtFrame(digIdx(2:3)));
final_endPtFrame = min(partFinalEndPtFrame(digIdx(2:3)));
% second choice is the most advanced pip frame
if isnan(endPtFrame)
    endPtFrame = min(partEndPtFrame(pipIdx(2:3)));
end
% third choice is the most advanced pip frame
if isnan(endPtFrame)
    endPtFrame = min(partEndPtFrame(mcpIdx(2:3)));
end
% last choice is paw dorsum
if isnan(endPtFrame)
    endPtFrame = min(partEndPtFrame(pawDorsumIdx));
end
if isnan(final_endPtFrame)
    final_endPtFrame = min(partFinalEndPtFrame(pipIdx(2:3)));
end
% third choice is the most advanced pip frame
if isnan(final_endPtFrame)
    final_endPtFrame = min(partFinalEndPtFrame(mcpIdx(2:3)));
end
% last choice is paw dorsum
if isnan(final_endPtFrame)
    final_endPtFrame = min(partFinalEndPtFrame(pawDorsumIdx));
end

endPts = zeros(numPawParts,3);

if ~isnan(endPtFrame)
    for iPart = 1 : numPawParts
        if all(squeeze(xyz_smooth(endPtFrame,:,iPart))==0)
            endPts(iPart,:) = NaN(1,3);
        else
            endPts(iPart,:) = squeeze(xyz_smooth(endPtFrame,:,iPart));
        end
    end
else
    endPts(iPart,:) = zeros(1,3);
end

final_endPts = zeros(numPawParts,3);

if ~isnan(final_endPtFrame)
    for iPart = 1 : numPawParts
        if all(squeeze(xyz_smooth(final_endPtFrame,:,iPart))==0)
            final_endPts(iPart,:) = NaN(1,3);
        else
            final_endPts(iPart,:) = squeeze(xyz_smooth(final_endPtFrame,:,iPart));
        end
    end
else
    final_endPts(iPart,:) = zeros(1,3);
end

% extraFramesToExtract = 5;
% if ~isnan(endPtFrame) && ~isnan(final_endPtFrame)
%     validLocalMins = localMins(endPtFrame-extraFramesToExtract:final_endPtFrame+extraFramesToExtract,digIdx(2));
%     valid_z_smooth = z_smooth(endPtFrame-extraFramesToExtract:final_endPtFrame+extraFramesToExtract,digIdx(2));
%     
%     reachIdx = find_reaches(validLocalMins,valid_z_smooth,min_z_diff_pre_reach);
% 
% end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function first_paw_return = findFirstPawReturnFrame(pawDorsum_z,z_smooth,paw_through_slot_frame,slot_z)
% % find the first time the paw moves behind the slot after it has passed
% % through the slot. this is a little tricky - need to find the first frame
% % that the paw dorsum passes in front of the reaching slot, then the next
% % frame after that when the paw is behind the slot. the problem is that
% % many times the paw doesn't make it all the way through the slot...
% 
% pd_behind_slot_frames = find(pawDorsum_z > slot_z);
% paw_through_slot_frame_mask = false(size(pawDorsum_z));
% paw_through_slot_frame_mask(paw_through_slot_frame:end) = true;
% pd_through_slot_frame = find((pawDorsum_z < slot_z) & paw_through_slot_frame_mask,1);
% 
% if isempty(pd_through_slot_frame)
%     % if the paw dorsum didn't make it through the slot, use
%     % paw_through_slot_frame as the start of the search for when the paw
%     % moves back behind the slot. This still may not work if the paw dorsum
%     % never gets into the slot...
%     pd_through_slot_frame = paw_through_slot_frame;
% end
% 
% digits_behind_slot_frames = true(size(z_smooth,1),12);
% for iDigitIdx = 1 : 12
%     digits_behind_slot_frames = digits_behind_slot_frames & ((z_smooth(:,iDigitIdx) > slot_z) | isnan(z_smooth(:,iDigitIdx)));
% end
% digits_behind_slot_frames = digits_behind_slot_frames & paw_through_slot_frame_mask;
% 
% first_pd_return = pd_behind_slot_frames(pd_behind_slot_frames > pd_through_slot_frame);
% if isempty(first_pd_return)
%     first_pd_return = length(pawDorsum_z);
% else
%     first_pd_return = first_pd_return(1);
% end
% first_digits_return = find(digits_behind_slot_frames,1);
% 
% first_paw_return = min(first_digits_return,first_pd_return);
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reachIdx = find_reaches(localMins,z,y,min_z_diff_pre_reach,min_z_diff_post_reach,maxFramesPriorToAdvance,extraFramesExtracted,pts_to_extract)



poss_reach_idx = find(localMins);
poss_reach_idx = poss_reach_idx(poss_reach_idx > extraFramesExtracted);
% extra frames prior to triggerFrame should be input to this function; but
% don't allow poss_reach_idx to be returned as an actual reach if before
% the trigger frame
num_poss_reaches = length(poss_reach_idx);

reachIdx = false(length(localMins),1);
for i_possReach = 1 : num_poss_reaches

    % throw out points near the very beginning or end of the time series of
    % z-values (avoid errors, and should have allowed enough buffer when
    % calling this function that these edge points aren't relevant).
    if poss_reach_idx(i_possReach) - pts_to_extract < 1 || ...
            poss_reach_idx(i_possReach) + max(pts_to_extract,maxFramesPriorToAdvance) > length(localMins)
        continue;
    end
    
    % extract z-coordinates near the current local minimum
    z_at_min = z(poss_reach_idx(i_possReach));
    
    % if the paw part advances past its current position, or there is another
    % local minimum in the next maxFramesPriorToAdvance frames, don't count
    % this as a reach
    test_z = z(poss_reach_idx(i_possReach)+1:poss_reach_idx(i_possReach) + maxFramesPriorToAdvance);
    if any(test_z < z_at_min) %|| any(localMins(poss_reach_idx(i_possReach)+1:poss_reach_idx(i_possReach) + maxFramesPriorToAdvance))
        continue;
    end
    
    % if the paw part is moving upwards, don't count it as a reach. It
    % sometimes happens that the paw is resting on the bottom of the slot;
    % to retract, the digits move towards the pellet and up, but this is
    % clearly NOT a reach.
    y_diff = diff(y(poss_reach_idx(i_possReach)-5:poss_reach_idx(i_possReach)));

    % if the paw part is moving up quickly AND there are no points where it was
    % descending quickly, throw it out
    if any(y_diff < -0.4) && ~any(y_diff > 0.4)
        continue;
    end
    % if the paw part retracted at least min_z_diff_pre_reach, count it as
    % a reach. It must have also moved at least z_diff_for_reach forward
    % prior to the reach and then pulled back that far after the reach.
    % extract points prior to potential reach
    test_z_backward = z(poss_reach_idx(i_possReach)-pts_to_extract:poss_reach_idx(i_possReach)-1);
    test_diff_backward = test_z_backward - z_at_min;
    
    test_z_forward = z(poss_reach_idx(i_possReach)+1:poss_reach_idx(i_possReach)+pts_to_extract);
    test_diff_forward = test_z_forward - z_at_min;
    if any(test_diff_backward > min_z_diff_pre_reach) && any(test_diff_forward > min_z_diff_post_reach)
        reachIdx(poss_reach_idx(i_possReach)) = true;
    end
    
end

end