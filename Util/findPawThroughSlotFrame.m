function [paw_through_slot_frame,varargout] = findPawThroughSlotFrame(pawTrajectory, bodyparts, pawPref, varargin)
%
% INPUTS
%
% OUTPUTS
%

slot_z = 200; 

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

if nargin == 3
    slot_z = varargin{1};
end


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

xyz_coords = pawTrajectory(:,:,allPawPartsIdx);
z_coords = squeeze(xyz_coords(:,3,:));
z_coords(z_coords == 0) = NaN;


% find the first time the paw moves in front of the slot
firstSlotBreak = NaN(numPawParts,1);
for iPart = 1 : numPawParts
    temp = z_coords(:,iPart);
    temp(temp == 0) = NaN;
    tempFrame = find(temp < slot_z,1,'first');
    if ~isempty(tempFrame)
        firstSlotBreak(iPart) = tempFrame;
    end
end

varargout{1} = firstSlotBreak;
paw_through_slot_frame = min(firstSlotBreak);