%%
% generate camera matrices from fundamental matrix, which we know is pretty
% accurate. Then need to compute homographic transformation that maps
% triangulated points onto real world points, and apply it to all imaged
% points

[P1,P2] = cameraMatricesFromFundMatrix(boxMarkers, rat_metadata);

wpts = triangulate(squeeze(mp(:,:,1)),squeeze(mp(:,:,2)),P1,P2);
wpts = [wpts,ones(size(wpts,1),1)];

plot3(wpts(:,1),wpts(:,2),wpts(:,3),'marker','*','linestyle','none')

temp = wpts*P1;
reprojection1 = [temp(:,1)./temp(:,3),temp(:,2)./temp(:,3)];
temp = wpts*P2;
reprojection2 = [temp(:,1)./temp(:,3),temp(:,2)./temp(:,3)];


[cparams,imUsed,estErrors] = estimateCameraParameters(imPoints, worldPoints)


% can get world points in the camera coordinate system from the first
% camera matrix, then just need a transform to go from 3D points to "real"
% checkerboard points, and we should be able to get "real" digit
% coordinates

% world points (camera origin) = (worldpoints(checkerboard origin) * R)) + t