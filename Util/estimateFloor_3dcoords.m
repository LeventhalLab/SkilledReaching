function [ floor_coords ] = estimateFloor_3dcoords( session_mp, boxCalibration )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

K = boxCalibration.cameraParams.IntrinsicMatrix;
floor_coords = zeros(2,3);
% first calculate based on the left mirror
mp_left = zeros(1,2,2);
mp_left(1,:,1) = session_mp.direct.left_top_floor_corner;   % left top floor corner in the direct view
mp_left(1,:,2) = session_mp.leftMirror.left_top_floor_corner;   % left top floor corner in the left mirror view

mp_left_norm = zeros(size(mp_left));
for iView = 1 : 2
    mp_left_norm(:,:,iView) = normalize_points(squeeze(mp_left(:,:,iView)), K);
end


mp_right = zeros(1,2,2);
mp_right(1,:,1) = session_mp.direct.right_top_floor_corner;   % right top floor corner in the direct view
mp_right(1,:,2) = session_mp.rightMirror.right_top_floor_corner;   % right top floor corner in the right mirror view

mp_right_norm = zeros(size(mp_right));
for iView = 1 : 2
    mp_right_norm(:,:,iView) = normalize_points(squeeze(mp_right(:,:,iView)), K);
end


[floor_coords(1,:),~,~] = triangulate_DL(mp_left_norm(:,:,1),mp_left_norm(:,:,2),eye(4,3),boxCalibration.srCal.P(:,:,1));
[floor_coords(2,:),~,~] = triangulate_DL(mp_right_norm(:,:,1),mp_right_norm(:,:,2),eye(4,3),boxCalibration.srCal.P(:,:,2));

end

