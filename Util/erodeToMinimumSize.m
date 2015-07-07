function new_mask = erodeToMinimumSize(old_mask, minSize)
%
% usage:
%
%
%
% INPUTS:
%
% OUTPUTS:
%

SE = strel('disk',1);

new_mask   = old_mask;
erodedMask = false(size(old_mask));

if ~any(old_mask(:))    
    return
end

while any(new_mask(:))
    
    labelMat = bwlabel(new_mask);
    
    s = regionprops(new_mask,'Area');
    A = [s.Area];
    
    validIdx = find(A < minSize);
    for ii = 1 : length(validIdx)
        erodedMask = erodedMask | (labelMat == validIdx(ii));
    end
    
    new_mask = new_mask & ~erodedMask;   % eliminate blobs from the algorithm that are already small enough
    
    new_mask = imerode(new_mask, SE);
    
end

new_mask = erodedMask;