function [direct_reproj,mirror_reproj] = reproj_single_trajectory(trajectory_wrt_pellet,initPellet3D,boxCal,pawPref)

% subtract out initial pellet location to move back to camera-centered
% coordinates

K = boxCal.cameraParams.IntrinsicMatrix;

numFrames = size(trajectory_wrt_pellet,1);
trajectory_wrt_camera = bsxfun(@minus,trajectory_wrt_pellet,initPellet3D);

direct_reproj = NaN(numFrames,3);
mirror_reproj = NaN(numFrames,3);

switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        sf = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        sf = mean(boxCal.scaleFactor(3,:));
end

for i_frame = 1 : numFrames
    currentPt3D = trajectory_wrt_camera(i_frame,:);
    if all(currentPt3D==0) || isnan(currentPt3D(1))
        % 3D point wasn't computed for this body part
        continue;
    end

    [direct_reproj(i_frame,:),mirror_reproj(i_frame,:)] = ...
        reproj_single_point(currentPt3D,boxCal.P,Pn,K,sf); 
end