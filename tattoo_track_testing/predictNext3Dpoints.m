function nextPoints = predictNext3Dpoints(recentDigitHistory, ...
                                          recentPawHistory, ...
                                          current_paw_mask, ...
                                          mask_bbox, ...
                                          trackingBoxParams)
%
% INPUTS:
%   recentDigitHistory - m x n x p x q array, where m is the number of
%       frames to look back, n is 5 (hand + 4 digits), p is site on the
%       digit (proximal, centroid, distal), q contains (x,y,z)
%   recentPawHistory - 
%
% OUTPUTS:
%   nextPoints - 
%

numFrames = size(recentDigitHistory,1);

% calculate the trajectory of the paw's center of mass

% find the centroid of the paw in each view
directMask = connectBlobs(current_paw_mask{1});
mirrorMask = connectBlobs(current_paw_mask{2});

s_direct = regionprops(directMask,'centroid');
s_mirror = regionprops(mirrorMask,'centroid');

directCentroid = s_direct.Centroid + mask_bbox(1,1:2);
mirrorCentroid = s_mirror.Centroid + mask_bbox(2,1:2);

norm_centroids = normalize_points([directCentroid;mirrorCentroid], trackingBoxParams.K);
centroids3D = triangulate_DL(norm_centroids(1,:), ...
                             norm_centroids(2,:), ...
                             trackingBoxParams.P1, ...
                             trackingBoxParams.P2);
centroids3D = centroids3D * trackingBoxParams.scale;

% find previous digit locations w.r.t. paw mask centroid triangulated back
relative_digit_positions = zeros(size(recentDigitHistory));
for ii = 1 : numFrames
    for jj = 1 : size(recentDigitHistory,2)
        tempPos = squeeze(recentDigitHistory(ii,jj,:,:));
        relative_digit_positions(ii,jj,:,:) = bsxfun(@minus,tempPos,recentPawHistory(ii,:));
    end
end

% average the relative digit positions across frames
mean_rel_dig_pos = squeeze(mean(relative_digit_positions,1));
nextPoints = zeros(size(mean_rel_dig_pos));
for jj = 1 : size(recentDigitHistory,2)
    nextPoints(jj,:,:) = bsxfun(@plus,...
                                squeeze(mean_rel_dig_pos(jj,:,:)), ...
                                centroids3D);
end

    
    