function newMasks = restrictSilhouettes(fullMasks,...
                                             bbox,...
                                             fundMat,...
                                             imSize)
%                                         
% function to take masks in the direct and mirror views, and clip the masks
% if the projection from one view doesn't extend to the edge of the other
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
%       masks, respectively, after extending them to make sure there are
%       supporting lines for the two masks
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
% 
% for iView = 1 : 2
% 
%     [tangentPoints(:,:,iView), tangentLines(:,:,iView)] = ...
%         findTangentToEpipolarLine(fullMasks{iView}, F, bbox(iView,:));
%     % rearrange tangent points so that top one comes first in both views
%     [~,idx] = sort(tangentPoints(:,2,iView));
%     tangentPoints(:,:,iView) = tangentPoints(idx,:,iView);
%     tangentLines(:,:,iView) = tangentLines(idx,:,iView);
%     bpts(:,:,iView) = lineToBorderPoints(tangentLines(:,:,iView),imSize);
% end

% now, check to see which mask extends higher above the other's projection,
% then find the one that extends below the other's projection
% find the top tangent point in each view

for iView = 1 : 2
    otherView = 3 - iView;
    if iView == 2
        F = fundMat';
    else
        F = fundMat;
    end
    
    projMask = projMaskFromTangentLines(fullMasks{iView}, F, bbox(iView,:), [h,w]);
    newMasks{otherView} = fullMasks{otherView} & projMask;
    
end