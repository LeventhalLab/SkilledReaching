%%
K = createIntrinsicMatrix();
K = K';

%%
% K = cameraParams.IntrinsicMatrix;
rd = cameraParams.RadialDistortion;

K = createIntrinsicMatrix();
K = K';
cp_intrinsic = cameraParameters('intrinsicmatrix',K, ...
                                'radialdistortion',rd);

worldPoints_small = generateCheckerboardPoints([5,5],8);worldPoints_small = fliplr(worldPoints_small);
wpts_hom = [worldPoints_small, zeros(16,1), ones(16,1)];
mp = matchBoxMarkers(boxMarkers_ud);
numImages = size(mp,3);

impts = zeros(16,2,numImages);
R = zeros(3,3,numImages);
rvecs = zeros(numImages, 3);
t = zeros(numImages,3);
H = zeros(3,3,numImages);
P = zeros(4,3,numImages);
for ii = 1 : 4
    impts(:,:,ii) = squeeze(mp(7:end,:,ii));
    
%     hmgrphy = fitgeotrans(worldPoints, squeeze(impts(:,:,ii)), 'projective');
%     hmgrphy = (hmgrphy.T)';
%     hmgrphy = hmgrphy / hmgrphy(3,3);
%     H(:,:,ii) = hmgrphy;
    
    [R(:,:,ii),t(ii,:)] = extrinsics(squeeze(impts(:,:,ii)),worldPoints_small,cp_intrinsic);
    rvecs(ii,:) = vision.internal.calibration.rodriguesMatrixToVector(squeeze(R(:,:,ii)));
    
    P(:,:,ii) = [squeeze(R(:,:,ii));t(ii,:)] * K;
end

%%
%%
cb_pts_cam_coord = wpts_hom(:,1:3) * R(:,:,2);
for ii = 1 : size(cb_pts_cam_coord,1);
    cb_pts_cam_coord(ii,:) = cb_pts_cam_coord(ii,:) + t(2,:);
end
cb_pts_cam_coord_hom = [cb_pts_cam_coord,ones(16,1)];

%%
rproj_hom = zeros(16,3,numImages);
rproj = zeros(16,2,numImages);
for ii = 1 : 4
    rproj_hom(:,:,ii) = wpts_hom * P(:,:,ii);
    rproj(:,:,ii) = [rproj_hom(:,1,ii)./rproj_hom(:,3,ii),rproj_hom(:,2,ii)./rproj_hom(:,3,ii)];
end
    
%%
figure
imshow(BGimg)
hold on
for ii = 1 : 4
    plot(impts(:,1,ii),impts(:,2,ii),'marker','*','linestyle','none')
    plot(rproj(:,1,ii),rproj(:,2,ii),'marker','o','linestyle','none')
end
    
%%
% 
cparams_init = cameraParameters('IntrinsicMatrix',K, ...
                                'RotationVectors', rvecs, ...
                                'TranslationVectors', t, ...
                                'WorldPoints', worldPoints, ...
                                'radialdistortion',cameraParams.RadialDistortion, ...
                                'WorldUnits', 'mm');

%%
cparams = cparams_init;
errors = refine(cparams,impts,true);
                                
% [R,t] = extrinsics(impts,worldPoints, cparams);
% [R2,t2] = extrinsics(impts(16:-1:1,:),worldPoints(16:-1:1,:), cparams);