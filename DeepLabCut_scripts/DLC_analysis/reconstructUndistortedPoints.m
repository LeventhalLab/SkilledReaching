function points_ud = reconstructUndistortedPoints(pts,ROI,cameraParams,valid_pts)
%
% INPUTS:
%   pts - m x n x 2 array where each row m is the number of body parts and
%       n is the number of frames. Each (x,y) pair is a distorted
%       point detected within a ROI in deeplabcut
%   ROI - region of interest for deeplabcut video. 4-element vector of
%       [left,top,width,height] in pixels
%   cameraParams - matlab camera parameters object
%
% OUTPUTS
%   points_ud - undistorted points with coordinates such that (0,0) is the
%      top left corner of the original video frame


points_ud = NaN(size(pts));
translated_pts = NaN(size(pts));
for i_coord = 1 : 2
    translated_pts(:,:,i_coord) = pts(:,:,i_coord) + ROI(i_coord) - 1;
end

for i_part = 1 : size(points_ud,1)

    validFrames = valid_pts(i_part,:);
    if any(validFrames)
        points_ud(i_part,valid_pts(i_part,:),:) = undistortPoints(squeeze(translated_pts(i_part,validFrames,:)),cameraParams);
    end

end

end