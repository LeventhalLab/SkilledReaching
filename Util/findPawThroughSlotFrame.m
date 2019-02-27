function [paw_through_slot_frame,firstSlotBreak,first_pawPart_outside_box,maxDigitReachFrame] = findPawThroughSlotFrame(pawTrajectory, bodyparts, pawPref, invalid_direct, invalid_mirror, reproj_error, varargin)
%
% INPUTS
%   pawTrajectory - 
%   bodyparts
%   pawPref - 'right' or 'left'
%   invalid_direct
%   invalid_mirror
%
% OUTPUTS
%   paw_through_slot_frame - the first 
%   firstSlotBreak
%   first_pawPart_outside_box
%   maxPawReachFrame

slot_z = 200; 
maxReprojError = 10;
min_consec_frames = 5;

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'maxreprojerror'
            maxReprojError = varargin{iarg + 1};
        case 'slot_z'
            slot_z = varargin{iarg + 1};
        case 'minconsecframes'
            min_consec_frames = varargin{iarg + 1};
    end
end

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

% only look for paw coming through the slot after the paw has been
% identified behind the front panel
pawDorsum_z = pawTrajectory(:,3,pawDorsumIdx);
pawDorsum_mirror_valid = ~invalid_mirror(pawDorsumIdx,:);
pawDorsum_reproj_error = squeeze(reproj_error(pawDorsumIdx,:,:));

if isrow(pawDorsum_z)
    pawDorsum_z = pawDorsum_z';
end
if isrow(pawDorsum_mirror_valid)
    pawDorsum_mirror_valid = pawDorsum_mirror_valid';
end

% truncate pawDorsum_mirror_valid, which has the same number of points as
% most of the videos. However, sometimes a video recording gets cut off,
% and pawDorsum_z will not have as many points
numFramesInThisVideo = size(pawDorsum_z,1);
validPawDorsumIdx = (pawDorsum_mirror_valid(1:numFramesInThisVideo)) & ... % only accept points identified with high probability
                    (pawDorsum_z > slot_z) & ...     % only accept points on the far side of the reaching slot
                    (pawDorsum_reproj_error(:,1) < maxReprojError) & ...   % only accept points that are near the epipolar line defined by the direct view observation (if present)
                    (pawDorsum_reproj_error(:,2) < maxReprojError);   
firstValidPawDorsum = find(validPawDorsumIdx,1);
if isempty(firstValidPawDorsum)
    firstValidPawDorsum = 1;
end
pastValidDorsum = false(size(validPawDorsumIdx));
pastValidDorsum(firstValidPawDorsum:end) = true;
                
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

xyz_coords = pawTrajectory(:,:,allPawPartsIdx);
z_coords = squeeze(xyz_coords(:,3,:));

for iPart = 1 : numPawParts
    part_reproj_error = squeeze(reproj_error(iPart,:,:));
    invalid_reproj = part_reproj_error(:,1) > maxReprojError | ...
                     part_reproj_error(:,2) > maxReprojError;

    z_coords(invalid_direct(iPart,1:numFramesInThisVideo),iPart) = NaN;
    z_coords(invalid_mirror(iPart,1:numFramesInThisVideo),iPart) = NaN;
    z_coords(invalid_reproj,iPart) = NaN;
end

% find the first time the paw moves in front of the slot
firstSlotBreak = NaN(numPawParts,1);
first_pawPart_outside_box = NaN(numPawParts,1);

digit_z = z_coords(:,digIdx);
% find the farthest z-coordinate of any of the digits
min_digit_z = min(digit_z(:));
% assume that one of the digit tips has to be the first visible paw part
% through the slot, but only after the paw dorsum has been found behind the
% slot
for iDigit = 1 : length(digIdx)
    
    temp = z_coords(:,digIdx(iDigit));
    
    if any(temp == min_digit_z)
        maxDigitReachFrame = find(temp == min_digit_z,1);   % only take the first time the paw got out that far, though seems unlikely it would get to the exact same z-coordinate twice
    end

    tempFrame = temp < slot_z & pastValidDorsum;   % only take frames where a digit tip is already through the slot, and the paw dorsum was found behind the slot
    all_tempFrame = temp < slot_z;   % all frames, including before the paw dorsum was found inside the box
    through_slot_borders = findConsecutiveEntries(tempFrame);   % look for consecutive frames with the paw outside the box after paw dorsum found inside the box
    past_slot_borders = findConsecutiveEntries(all_tempFrame);  % same, but including before the paw dorsum was found inside the box
    if ~isempty(through_slot_borders)
        % WILL SKIP THIS IF... SEGMENT IF
        % couldn't find this digit AFTER the paw dorsum was found behind
        % the slot. On a handful of trials, the paw through the slot
        % already at frame 1, then the rat pulled it back and never reached
        % again.
        
        streakLengths = through_slot_borders(:,2) - through_slot_borders(:,1) + 1;
        streak_idx = find(streakLengths > min_consec_frames,1);

        if isempty(streak_idx)
            firstSlotBreak(digIdx(iDigit)) = find(tempFrame,1);
        else
            firstSlotBreak(digIdx(iDigit)) = through_slot_borders(streak_idx,1);
        end
    end
    if ~isempty(past_slot_borders)
        streakLengths = past_slot_borders(:,2) - past_slot_borders(:,1) + 1;
        streak_idx = find(streakLengths > min_consec_frames,1);

        if isempty(streak_idx)
            first_pawPart_outside_box(digIdx(iDigit)) = find(all_tempFrame,1);
        else
            first_pawPart_outside_box(digIdx(iDigit)) = past_slot_borders(streak_idx,1);
        end
    end
end
    
paw_through_slot_frame = min(firstSlotBreak);

for iPart = 1 : numPawParts
    
    if ~any(ismember(digIdx,iPart))    % don't redo the digit tips
        
        temp = z_coords(:,iPart);
    %     temp(temp == 0) = NaN;
    %     tempFrame = find(temp < slot_z,1,'first');
        tempFrame = temp < slot_z & pastValidDorsum;   % only take frames where a digit tip is already through the slot, and the paw dorsum was found behind the slot
        all_tempFrame = temp < slot_z;   % all frames, including before the paw dorsum was found inside the box
        through_slot_borders = findConsecutiveEntries(tempFrame);
        through_slot_borders = findConsecutiveEntries(tempFrame);   % look for consecutive frames with the paw outside the box after paw dorsum found inside the box
        past_slot_borders = findConsecutiveEntries(all_tempFrame);  % same, but including before the paw dorsum was found inside the box
        if ~isempty(through_slot_borders)
            streakLengths = through_slot_borders(:,2) - through_slot_borders(:,1) + 1;
            streak_idx = find(streakLengths > min_consec_frames,1);

            if isempty(streak_idx)
                firstSlotBreak(iPart) = find(tempFrame,1);
            else
                firstSlotBreak(iPart) = through_slot_borders(streak_idx,1);
            end
        end
        if ~isempty(past_slot_borders)
            streakLengths = past_slot_borders(:,2) - past_slot_borders(:,1) + 1;
            streak_idx = find(streakLengths > min_consec_frames,1);

            if isempty(streak_idx)
                first_pawPart_outside_box(iPart) = find(all_tempFrame,1);
            else
                first_pawPart_outside_box(iPart) = past_slot_borders(streak_idx,1);
            end
        end

    end
%     if ~isempty(tempFrame)
%         firstSlotBreak(iPart) = tempFrame;
%     end
end
