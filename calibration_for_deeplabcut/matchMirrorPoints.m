function matchedPoints = matchMirrorPoints(directPoints, mirrorPoints, mirrorView)

% INPUTS
%   mirrorPoints - m x 2 array of (x,y) points in the mirror view
%   directPoints - m x 2 array of (x,y) points in the direct view
%   mirrorView - 'left','right', or 'top'
%   m - number of checkerboard rows
%   n - number of checkerboard columns


squareSize = 4;    % mm

if size(mirrorPoints,1) ~= size(directPoints,1)
    error('mirrorPoints and directPoints must have the same number of rows')
end

matchedPoints = zeros(size(mirrorPoints,1),2,2);

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
