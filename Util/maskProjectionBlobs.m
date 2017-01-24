function newMasks = maskProjectionBlobs(fullMasks,...
                                             bbox,...
                                             fundMat,...
                                             imSize)
%                                         
% function to take masks in the direct and mirror views, and only keep them
% if they overlap with a blob in the other view
%
% INPUTS:
%   fullMasks - 1 x 2 cell array containing the direct and mirror view
%       masks, respectively
%   bbox - 2x4 matrix where each row is [x,y,w,h], where (x,y) is the top
%       left coordinate of the bounding box, w and h are width and height,
%       respectively. First row is for direct view, second row is for
%       mirror view
%   fundMat - fundamental matrix going from the direct view to mirror view
%   imSize - [h,w], where h and w are the height and width of the full
%       image, respectively
%
% OUTPUTS:
%   newMasks - 1 x 2 cell array containing the direct and mirror view
%       masks, respectively, after eliminating blobs that don't have a
%       correspondence in the other view
%
h = imSize(1); w = imSize(2);

% tangentPoints = zeros(2,2,2);    % mxnxp where m is number of points, n is (x,y), p is the view index (1 for direct, 2 for mirror)
% tangentLines = zeros(2,3,2);     % mxnxp where m is number of points, n is (A,B,C), p is the view index (1 for direct, 2 for mirror)
% epiPts = zeros(2,4,2);           % mxnxp where m is number of points, n is (x1,y1,x2,y2), p is the view index (1 for direct, 2 for mirror)
% matchLineIdx = zeros(2,2);       % mxn where m is upper vs lower line (idx 1 for upper, 2 for lower), n is the view idx (1 = direct, 2 = mirror)
% bpts = zeros(2,4,2);

newMasks = fullMasks;

if ~any(fullMasks{1}(:)) || ~any(fullMasks{2}(:))
    return;
end

fullSizeMask = cell(1,2);
for ii = 1 : 2
    fullSizeMask{ii} = false(imSize);
    fullSizeMask{ii}(bbox(ii,2):bbox(ii,2)+bbox(ii,4),bbox(ii,1):bbox(ii,1)+bbox(ii,3)) = fullMasks{ii};
end

% loop through every blob in each view; if its projection doesn't overlap
% at all with a blob in the other view, get rid of it

for iView = 1 : 2
    otherView = 3 - iView;
    if iView == 2
        F = fundMat';
    else
        F = fundMat;
    end
    
    currentViewLabelMask = bwlabel(fullMasks{iView});
    for ii = 1 : max(currentViewLabelMask(:))
        curBlob = (currentViewLabelMask == ii);
        projMask = projMaskFromTangentLines(curBlob, F, bbox(iView,:), imSize);
        testMask = projMask & fullSizeMask{otherView};
        if ~any(testMask(:))   % if no overlap between the current blob and anything in the other view, get rid of it
            newMasks{iView} = newMasks{iView} & ~curBlob;
        end
    end
    
end