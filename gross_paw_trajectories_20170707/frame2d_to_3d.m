function [ points3d ] = frame2d_to_3d( points2d, boxCalibration, pawPref, imSize, epipole, varargin )
%points2d_to_3d Summary of this function goes here
%   Detailed explanation goes here

showSilhouettes = true;
refine_estimates = true;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'refineestimates'
            refine_estimates = varargin{iarg + 1};
        case 'showsilhouettes'
            showSilhouettes = varargin{iarg + 1};
    end
end

P1 = eye(4,3);
sf = mean(boxCalibration.srCal.sf,1);
switch lower(pawPref)
    case 'right'
        P2 = squeeze(boxCalibration.srCal.P(:,:,1));
        sf = sf(1);
    case 'left'
        P2 = squeeze(boxCalibration.srCal.P(:,:,2));
        sf = sf(2);
                            % need to figure out how I organized the scale factor matrix and comment that into the estimate scale function
                                                                   % looks like the columns are the view: 1 = left, 2 = right. The rows are the independent estimates for pairs of rubiks spacings. So, should take the mean across rows to estimate the scale factor in each mirror view                   
end

% calculate the convex hulls of the direct and mirror views
% index 1 is the direct view, 2 is the mirror view
tanPts = zeros(2,2,2);   % x,y,view
tanLines = zeros(2,3,2);   % x,y,view
borderpts = zeros(2,4,2);
for iView = 1 : 2
    pawOutline = false(imSize);
    for ii = 1 : size(points2d{iView},1)
        pawOutline(points2d{iView}(ii,2),points2d{iView}(ii,1)) = true;
    end
    pawMask{iView} = bwconvhull(pawOutline,'union');
    [tanPts(:,:,iView), tanLines(:,:,iView)] = findTangentToBlob(pawMask{iView}, epipole);
    
    % for development; can comment out later
    for i_pt = 1 : 2
        borderpts(i_pt,:,iView) = lineToBorderPoints(tanLines(i_pt,:,iView),imSize);
    end
    
end

if showSilhouettes
    figure(2);
    imshow(pawMask{1} | pawMask{2});
    hold on
    for iView = 1 : 2
        plot(squeeze(tanPts(:,1,iView)),squeeze(tanPts(:,2,iView)),'marker','o','linestyle','none')
        for i_pt = 1 : 2
            line([borderpts(i_pt,1,iView),borderpts(i_pt,3,iView)],[borderpts(i_pt,2,iView),borderpts(i_pt,4,iView)])
        end
    end
end
    
    
    
% find the points tangent to the direct and mirror view blobs that pass
% through the epipole


% match points in both regions
bboxes = [1,1,imSize(2)-1,imSize(1)-1];
bboxes = [bboxes;bboxes];
points3d = silhouetteTo3D(pawMask, boxCalibration, bboxes, tanPts, imSize);

plot3(points3d(:,1),points3d(:,2),points3d(:,3),'marker','.','linestyle','none')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%