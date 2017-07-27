function [ points3d ] = frame2d_to_3d_boundary( points2d, boxCalibration, pawPref, imSize, epipole, currentFrame_ud, varargin )
%points2d_to_3d Summary of this function goes here
%   Detailed explanation goes here

showSilhouettes = false;
show3dpoints = false;
refine_estimates = true;
% s = 0.6;    % shrink factor for boundaries - not using since switched to
% convex hull

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'refineestimates'
            refine_estimates = varargin{iarg + 1};
        case 'showsilhouettes'
            showSilhouettes = varargin{iarg + 1};
        case 'show3dpoints'
            show3dpoints = varargin{iarg + 1};
    end
end

% P1 = eye(4,3);
% sf = mean(boxCalibration.srCal.sf,1);
% switch lower(pawPref)
%     case 'right'
%         P2 = squeeze(boxCalibration.srCal.P(:,:,1));
%         sf = sf(1);
%     case 'left'
%         P2 = squeeze(boxCalibration.srCal.P(:,:,2));
%         sf = sf(2);
%                             % need to figure out how I organized the scale factor matrix and comment that into the estimate scale function
%                                                                    % looks like the columns are the view: 1 = left, 2 = right. The rows are the independent estimates for pairs of rubiks spacings. So, should take the mean across rows to estimate the scale factor in each mirror view                   
% end

% calculate the convex hulls of the direct and mirror views
% index 1 is the direct view, 2 is the mirror view
tanPts = zeros(2,2,2);   % x,y,view
tanLines = zeros(2,3,2);   % x,y,view
borderpts = zeros(2,4,2);
% boundaryPts = cell(1,2);
pawMask = cell(1,2);
ext_pts = cell(1,2);
% isBlobComplete = true(2,2);
for iView = 1 : 2
%     pawOutline = false(imSize);
%     for ii = 1 : size(points2d{iView},1)
%         pawOutline(points2d{iView}(ii,2),points2d{iView}(ii,1)) = true;
%     end
%     pawMask{iView} = bwconvhull(pawOutline,'union');

%     otherView = 3 - iView;
%     boundaryIdx = boundary(points2d{iView},s);
%     boundaryPts{iView} = points2d{iView}(boundaryIdx,:);
    
%     pawMask{iView} = poly2mask(boundaryPts{iView}(:,1),boundaryPts{iView}(:,2),imSize(1),imSize(2));

    cvx_hull_idx = convhull(points2d{iView});
    pawMask{iView} = poly2mask(points2d{iView}(cvx_hull_idx,1),points2d{iView}(cvx_hull_idx,2),imSize(1),imSize(2));
    mask_ext = bwmorph(pawMask{iView},'remove');
    
    [y,x] = find(mask_ext);
    s = regionprops(mask_ext,'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
    
    try
        [tanPts(:,:,iView), tanLines(:,:,iView)] = findTangentToBlob(pawMask{iView}, epipole);
    catch
        keyboard
    end
    
    % do these tangent lines intersect the other blob?
%     for i_tanPt = 1 : 2
%         lineValue = tanLines(i_tanPt,1,iView) * points2d{otherView}(:,1) + ...
%                     tanLines(i_tanPt,2,iView) * points2d{otherView}(:,2) + ...
%                     tanLines(i_tanPt,3,iView);
%         if all(lineValue > 0) || all(lineValue < 0)    % the line does not intersect the blob in the other view
%             isBlobComplete(i_tanPt,otherView
%     end
    % for development; can comment out later
    for i_pt = 1 : 2
        borderpts(i_pt,:,iView) = lineToBorderPoints(tanLines(i_pt,:,iView),imSize);
    end
    
end
ext_pts{2} = flipud(ext_pts{2});   % now these points are sorted in the clockwise direction

if showSilhouettes
    figure(1);

    imshow(pawMask{1} | pawMask{2});

    hold on
    for iFig = 1 : 2
        figure(1)
        for iView = 1 : 2
%             plot(boundaryPts{iView}(:,1),boundaryPts{iView}(:,2),'marker','.','linestyle','none')
            plot(squeeze(tanPts(:,1,iView)),squeeze(tanPts(:,2,iView)),'marker','o','linestyle','none')
            for i_pt = 1 : 2
                line([borderpts(i_pt,1,iView),borderpts(i_pt,3,iView)],[borderpts(i_pt,2,iView),borderpts(i_pt,4,iView)])
            end
        end
    end
end
    
    
    
% find the points tangent to the direct and mirror view blobs that pass
% through the epipole


% match points in both regions
bboxes = [1,1,imSize(2)-1,imSize(1)-1];
bboxes = [bboxes;bboxes];
% points3d = silhouetteTo3D(pawMask, boxCalibration, bboxes, tanPts, imSize);
[points3d,matchedPoints] = bordersTo3D_bothDirs(ext_pts, boxCalibration, bboxes, tanPts, imSize, currentFrame_ud);

if show3dpoints
    figure(2)
    hold off
    plot3(points3d{1}(:,1),points3d{1}(:,2),points3d{1}(:,3),'marker','.','linestyle','none','color','b')
    hold on
    plot3(points3d{2}(:,1),points3d{2}(:,2),points3d{2}(:,3),'marker','.','linestyle','none','color','r')
%     set(gca,'ydir','reverse');
    set(gca,'zdir','reverse');
    set(gca,'xdir','reverse');
    xlabel('x');ylabel('y');zlabel('z')
    camup([0 1 0])
end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%