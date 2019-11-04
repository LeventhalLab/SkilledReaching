function reachStartFrame = findReachStart_pastSlot(trajectory,bodyparts,pawPref,endPtFrame,slot_z,initPellet_z)
%
% function to find the first frame that a given reach was "initiated" -
% that is, where the rat was clearly moving its paw forward to make a
% discrete reach
%
% INPUTS
%   trajectory - m x n x p array where m is the number of frames, n is 3
%       (x,y,z coordinates), and p is number of bodyparts
%   bodyparts - cell array containing the list of bodyparts
%   pawPref - preferred reaching paw; 'right' or 'left'
%   endPtFrame - estimated frame at which the end point occurred for this
%       reach
%   slot_z - z-coordinate of the reaching slot/front panel of the box
%   initPellet_z - initial z-coordinate of the pellet for this trial (or
%       if no pellet found, average of z-coordinate of pellet when it was
%       found in this session)
%
% OUTPUTS
%   reachStartFrame - 
%

digitsToTrack = [2,3];
[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

% look for the first point where z is less than the slot location prior to
% the current reach end point. This may be overly simple - for example,
% might want to use the first time when z is monotonically decreasing after
% passing through the slot.

slot_z_wrt_pellet = slot_z - initPellet_z + 1.5;   % added 1.5 to give some cushion for measurement error

if isnan(endPtFrame)
    reachStartFrame = NaN;
    return
end

z = squeeze(trajectory(1:endPtFrame,3,digIdx(digitsToTrack)));
% pawDorsum_z = squeeze(trajectory(1:endPtFrame,3,pawDorsumIdx));

numDigits = size(z,2);
digStartFrame = NaN(numDigits,1);
for iDigit = 1 : numDigits
    % find the last z point that was behind the slot
    lastBehindSlotFrame = find(z(:,iDigit)>slot_z_wrt_pellet,1,'last');
    if isempty(lastBehindSlotFrame)
        lastBehindSlotFrame = 1;   % digit must not have been found inside the box
    end
    firstPreSlotFrame = find(z(lastBehindSlotFrame:end,iDigit)<slot_z_wrt_pellet,1,'first');
    if isempty(firstPreSlotFrame)   % maybe if one of the digits wasn't detected, the other was
        continue;
    end
    digStartFrame(iDigit) = firstPreSlotFrame + lastBehindSlotFrame - 1;

end
reachStartFrame = min(digStartFrame);

end

