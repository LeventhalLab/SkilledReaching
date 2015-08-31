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
figure
imshow(BGimg_ud)
hold on
%%
% calculate epipolar lines based on F
tpts = mp(:,:,2);
lines = epipolarLine(F.left, tpts);

epipts = lineToBorderPoints(lines,size(BGimg_ud));
[~,epipole] = isEpipoleInImage(F.left,size(BGimg_ud));

%%
for ii = 1 : 2 : size(epipts,1)
    line([epipts(ii,1),epipts(ii,3)],[epipts(ii,2),epipts(ii,4)]);
end
%%
E = K * F.left * K';
[rot,t] = EssentialMatrixToCameraMatrix(E);
% [cRot,cT,correct] = SelectCorrectEssentialCameraMatrix(rot,t,squeeze(mp(:,:,2))',squeeze(mp(:,:,1))',K');
cRot = rot(:,:,4);cT = t(:,:,4);
P1 = eye(4,3);
P2 = [cRot,cT];
P2 = P2';
%%
% convert to normalized coordinates
dpts_hom = [mp(:,:,2), ones(size(mp,1),1)];
dpts_norm = K' \ dpts_hom';
dpts_norm = dpts_norm';

mpts_hom = [mp(:,:,1), ones(size(mp,1),1)];
mpts_norm = K' \ mpts_hom';
mpts_norm = mpts_norm';


%%
wpts = triangulate(dpts_norm(:,1:2),mpts_norm(:,1:2),P1,P2)
wpts2_hom = LinearTriangulation(dpts_norm(:,1:2)',mpts_norm(:,1:2)',cRot,cT);
wpts2_hom = wpts2_hom';
wpts2 = bsxfun(@rdivide,wpts_hom(:,1:3),wpts_hom(:,4))
wpts_hom = [wpts,ones(size(wpts_hom,1),1)];

%%
figure
plot3(wpts(:,1),wpts(:,2),wpts(:,3),'marker','*','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('y');zlabel('z')
hold on
plot3(wpts(1,1),wpts(1,2),wpts(1,3),'marker','o','linestyle','none','color','r');
plot3(wpts(2,1),wpts(2,2),wpts(2,3),'marker','o','linestyle','none','color','k');
plot3(wpts(7,1),wpts(7,2),wpts(7,3),'marker','o','linestyle','none','color','g');

%%
figure
plot(wpts(:,1),wpts(:,3),'marker','*','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('z');
hold on
plot(wpts(1,1),wpts(1,3),'marker','o','linestyle','none','color','r');
plot(wpts(2,1),wpts(2,3),'marker','o','linestyle','none','color','k');
plot(wpts(7,1),wpts(7,3),'marker','o','linestyle','none','color','g');

%%
mirror_reproj = wpts_hom * P2;
direct_reproj = wpts_hom * P1;
figure
a = [mirror_reproj(:,1)./mirror_reproj(:,3),mirror_reproj(:,2)./mirror_reproj(:,3)];
b = [direct_reproj(:,1)./direct_reproj(:,3),direct_reproj(:,2)./direct_reproj(:,3)];
plot(a(:,1),a(:,2),'marker','*','linestyle','none')
hold on
set(gca,'ydir','reverse')
plot(b(:,1),b(:,2),'marker','*','linestyle','none')
plot(dpts_norm(:,1),dpts_norm(:,2),'marker','o','linestyle','none')
plot(mpts_norm(:,1),mpts_norm(:,2),'marker','o','linestyle','none')
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


%%

for ii = 1 : 4
    figure
    set(gcf,'name',sprintf('view %d',ii))
    plot3(x3D(1,:,ii),x3D(2,:,ii),x3D(3,:,ii),'marker','*','linestyle','none','color','b')
    hold on
    plot3(x3D(1,1,ii),x3D(2,1,ii),x3D(3,1,ii),'marker','o','linestyle','none','color','b')
    
    plot3(cam_pt1(1,:,ii),cam_pt1(2,:,ii),cam_pt1(3,:,ii),'markersize',6,'marker','o')
    plot3(cam_pt1(1,1,ii),cam_pt1(2,1,ii),cam_pt1(3,1,ii),'markersize',6,'marker','+','color','k')
    plot3(cam_pt2(1,:,ii),cam_pt2(2,:,ii),cam_pt2(3,:,ii),'markersize',6,'marker','o')
    plot3(cam_pt2(1,1,ii),cam_pt2(2,1,ii),cam_pt2(3,1,ii),'markersize',6,'marker','+','color','k')
    xlabel('x');ylabel('y');zlabel('z')
end

%%
cam_pt1 = zeros(3,2,4);
cam_pt2 = zeros(3,2,4);
camAxis = ([0 1 0 0 0 0;
            0 0 0 1 0 0;
            0 0 0 0 0 1]);
camPt = [0 0
         0 0
         0 1];
for ii = 1 : 4
    cam_pt1(:,:,ii) = eye(3)'*bsxfun(@minus,camPt,zeros(3,1));
    cam_pt2(:,:,ii) = rot(:,:,ii)'*bsxfun(@minus,camPt,t(:,:,ii));
end

%%