%%
% K = createIntrinsicMatrix();
% K = K';

%%

num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = true;

% [cp_intrinsic, imUsed, estimationErrors] = cb_calibration('numradialdistortioncoefficients',num_rad_coeff, ...
%                                                           'estimatetangentialdistortion',est_tan_distortion, ...
%                                                           'estimateskew',estimateSkew);

% K = cp_intrinsic.IntrinsicMatrix;
K = createIntrinsicMatrix();
K = K';
% cp_intrinsic = cameraParameters('intrinsicmatrix',K, ...
%                                 'radialdistortion',rd);

worldPoints_small = generateCheckerboardPoints([5,5],8);worldPoints_small = fliplr(worldPoints_small);
wpts_planar_hom = [worldPoints_small, zeros(16,1)];
wpts_hom = [worldPoints_small, zeros(16,1), ones(16,1)];
mp = matchBoxMarkers(boxMarkers_ud);
numImages = size(mp,3);


impts = zeros(16,2,numImages);
R = zeros(3,3,numImages);R_dl = zeros(3,3,numImages);R_norm = zeros(3,3,numImages);
rvecs = zeros(numImages, 3);
t = zeros(numImages,3);t_dl = zeros(numImages,3);t_norm = zeros(numImages,3);
H = zeros(3,3,numImages);
P = zeros(4,3,numImages);
for ii = 1 : numImages
    impts(:,:,ii) = squeeze(mp(7:end,:,ii));
    
%     hmgrphy = fitgeotrans(worldPoints, squeeze(impts(:,:,ii)), 'projective');
%     hmgrphy = (hmgrphy.T)';
%     hmgrphy = hmgrphy / hmgrphy(3,3);
%     H(:,:,ii) = hmgrphy;
    
%     [R_ml(:,:,ii),t_ml(ii,:)] = extrinsics(squeeze(impts(:,:,ii)),worldPoints_small,cp_intrinsic);
    im_hom = [impts(:,:,ii),ones(16,1)];
    normcoord = im_hom * inv(K);
    
    [R(:,:,ii),t(ii,:)] = extrinsicsPlanar_DL(squeeze(impts(:,:,ii)),worldPoints_small,K);
%     [R_norm(:,:,ii),t_norm(ii,:)] = extrinsicsPlanar_DL(normcoord(:,1:2),worldPoints_small,K);
%     [R,t] = extrinsicsPlanar_normCoord(normcoord(:,1:2), worldPoints_small);
    
    rvecs(ii,:) = vision.internal.calibration.rodriguesMatrixToVector(squeeze(R_dl(:,:,ii)));
    
    P(:,:,ii) = [squeeze(R(:,:,ii));t(ii,:)] * K;
end

%%
% given the camera matrix for the front view of each checkerboard, find the
% camera matrix for the side view

% First, assume P1 = eye(4,3);
H = fitgeotrans(impts(:,:,2),impts(:,:,1),'projective');
P1 = P(:,:,2);
P2 = P1*H.T;
%%
cb_pts_cam_coord_hom = zeros(16,4,4);
for ii = 1 : 4
    cb_pts_cam_coord_hom(:,1:3,ii) = wpts_hom(:,1:3) * R(:,:,ii);

    for jj = 1 : size(cb_pts_cam_coord_hom,1);
        cb_pts_cam_coord_hom(jj,1:3,ii) = squeeze(cb_pts_cam_coord_hom(jj,1:3,ii)) + t(ii,:);
    end
    cb_pts_cam_coord_hom(:,4,ii) = ones(16,1);
end
%%
figure
for ii = 1 : 4
    plot3(cb_pts_cam_coord_hom(:,1,ii),cb_pts_cam_coord_hom(:,3,ii),cb_pts_cam_coord_hom(:,2,ii),'marker','*','linestyle','none')
    hold on
end
%%
rproj_hom = zeros(16,3,numImages);
rproj = zeros(16,2,numImages);
for ii = 1 : 4
    P(:,:,ii) = [squeeze(R(:,:,ii));t(ii,:)] * K;
    rproj_hom(:,:,ii) = wpts_hom * P(:,:,ii);
    rproj(:,:,ii) = [rproj_hom(:,1,ii)./rproj_hom(:,3,ii),rproj_hom(:,2,ii)./rproj_hom(:,3,ii)];
end
    
%%
figure
imshow(BGimg_ud)
hold on
for ii = 1 : 4
    plot(impts(:,1,ii),impts(:,2,ii),'marker','*','linestyle','none')
    plot(rproj(:,1,ii),rproj(:,2,ii),'marker','o','linestyle','none')
end

if est_tan_distortion
    tanString = 'corrected for tangential distortion';
else
    tanString = 'uncorrected for tangential distortion';
end
if estimateSkew
    skewString = 'corrected for skew';
else
    skewString = 'uncorrected for skew';
end
titleString = sprintf('%d radial distortion coefficients, %s, %s', ...
                      num_rad_coeff, ...
                      tanString, ...
                      skewString);
set(gcf,'name',titleString);

% NOW, CAN GO BACK AND USE THE FUNDAMENTAL MATRIX TO ESTIMATE THE POSE OF
% THE SECOND CAMERA W.R.T. THE CHECKERBOARDS...
% GETTING RID OF THE SINGULAR VALUE DECOMPOSITION IN THE ROTATION MATRIX
% ESTIMATION MADE A HUGE DIFFERENCE IN THE RECONSTRUCTION ACCURACY

%%
% 
% cparams_new = cameraParameters('IntrinsicMatrix',K, ...
%                                 'RotationVectors', rvecs, ...
%                                 'TranslationVectors', t, ...
%                                 'WorldPoints', worldPoints, ...
%                                 'radialdistortion',cameraParams.RadialDistortion, ...
%                                 'WorldUnits', 'mm');
%                             
% figure
% showExtrinsics(cparams_new)
% 
% %%
% cparams = cparams_init;
% errors = refine(cparams,impts,true);
%                                 
% % [R,t] = extrinsics(impts,worldPoints, cparams);
% % [R2,t2] = extrinsics(impts(16:-1:1,:),worldPoints(16:-1:1,:), cparams);