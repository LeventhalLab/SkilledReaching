function points3d = compute3Dtrajectory(video, points2d, track_metadata, pawPref, 

boxCalibration = track_metadata.boxCalibration;
numFrames = size(points2d, 2);

points3d = cell(numFrames,1);

video.CurrentTime = track_metadata.triggerTime;



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function frame_points3D = computeNext3Dpoints( points2d, points3d, currentFrame, img_ud )

frame_points2d = cell(1,2);
frame_points2d{1} =  points2d{1,currentFrame};
frame_points2d{2} =  points2d{2,currentFrame};

% use knowledge of where the 3D points were from the previous frame, where
% the paw was identified in the current frame/view (if at all), the current
% frame image, and where the paw was identified in adjacent frames to
% estimate where it is now