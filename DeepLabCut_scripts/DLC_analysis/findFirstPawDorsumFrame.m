function firstPawDorsumFrame = findFirstPawDorsumFrame(pawDorsum_p,paw_z,paw_through_slot_frame,reproj_error,varargin)
%
% INPUTS
%   pawDorsum_p - numFrames length vector containing certainty values for
%       paw dorsum identification in the mirror view from DLC
%   paw_z - z-coordinates of the paw dorsum from the 3-D reconstruction
%   paw_through_slot_frame - frame where the paw first appeared outside the
%       box
%   reproj_error - numFrames x 2 array containing the paw dorsum
%       reprojection errors in the direct (reproj_error(:,1)) and mirror
%       (reproj_error(:,2)) views
%
% VARARGS
%   pthresh - minimum acceptable certainty value from DLC for identifying
%       the paw dorsum in the mirror view
%   min_consec_frames - minimum number of consecutive frames in which the
%       paw dorsum must be found in the mirror view
%   max_consecutive_misses - maximum number of consecutive frames for which
%       there could be a gap where the paw isn't visible in the mirror view
%   maxreprojerror - maximum tolerable reprojection error
%
% OUPTUTS
%   firstPawDorsumFrame - first frame that the paw dorsum is reliably
%       identified in the mirror view, and an acceptable match could be
%       found in the direct view (even if just an estimate based on the
%       location of the digits)

if isnan(paw_through_slot_frame)
    firstPawDorsumFrame = NaN;
    return;
end

pThresh = 0.98;   % minimum prob of finding the paw dorsum in the mirror view
min_consec_frames = 5;   % minimum number of consecutive frames in which the paw dorsum must be found in the mirror view
max_consecutive_misses = 50;   % maximum number of consecutive frames for which there could be a gap where the paw isn't visible in the mirror view
maxReprojError = 10;    % if paw dorsum found in both views, only count it if they are more or less on the same epipolar line
slot_z = 200;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'pthresh'
            pThresh = varargin{iarg + 1};
        case 'min_consec_frames'
            min_consec_frames = varargin{iarg + 1};
        case 'max_consecutive_misses'
            max_consecutive_misses = varargin{iarg + 1};
        case 'maxreprojerror'
            maxReprojError = varargin{iarg + 1};
        case 'slot_z'
            slot_z = varargin{iarg + 1};
    end
end

pawDorsum_p = pawDorsum_p(1:paw_through_slot_frame);
paw_z = paw_z(1:paw_through_slot_frame);
reproj_error = reproj_error(1:paw_through_slot_frame,:);

if isrow(pawDorsum_p)
    pawDorsum_p = pawDorsum_p';
end
if isrow(paw_z)
    paw_z = paw_z';
end
% find the first frame before the paw_through_slot_frame where mirror_p >
% pThresh and a valid trajectory point was found (so there must have also
% been at least some points found in the direct view), and this is true for
% at least min_consec_frames frames in a row

validPawDorsumIdx = (pawDorsum_p > pThresh) & ... % only accept points identified with high probability
                    (paw_z > slot_z) & ...     % only accept points on the far side of the reaching slot
                    (reproj_error(:,1) < maxReprojError) & ...   % only accept points that are near the epipolar line defined by the direct view observation (if present)
                    (reproj_error(:,2) < maxReprojError);        % only accept points that are near the epipolar line defined by the direct view observation (if present)
try
    validPawDorsumBorders = findConsecutiveEntries(validPawDorsumIdx);
catch
    keyboard
end
if isempty(validPawDorsumBorders)
    firstPawDorsumFrame = paw_through_slot_frame;
    return;
end

% find the last gap in finding the paw dorsum in the mirror that is longer
% than max_consecutive_misses
invalidPawDorsumBorders = findConsecutiveEntries(~validPawDorsumIdx);
if isempty(invalidPawDorsumBorders)
    minPawDorsumFrame = 0;
else
    invalidStreakLengths = invalidPawDorsumBorders(:,2) - invalidPawDorsumBorders(:,1) + 1;
    invalidStreaksEnd = find(invalidStreakLengths > max_consecutive_misses,1,'last');
    if isempty(invalidStreaksEnd)
        minPawDorsumFrame = 0;
    else
        minPawDorsumFrame = invalidPawDorsumBorders(invalidStreaksEnd,2);
    end
end
validPawDorsumBorders = validPawDorsumBorders(validPawDorsumBorders(:,1) > minPawDorsumFrame,:);

if isempty(validPawDorsumBorders)
    firstPawDorsumFrame = paw_through_slot_frame;
    return;
end

streakLengths = validPawDorsumBorders(:,2) - validPawDorsumBorders(:,1) + 1;
streak_idx = find(streakLengths >= min_consec_frames,1);

if isempty(streak_idx)
    % this could happen if there aren't enough consecutive frames with a
    % high enough probability of accurately finding the paw dorsum
    firstPawDorsumFrame = paw_through_slot_frame;
    return;
end

valid_z_idx = validPawDorsumBorders(streak_idx,1) : validPawDorsumBorders(streak_idx,2);
max_z_idx = find(paw_z(valid_z_idx) == max(paw_z(valid_z_idx)),1);

firstPawDorsumFrame = valid_z_idx(max_z_idx);

end