function matched_points = matchMirrorMaskPoints(fullMask, fundMat)
%
% INPUTS:
%
% OUTPUTS:
%   matched_points - m x 2 x 2 array where matched_points(:,:,1) contains
%       (x,y) pairs of points around the circumference of fullMask{1}
%       (direct view) and matched_points(:,:,2) contains the corresponding
%       (x,y) pairs around the circumference of the mirror mask

h = size(fullMask{1},1); w = size(fullMask{1},2);

bbox = [1 1 w-1 h-1];

tangentPoints = zeros(2,2,2);    % mxnxp where m is number of points, n is (x,y), p is the view index (1 for direct, 2 for mirror)
tangentLines = zeros(2,3,2);     % mxnxp where m is number of points, n is (A,B,C), p is the view index (1 for direct, 2 for mirror)

ext_pts = cell(1,2);
fullHull = bwconvhull((fullMask{1} | fullMask{2}),'union');
fullHull_ext = bwmorph(fullHull,'remove');
for iView = 1 : 2
    if iView == 2
        F = fundMat';
    else
        F = fundMat;
    end
    curMask = bwconvhull(fullMask{iView});
%     [tangentPoints(:,:,iView), ~] = ...
%         findTangentToEpipolarLine(fullMask{iView}, F, bbox);
    [tangentPoints(:,:,iView), ~] = ...
        findTangentToEpipolarLine(curMask, F, bbox);
    % rearrange tangent points so that top one comes first in both views
    [~,idx] = sort(tangentPoints(:,2,iView));
    tangentPoints(:,:,iView) = tangentPoints(idx,:,iView);
%     tangentLines(:,:,iView) = tangentLines(idx,:,iView);
%     bpts(:,:,iView) = lineToBorderPoints(tangentLines(:,:,iView),imSize);
    startTracePt = [tangentPoints(1,2,iView),tangentPoints(1,1,iView)];
    ext_pts{iView} = bwtraceboundary(curMask,startTracePt,'E');
%     ext_pts{iView} = bwtraceboundary(fullMask{iView},startTracePt,'E');
    ext_pts{iView} = circshift(ext_pts{iView}(1:end-1,:),1,2);
    
end

num_pts = size(ext_pts{1},1);
matched_points = zeros(num_pts,2,2);
matched_points(:,:,1) = ext_pts{1};
epiLines = epipolarLine(fundMat, ext_pts{1});
for ii = 1 : num_pts
    % find points on the same line as the current point in the direct view
    idx_zero = cell(1,2);

    lineVal = epiLines(ii,1) * ext_pts{2}(:,1) + epiLines(ii,2) * ext_pts{2}(:,2) + epiLines(ii,3);
    temp = detectCircularZeroCrossings(lineVal);
    idx_zero{2} = find(temp);

    if isempty(idx_zero{2})
        lineVal = epiLines(ii,1) * ext_pts{2}(:,1) + epiLines(ii,2) * ext_pts{2}(:,2) + epiLines(ii,3);
        idx_zero{2} = find(abs(lineVal) == min(abs(lineVal)));
    end
    if length(idx_zero{2}) == 1
        ptIdx = idx_zero{2};
    else
        ptSep = bsxfun(@minus,ext_pts{2}(idx_zero{2},:),ext_pts{1}(ii,:));
        ptSep = sum(ptSep.^2,2);
        if fullHull_ext(ext_pts{1}(ii,2),ext_pts{1}(ii,1))   % the current point in
                                                         % the direct view is
                                                         % on the convex hull of
                                                         % the union of the masks in the two views
                                                         % this means it is
                                                         % on the far side
                                                         % from the mirror
            ptIdx = idx_zero{2}(find(ptSep == max(ptSep),1));
        else
            ptIdx = idx_zero{2}(find(ptSep == min(ptSep),1));
        end
    end
    matched_points(ii,:,2) = ext_pts{2}(ptIdx,:);

end
        
    