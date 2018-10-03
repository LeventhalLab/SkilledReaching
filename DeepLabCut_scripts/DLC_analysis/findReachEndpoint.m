function [partEndPts,partEndPtFrame,endPts,endPtFrame,pawPartsList] = findReachEndpoint(pawTrajectory, bodyparts,frameRate,frameTimeLimits,pawPref,varargin)
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   frameRate - frame rate in frames per second
%   frameTimeLimits - time of initial and final frames with respect to the
%       trigger event (generally, when the paw is detected by LabView).
%       Use negative times to indicate times before the trigger event
%       (e.g., the first entry should be negative if the first frame is
%       before the trigger event)
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
%       change directions. Currently calculated as the median of the
%       direction-reversal frames for each paw part individually
%   pawPartsList - the list of paw parts in the same order as for the
%       numeric arrays above

smoothSize = 3;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'smoothsize'
            smoothSize = varargin{iarg + 1};
    end
end

triggerFrame = round((-frameTimeLimits(1)) * frameRate);

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
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

% find the first local minimum in the z-dimension after reach onset
xyz_coords = pawTrajectory(:,:,allPawPartsIdx);
z_coords = squeeze(xyz_coords(:,3,:));
z_smooth = smoothdata(z_coords,1,'movmean',smoothSize);
localMins = islocalmin(z_smooth, 1);

partEndPts = zeros(numPawParts,3);
partEndPtFrame = zeros(numPawParts,1);
for iPart = 1 : numPawParts
    
    if any(localMins(triggerFrame+1:end,iPart))
        partEndPtFrame(iPart) = triggerFrame + find(localMins(triggerFrame+1:end,iPart),1);
        partEndPts(iPart,:) = squeeze(xyz_coords(partEndPtFrame(iPart),:,iPart));
    end
    if all(partEndPts(iPart,:) == 0)
        partEndPtFrame(iPart) = NaN;
        partEndPts(iPart,:) = NaN(1,3);
    end
    
end
    
% now come up with an overall endpoint frame - use the median of identified
% frames because why not? Could also try the mode or mean
endPtFrame = round(nanmedian(partEndPtFrame));
endPts = zeros(numPawParts,3);

if ~isnan(endPtFrame)
    for iPart = 1 : numPawParts
        if all(squeeze(xyz_coords(endPtFrame,:,iPart))==0)
            endPts(iPart,:) = NaN(1,3);
        else
            endPts(iPart,:) = squeeze(xyz_coords(endPtFrame,:,iPart));
        end
    end
else
    endPts(iPart,:) = zeros(1,3);
end

end