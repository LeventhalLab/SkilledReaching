function [partEndPts,partEndPtFrame,endPts,endPtFrame,pawPartsList] = findReachEndpoint(pawTrajectory, bodyparts,frameRate,frameTimeLimits,pawPref,paw_through_slot_frame,isEstimate,varargin)
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFrame x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   frameRate - frame rate in frames per second
%   frameTimeLimits - time of initial and final frames with respect to the
%       trigger event (generally, when the paw is detected by LabView).
%       Use negative times to indicate times before the trigger event
%       (e.g., the first entry should be negative if the first frame is
%       before the trigger event)
%   isEstimate - 
%
% OUTPUTS
%   partEndPts - m x 3 matrix where m is the number of paw parts and each
%       row is the (x,y,z) point where z-coordinate reaches a local minimum
%       after the trigger frame. NaN for frames where the paw part isn't
%       visible in both views
%   partEndPtFrame - vector of length m (number of paw parts) containing
%       the frame number at which each paw part reversed z-direction after
%       the trigger frame
%   endPts - same as partEndPts, but contains the coordinates at endPtFrame
%       for each body part
%   endPtFrame - single frame at which the paw as a whole is believed to
%       change directions. Currently calculated as the maximum frame at
%       which any of the last 3 digits (exclude index since often occluded)
%       changes direction
%   pawPartsList - the list of paw parts in the same order as for the
%       numeric arrays above

smoothSize = 3;
slot_z = 25;
% slot_z = 200;    % distance from the camera to the slot. hard-coded for now, eventually should mark this somehow in the video

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'smoothsize'
            smoothSize = varargin{iarg + 1};
        case 'slot_z'
            slot_z = varargin{iarg + 1};
    end
end

video_triggerFrame = round((-frameTimeLimits(1)) * frameRate);
% replace trigger frame as assessed by number of frames before video
% trigger with the first frame where the paw is in front of the slot
% (below)

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

pawDorsum_z = squeeze(pawTrajectory(:,3,pawDorsumIdx));
% numFrames = length(pawDorsum_z);

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
for ii = 1 : length(pawDorsumIdx)
    curPartIdx = curPartIdx + 1;
    pawPartsList{curPartIdx} = bodyparts{pawDorsumIdx(ii)};
    allPawPartsIdx(curPartIdx) = pawDorsumIdx(ii);
end

if isnan(paw_through_slot_frame)
    % something happened that it couldn't find a clean movement of the paw
    % through the reaching slot earlier
    partEndPtFrame = NaN(numPawParts,1);
    endPtFrame = NaN;
    partEndPts = zeros(numPawParts,3);
    endPts = zeros(numPawParts,3);
    return
end

% find the first local minimum in the z-dimension after reach onset
xyz_coords = pawTrajectory(:,:,allPawPartsIdx);
xyz_smooth = zeros(size(xyz_coords));
% find all frames where one of the points was estimated (maybe good enough
% to use just the mirror frame?), and exclude them
pawPartEstimates = squeeze(isEstimate(allPawPartsIdx,:,1)) | squeeze(isEstimate(allPawPartsIdx,:,2));
for iPart = 1 : numPawParts
    xyz_coords(pawPartEstimates(iPart,:)',:,iPart) = NaN;
    xyz_part = squeeze(xyz_coords(:,:,iPart));
    xyz_smooth(:,:,iPart) = smoothdata(xyz_part,1,'movmean',smoothSize);
end
z_smooth = squeeze(xyz_smooth(:,3,:));

% z_smooth = smoothdata(z_coords,1,'movmean',smoothSize);
localMins = islocalmin(z_smooth, 1);

% find the first time the paw moves behind the slot after paw_through_slot_frame
% paw_behind_slot_frames = find(pawDorsum_z > slot_z);
% first_paw_return = paw_behind_slot_frames(paw_behind_slot_frames > paw_through_slot_frame);
% if isempty(first_paw_return)
%     first_paw_return = numFrames;
% else
%     first_paw_return = first_paw_return(1);
% end

try
first_paw_return = findFirstPawReturnFrame(pawDorsum_z,z_smooth,paw_through_slot_frame,slot_z);
catch
    keyboard
end

% triggerFrame = min(paw_through_slot_frame,video_triggerFrame); % probably not necessary
triggerFrame = paw_through_slot_frame; % probably not necessary
partEndPts = zeros(numPawParts,3);
partEndPtFrame = zeros(numPawParts,1);
for iPart = 1 : numPawParts
    
    if any(localMins(triggerFrame+1:end,iPart))
        partEndPtFrame(iPart) = triggerFrame + find(localMins(triggerFrame+1:end,iPart),1);
        % make sure we don't take a reach end point that occurs after the
        % paw has been retracted back behind the slot
        if partEndPtFrame(iPart) > first_paw_return
            partEndPtFrame(iPart) = first_paw_return;
        end
        partEndPts(iPart,:) = squeeze(xyz_smooth(partEndPtFrame(iPart),:,iPart));
    end
    if all(partEndPts(iPart,:) == 0)
        partEndPtFrame(iPart) = NaN;
        partEndPts(iPart,:) = NaN(1,3);
    end
    
end
    
% now come up with an overall endpoint frame
% first choice is the latest frame for one of the digit tips to reach its furthest extension
% exclude the first digit, which is often obscured. also exclude 4th digit
% (pinky) which sometimes moves independently of the rest of the digits
endPtFrame = min(partEndPtFrame(digIdx(2:3)));
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

% endPtFrame = round(nanmedian(partEndPtFrame));
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

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function first_paw_return = findFirstPawReturnFrame(pawDorsum_z,z_smooth,paw_through_slot_frame,slot_z)
% find the first time the paw moves behind the slot after it has passed
% through the slot. this is a little tricky - need to find the first frame
% that the paw dorsum passes in front of the reaching slot, then the next
% frame after that when the paw is behind the slot. the problem is that
% many times the paw doesn't make it all the way through the slot...

pd_behind_slot_frames = find(pawDorsum_z > slot_z);
paw_through_slot_frame_mask = false(size(pawDorsum_z));
paw_through_slot_frame_mask(paw_through_slot_frame:end) = true;
pd_through_slot_frame = find((pawDorsum_z < slot_z) & paw_through_slot_frame_mask,1);

if isempty(pd_through_slot_frame)
    % if the paw dorsum didn't make it through the slot, use
    % paw_through_slot_frame as the start of the search for when the paw
    % moves back behind the slot. This still may not work if the paw dorsum
    % never gets into the slot...
    pd_through_slot_frame = paw_through_slot_frame;
end

digits_behind_slot_frames = true(size(z_smooth,1),12);
for iDigitIdx = 1 : 12
    digits_behind_slot_frames = digits_behind_slot_frames & ((z_smooth(:,iDigitIdx) > slot_z) | isnan(z_smooth(:,iDigitIdx)));
end
digits_behind_slot_frames = digits_behind_slot_frames & paw_through_slot_frame_mask;

first_pd_return = pd_behind_slot_frames(pd_behind_slot_frames > pd_through_slot_frame);
if isempty(first_pd_return)
    first_pd_return = length(pawDorsum_z);
else
    first_pd_return = first_pd_return(1);
end
first_digits_return = find(digits_behind_slot_frames,1);

first_paw_return = min(first_digits_return,first_pd_return);

% if isempty(first_paw_return)
%     first_paw_return = length(pawDorsum_z);
% else
%     first_paw_return = first_paw_return(1);
% end

end