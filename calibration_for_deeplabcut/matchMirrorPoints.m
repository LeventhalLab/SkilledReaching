function matchedPoints = matchMirrorPoints(directPoints, mirrorPoints, imSize, mirrorView)

% INPUTS
%   mirrorPoints - m x 2 array of (x,y) points in the mirror view
%   directPoints - m x 2 array of (x,y) points in the direct view
%   mirrorView - 'left','right', or 'top'
%   m - number of checkerboard rows
%   n - number of checkerboard columns

% I think for both left and right views, can just order points from top to
% bottom to match them. Do we need to know which rows they're in too?

% squareSize = 8;    % mm
% for iarg = 1 : 2 : nargin - 3
%     switch lower(varargin{iarg})
%         case 'squaresize'
%             squareSize = varargin{iarg + 1};
%     end
% end

if size(mirrorPoints,1) ~= size(directPoints,1)
    error('mirrorPoints and directPoints must have the same number of rows')
end

h = imSize(1);
w = imSize(2);
num_points = size(mirrorPoints,1);
if num_points ~= size(directPoints,1)
    error('directPoints and mirrorPoints must have the same number of rows')
end

matchedPoints = zeros(num_points,2,2);
testMatch = zeros(num_points,2,2);

% there are num_points*(num_points-1) possible matches. The right one
% should converge on the same epipolar point that is outside the image
switch mirrorView
    case {'left','right'}
        % left-most and right-most points should be inverted (but may not
        % be based on angle, so try without this match)
%         direct_ltIdx = directPoints(:,1) == min(directPoints(:,1));
%         direct_rtIdx = directPoints(:,1) == max(directPoints(:,1));
%         mirror_ltIdx = mirrorPoints(:,1) == min(mirrorPoints(:,1));
%         mirror_rtIdx = mirrorPoints(:,1) == max(mirrorPoints(:,1));
%         
%         testMatch(1,:,1) = directPoints(direct_ltIdx,:);
%         testMatch(2,:,1) = directPoints(direct_rtIdx,:);
%         testMatch(1,:,2) = mirrorPoints(mirror_rtIdx,:);
%         testMatch(2,:,2) = mirrorPoints(mirror_ltIdx,:);
        
        % the top and bottom points should match
        direct_topIdx = directPoints(:,2) == min(directPoints(:,2));
        direct_botIdx = directPoints(:,2) == max(directPoints(:,2));
        mirror_topIdx = mirrorPoints(:,2) == min(mirrorPoints(:,2));
        mirror_botIdx = mirrorPoints(:,2) == max(mirrorPoints(:,2));
        
        testMatch(1,:,1) = directPoints(direct_topIdx,:);
        testMatch(2,:,1) = directPoints(direct_botIdx,:);
        testMatch(1,:,2) = mirrorPoints(mirror_topIdx,:);
        testMatch(2,:,2) = mirrorPoints(mirror_botIdx,:);
    case 'top'
        % left-most and right-most points should match.
        direct_ltIdx = directPoints(:,1) == min(directPoints(:,1));
        direct_rtIdx = directPoints(:,1) == max(directPoints(:,1));
        mirror_ltIdx = mirrorPoints(:,1) == min(mirrorPoints(:,1));
        mirror_rtIdx = mirrorPoints(:,1) == max(mirrorPoints(:,1));
        
        testMatch(1,:,1) = directPoints(direct_ltIdx,:);
        testMatch(2,:,1) = directPoints(direct_rtIdx,:);
        testMatch(1,:,2) = mirrorPoints(mirror_ltIdx,:);
        testMatch(2,:,2) = mirrorPoints(mirror_rtIdx,:);
        
%         % the top-most direct point should match with the bottom-most
%         % mirror point (and vice-versa)
%         direct_topIdx = directPoints(:,2) == min(directPoints(:,2));
%         direct_botIdx = directPoints(:,2) == max(directPoints(:,2));
%         mirror_topIdx = mirrorPoints(:,2) == min(mirrorPoints(:,2));
%         mirror_botIdx = mirrorPoints(:,2) == max(mirrorPoints(:,2));
%         
%         testMatch(3,:,1) = directPoints(direct_topIdx,:);
%         testMatch(4,:,1) = directPoints(direct_botIdx,:);
%         testMatch(3,:,2) = mirrorPoints(mirror_botIdx,:);
%         testMatch(4,:,2) = mirrorPoints(mirror_topIdx,:);
end

% find epipole based on these matched points
testLines = zeros(2,3);
linePoints = zeros(2,2);
for ii = 1 : size(testLines,1)
    linePoints(1,:) = squeeze(testMatch(ii,:,1));   % direct view
    linePoints(2,:) = squeeze(testMatch(ii,:,2));   % mirror view
    
    testLines(ii,:) = lineCoeffFromPoints(linePoints);
end
epiPt = findIntersection(testLines(1,:),testLines(2,:));

%%%%%%%
testPts = lineToBorderPoints(testLines,imSize);
figure(1)
hold on
line(testPts(1,[1,3]),testPts(1,[2,4]))
line(testPts(2,[1,3]),testPts(2,[2,4]))


% find the convex hull of the direct and mirror points
direct_cvHull = convhull(directPoints(:,1),directPoints(:,2));
mirror_cvHull = convhull(mirrorPoints(:,1),mirrorPoints(:,2));

% match the convex hull points

direct_hullMask = poly2mask(directPoints(direct_cvHull,1),directPoints(direct_cvHull,2),h,w);
mirror_hullMask = poly2mask(mirrorPoints(mirror_cvHull,1),mirrorPoints(mirror_cvHull,2),h,w);


switch mirrorView
    case 'left'
        sortColumnIdx = 2;
        % points are reversed left-right but are in the same order top-bottom
        
        % find the extreme points that should consistently match (i.e., top and
        % bottom or left and right)
        [~,mirrorSortIdx] = sort(mirrorPoints(:,sortColumnIdx),1);
        [~,directSortIdx] = sort(directPoints(:,sortColumnIdx),1);

        % match the top and bottom points to determine the geometric
        % transformation accomplished by the mirror
        Mdirect = [directPoints(directSortIdx(1),:);
                   directPoints(directSortIdx(2),:);
                   directPoints(directSortIdx(end-1),:);
                   directPoints(directSortIdx(end),:);];
        Mmirror = [mirrorPoints(mirrorSortIdx(1),:);
                   mirrorPoints(mirrorSortIdx(2),:);
                   mirrorPoints(mirrorSortIdx(end-1),:);
                   mirrorPoints(mirrorSortIdx(end),:)];
       
    case 'right'
        sortColumnIdx = 2;
        % points are reversed left-right but are in the same order top-bottom  
        
        % find the extreme points that should consistently match (i.e., top and
        % bottom or left and right)
        [~,mirrorSortIdx] = sort(mirrorPoints(:,sortColumnIdx),1);
        [~,directSortIdx] = sort(directPoints(:,sortColumnIdx),1);

        % match the top and bottom points to determine the geometric
        % transformation accomplished by the mirror
        Mdirect = [directPoints(directSortIdx(1),:);
                   directPoints(directSortIdx(2),:);
                   directPoints(directSortIdx(end-1),:);
                   directPoints(directSortIdx(end),:);];
        Mmirror = [mirrorPoints(mirrorSortIdx(1),:);
                   mirrorPoints(mirrorSortIdx(2),:);
                   mirrorPoints(mirrorSortIdx(end-1),:);
                   mirrorPoints(mirrorSortIdx(end),:)];
               
    case 'top'
        % points are reversed top-bottom but are in the same order
        % left-right
        [~,LRdirectSortIdx] = sort(directPoints(:,1),1);
        [~,LRmirrorSortIdx] = sort(mirrorPoints(:,1),1);
        
        [~,TBdirectSortIdx] = sort(directPoints(:,2),1);
        [~,TBmirrorSortIdx] = sort(mirrorPoints(:,2),1);
        
        % match the top and bottom points and left/right points. Note that
        % the top point in the mirror view is the bottom point in the
        % direct view and vice versa
        Mdirect = [directPoints(LRdirectSortIdx(1),:);
                   directPoints(TBdirectSortIdx(1),:);
                   directPoints(TBdirectSortIdx(end),:);
                   directPoints(LRdirectSortIdx(end),:);];
        Mmirror = [mirrorPoints(LRmirrorSortIdx(1),:);
                   mirrorPoints(TBmirrorSortIdx(end),:);
                   mirrorPoints(TBmirrorSortIdx(1),:);
                   mirrorPoints(LRmirrorSortIdx(end),:)];
end

tform = estimateGeometricTransform(Mdirect, Mmirror, 'affine');

% transform direct points to mirror points
direct_hom = [directPoints,ones(size(directPoints,1),1)];
transformedDirect = direct_hom * tform.T;
transformedDirect = transformedDirect(:,1:2);


% now match points one by one
nndist = zeros(size(mirrorPoints,1),1);
for iPt = 1 : size(directPoints, 1)
    [nndist(iPt),nnidx] = findNearestNeighbor(mirrorPoints(iPt,:), transformedDirect);
    matchedPoints(iPt,:,1) = directPoints(nnidx,:);
    matchedPoints(iPt,:,2) = mirrorPoints(iPt,:);
end

end
