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

%%
K = createIntrinsicMatrix();
K = K';
worldPoints = generateCheckerboardPoints([5,5],8);worldPoints = fliplr(worldPoints);
wpts_hom = [worldPoints, ones(16,1)];
mp = matchBoxMarkers(boxMarkers);
impts = squeeze(mp(7:end,:,2));
cparams = cameraParameters('intrinsicmatrix',K);
[R,t] = extrinsics(impts,worldPoints, cparams);
[R2,t2] = extrinsics(impts(16:-1:1,:),worldPoints(16:-1:1,:), cparams);
%%
cb_pts_cam_coord = wpts_hom * R;
for ii = 1 : size(cb_pts_cam_coord,1);
    cb_pts_cam_coord(ii,:) = cb_pts_cam_coord(ii,:) + t;
end
cb_pts_cam_coord_hom = [cb_pts_cam_coord,ones(16,1)];
%%
P = [R;t]*K;
P2 = [R2;t]*K;
wpts3D = [worldPoints,zeros(16,1),ones(16,1)];
projected_pts_hom = wpts3D * P;
projected_pts_hom2 = wpts3D * P2;
projected_pts = [projected_pts_hom(:,1)./projected_pts_hom(:,3),projected_pts_hom(:,2)./projected_pts_hom(:,3)];
projected_pts2 = [projected_pts_hom2(:,1)./projected_pts_hom2(:,3),projected_pts_hom2(:,2)./projected_pts_hom2(:,3)];