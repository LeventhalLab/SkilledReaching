% script to track the tattooed paw, updated version as of 08/27/2015

sampleVid  = fullfile('/Volumes/RecordingsLeventhal3/SkilledReaching/R0044/R0044-rawdata/R0044_20150416a', 'R0044_20150416_12-11-45_034.avi');
sr_summary = sr_ratList();

test_ratID = 44;
rat_metadata = create_sr_ratMetadata(sr_summary, test_ratID);
numBGframes = 50;    % number of frames from the beginning of the video to
                     % use to generate the background image

%%
% establish fidelity point detection parameters
minBeadArea = 0300;
maxBeadArea = 2000;
pointsPerRow = 4;    % for the checkerboard detection and mirror images

hsvBounds_beads = [0.00    0.16    0.50    1.00    0.00    1.00
                   0.33    0.16    0.00    0.50    0.00    0.50
                   0.66    0.16    0.50    1.00    0.00    1.00];
maxBeadEcc = 0.8;
%%
% first, calibrate based on the full set of checkerboard images
cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;

% comment out the line below once camera is calibrated
[cameraParams, imUsed, estimationErrors] = cb_calibration('cb_path', cb_path, ...
                                                          'num_rad_coeff', num_rad_coeff, ...
                                                          'est_tan_distortion', est_tan_distortion, ...
                                                          'estimateskew', estimateSkew);
K = cameraParams.IntrinsicMatrix;

% alternatively, can use K from camera data sheet:
% K = createIntrinsicMatrix('f', 8, 'pixsize',5.5e-3,'princ_point',[1020,512]);
% K = K';  % because matlab does calculations in opposite order from
%          %Hartley and Zisserman
%%
% create a video reader object and extract video parameters
video = VideoReader(sampleVid);
h = video.Height;
w = video.Width;

%%
% extract the background image. This takes a little time, so can comment
% this out once BG image initially established
BGimg = extractBGimg( video, 'numbgframes', numBGframes);
BGimg_ud = undistortImage(BGimg, cameraParams);   % accounts for lens distortion

%%
% find the box fidelity markers and assemble matching points matrix
[boxMarkers_ud.beadLocations, boxMarkers_ud.beadMasks] = identifyBeads(BGimg_ud, ...
                                         'minbeadarea',minBeadArea, ...
                                         'maxbeadarea',maxBeadArea, ...
                                         'hsvbounds',hsvBounds_beads, ...
                                         'maxeccentricity',maxBeadEcc);
                                     
% divide up the image so checkerboards can be detected in each
% mirror/direct view without interference from other checkerboards
register_ROI(1,1) = 1; register_ROI(1,2) = 1;   % top left corner of left mirror region of interest
register_ROI(1,3) = round(min(boxMarkers_ud.beadLocations.center_red_beads(:,1))) - 5;  % right edge, move just to the left to make sure red bead centroids can be included in the center image
register_ROI(1,4) = size(BGimg_ud,1) - register_ROI(1,2);  % bottom edge

register_ROI(2,1) = register_ROI(1,3) + 2; register_ROI(2,2) = 1;   % top left corner of left mirror region of interest
register_ROI(2,4) = size(BGimg_ud,1) - register_ROI(2,2);  % bottom edge

register_ROI(3,1) = round(max(boxMarkers_ud.beadLocations.center_green_beads(:,1))) + 5;   % left edge
register_ROI(3,2) = 1;   % top edge of right mirror region of interest
register_ROI(3,3) = size(BGimg_ud,2) - register_ROI(3,1);  % right edge, extend to edge of the image
register_ROI(3,4) = size(BGimg_ud,1) - register_ROI(1,2);  % bottom edge
register_ROI(2,3) = register_ROI(3,1) - register_ROI(2,1) - 2;  % right edge, move just to the left to make sure green bead centroids can be included in the center image

boxMarkers_ud.register_ROI = register_ROI;

% extract the regions of interest from the parent image
BG_lft = uint8(BGimg_ud(register_ROI(1,2):register_ROI(1,2) + register_ROI(1,4), ...
                     register_ROI(1,1):register_ROI(1,1) + register_ROI(1,3), :));
BG_ctr = uint8(BGimg_ud(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                     register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :));
BG_rgt = uint8(BGimg_ud(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
                     register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :));
BG_leftctr  = uint8(BGimg_ud(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    register_ROI(2,1):round(frame_w/2), :));
BG_rightctr = uint8(BGimg_ud(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    round(frame_w/2):register_ROI(2,1) + register_ROI(2,3), :));
                
%%
% find the checkerboard points - comment these lines out to make it run
% faster, put them back in if checkerboard points need to be recalculated****************
% 
[cbLocations.left_mirror_cb, cbLocations.num_left_mirror_cb_rows] = detect_SR_checkerboard(BG_lft);
cbLocations.left_mirror_cb(:,1) = cbLocations.left_mirror_cb(:,1) + register_ROI(1,1) - 1;
cbLocations.left_mirror_cb(:,2) = cbLocations.left_mirror_cb(:,2) + register_ROI(1,2) - 1;
[cbLocations.right_mirror_cb, cbLocations.num_right_mirror_cb_rows] = detect_SR_checkerboard(BG_rgt);
cbLocations.right_mirror_cb(:,1) = cbLocations.right_mirror_cb(:,1) + register_ROI(3,1) - 1;
cbLocations.right_mirror_cb(:,2) = cbLocations.right_mirror_cb(:,2) + register_ROI(3,2) - 1;
[cbLocations.left_center_cb, cbLocations.num_left_center_cb_rows]  = detect_SR_checkerboard(BG_leftctr);
cbLocations.left_center_cb(:,1) = cbLocations.left_center_cb(:,1) + register_ROI(2,1) - 1;
cbLocations.left_center_cb(:,2) = cbLocations.left_center_cb(:,2) + register_ROI(2,2) - 1;
[cbLocations.right_center_cb, cbLocations.num_right_center_cb_rows] = detect_SR_checkerboard(BG_rightctr);
cbLocations.right_center_cb(:,1) = cbLocations.right_center_cb(:,1) + round(frame_w/2) - 1;
cbLocations.right_center_cb(:,2) = cbLocations.right_center_cb(:,2) + register_ROI(2,2) - 1;

boxMarkers_ud.cbLocations = cbLocations;
boxMarkers_ud = identifyBoxFront(BGimg_ud, register_ROI, boxMarkers_ud);
%%
mp = matchBoxMarkers(boxMarkers_ud);    % create matched points matrix
%   mp - m x 2 x n matrix, where m is the number of points, the
%       second dimension contains (x,y) coordinates, and n is the number of
%       views. Assumed that n = 1 --> left mirror, n = 2 --> left direct
%       view, n = 3 --> right direct view, n = 4 --> right mirror view
%%
% calculate the fundamental matrices going from the direct to mirror views

% F = fundMatrixFromMatchedPoints(mp);
% boxMarkers_ud.F = F;

F.left = fundMatrix_mirror(mp(7:end,:,2), mp(7:end,:,1));
F.right = fundMatrix_mirror(mp(7:end,:,3), mp(7:end,:,4));

%%
% now need to calculate essential matrix 
E.left = K * F.left * K';   % assumption - the intrinsic parameters are the same for the virtual "mirror" camera as the real camera
                            % note, this gets confusing with the intrinsic
                            % matrix K. Matlab assumes K is lower triangular,
                            % the Hartley and Zisserman textbook assumes K is
                            % upper triangular. This changes the shape of the
                            % camera matrices (4x3 in matlab, 3x4 in H-Z) and
                            % the order of operations when computing projections
E.right = K * F.right * K';
                       
[rot,t] = EssentialMatrixToCameraMatrix(E.left);
[cRot,cT,~] = SelectCorrectEssentialCameraMatrix_mirror(rot,t,squeeze(mp(:,:,2))',squeeze(mp(:,:,1))',K');
P1 = eye(4,3);
P2 = [cRot,cT];
P2 = P2';

[rot,t] = EssentialMatrixToCameraMatrix(E.right);
[cRot,cT,~] = SelectCorrectEssentialCameraMatrix_mirror(rot,t,squeeze(mp(:,:,3))',squeeze(mp(:,:,4))',K');
P3 = [cRot,cT];
P3 = P3';
%%
% test to see if triangulation is working
% first, normalize fidelity points based on K:
l_direct_hom  = [mp(:,:,2), ones(size(mp,1),1)];   % need homogeneous coordinates for normalization
l_direct_norm = (K' \ l_direct_hom')';             % normalize by the intrinsics matrix
l_direct_norm = bsxfun(@rdivide,l_direct_norm(:,1:2),l_direct_norm(:,3));

r_direct_hom  = [mp(:,:,3), ones(size(mp,1),1)];
r_direct_norm = (K' \ r_direct_hom')';
r_direct_norm = bsxfun(@rdivide,r_direct_norm(:,1:2),r_direct_norm(:,3));

l_mirror_hom  = [mp(:,:,1), ones(size(mp,1),1)];
l_mirror_norm = (K' \ l_mirror_hom')';
l_mirror_norm = bsxfun(@rdivide,l_mirror_norm(:,1:2),l_mirror_norm(:,3));

r_mirror_hom  = [mp(:,:,4), ones(size(mp,1),1)];
r_mirror_norm = (K' \ r_mirror_hom')';
r_mirror_norm = bsxfun(@rdivide,r_mirror_norm(:,1:2),r_mirror_norm(:,3));

%%
% calculate world points
wpts_left  = triangulate_DL(l_direct_norm, l_mirror_norm, P1, P2);
wpts_right = triangulate_DL(r_direct_norm, r_mirror_norm, P1, P3);

wpts_left_hom  = [wpts_left,ones(size(wpts_left,1),1)];
wpts_right_hom = [wpts_right,ones(size(wpts_right,1),1)];
%%
% plot world points
figure
% set(gcf,'name','left mirror')
plot3(wpts_left(:,1),wpts_left(:,2),wpts_left(:,3),'marker','*','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('y');zlabel('z')
hold on
plot3(wpts_left(1,1),wpts_left(1,2),wpts_left(1,3),'marker','o','linestyle','none','color','r');
plot3(wpts_left(2,1),wpts_left(2,2),wpts_left(2,3),'marker','o','linestyle','none','color','k');
plot3(wpts_left(7,1),wpts_left(7,2),wpts_left(7,3),'marker','o','linestyle','none','color','g');

% figure
% set(gcf,'name','right mirror')
plot3(wpts_right(:,1),wpts_right(:,2),wpts_right(:,3),'marker','+','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('y');zlabel('z')
hold on
plot3(wpts_right(1,1),wpts_right(1,2),wpts_right(1,3),'marker','o','linestyle','none','color','r');
plot3(wpts_right(2,1),wpts_right(2,2),wpts_right(2,3),'marker','o','linestyle','none','color','k');
plot3(wpts_right(7,1),wpts_right(7,2),wpts_right(7,3),'marker','o','linestyle','none','color','g');
%%
% calculate reprojections
l_mirror_reproj_hom = wpts_left_hom * P2;
l_direct_reproj_hom = wpts_left_hom * P1;

r_mirror_reproj_hom = wpts_right_hom * P3;
r_direct_reproj_hom = wpts_right_hom * P1;

l_mirror_reproj = bsxfun(@rdivide,l_mirror_reproj_hom(:,1:2),l_mirror_reproj_hom(:,3));
l_direct_reproj = bsxfun(@rdivide,l_direct_reproj_hom(:,1:2),l_direct_reproj_hom(:,3));

r_mirror_reproj = bsxfun(@rdivide,r_mirror_reproj_hom(:,1:2),r_mirror_reproj_hom(:,3));
r_direct_reproj = bsxfun(@rdivide,r_direct_reproj_hom(:,1:2),r_direct_reproj_hom(:,3));

%%
% plot reprojections
figure
plot(l_mirror_reproj(:,1),l_mirror_reproj(:,2),'marker','*','linestyle','none')
hold on
set(gca,'ydir','reverse')
plot(l_direct_reproj(:,1),l_direct_reproj(:,2),'marker','*','linestyle','none')
plot(r_mirror_reproj(:,1),r_mirror_reproj(:,2),'marker','*','linestyle','none')
plot(r_direct_reproj(:,1),r_direct_reproj(:,2),'marker','*','linestyle','none')

% plot original points
plot(l_mirror_norm(:,1),l_mirror_norm(:,2),'marker','o','linestyle','none')
plot(l_direct_norm(:,1),l_direct_norm(:,2),'marker','o','linestyle','none')
plot(r_mirror_norm(:,1),r_mirror_norm(:,2),'marker','o','linestyle','none')
plot(r_direct_norm(:,1),r_direct_norm(:,2),'marker','o','linestyle','none')

%%
% now, need to transform the normalized points back to "real" coordinates
% we know that the checkerboard points are each 8 mm apart
% calculate distance between adjacent reconstructed checkerboard points:

% numPts = size(wpts_left,1);
% 
% cb_start = 7;
% cb_dist = zeros(12,2,2);
% d_horiz_idx = 0;
% d_vert_idx = 0;
% for iRow = 1 : 4
%     for iCol = 1 : 4
%         % calculate distance between horizontal adjacent points
%         if iCol < 4
%             d_horiz_idx = d_horiz_idx + 1;
%             cb_idx1 = (cb_start-1) + (iRow-1)*4 + iCol;
%             cb_idx2 = (cb_start-1) + (iRow-1)*4 + iCol + 1;
%             
%             cb_dist(d_horiz_idx,1,1) = norm(wpts_left(cb_idx1,:) - wpts_left(cb_idx2,:));
%             cb_dist(d_horiz_idx,1,2) = norm(wpts_right(cb_idx1,:) - wpts_right(cb_idx2,:));
%         end
%         if iRow < 4
%             d_vert_idx = d_vert_idx + 1;
%             cb_idx1 = (cb_start-1) + (iRow-1)*4 + iCol;
%             cb_idx2 = (cb_start-1) + (iRow-1)*4 + iCol + 4;
%             
%             cb_dist(d_vert_idx,2,1) = norm(wpts_left(cb_idx1,:) - wpts_left(cb_idx2,:));
%             cb_dist(d_vert_idx,2,2) = norm(wpts_right(cb_idx1,:) - wpts_right(cb_idx2,:));
%         end
%     end
% end

[d_horiz_left,d_vert_left] = calc_cb_spacing(wpts_left(7:end,:),[4,4]);
[d_horiz_right,d_vert_right] = calc_cb_spacing(wpts_right(7:end,:),[4,4]);
%%
cb_spacing = 8;   % in mm
d_left = [d_horiz_left;d_vert_left];
d_right = [d_horiz_right;d_vert_right];

left_scale = cb_spacing / mean(d_left);
right_scale = cb_spacing / mean(d_right);

wpts_scaled = zeros(size(wpts_left,1),3,2);
wpts_scaled(:,:,1) = wpts_left * left_scale;
wpts_scaled(:,:,2) = wpts_right * right_scale;
%%
% plot world points
figure
% set(gcf,'name','left mirror')
plot3(wpts_scaled(:,1,1),wpts_scaled(:,2,1),wpts_scaled(:,3,1),'marker','*','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('y');zlabel('z')
hold on
plot3(wpts_scaled(1,1,1),wpts_scaled(1,2,1),wpts_scaled(1,3,1),'marker','o','linestyle','none','color','r');
plot3(wpts_scaled(2,1,1),wpts_scaled(2,2,1),wpts_scaled(2,3,1),'marker','o','linestyle','none','color','k');
plot3(wpts_scaled(7,1,1),wpts_scaled(7,2,1),wpts_scaled(7,3,1),'marker','o','linestyle','none','color','g');

% figure
% set(gcf,'name','right mirror')
plot3(wpts_scaled(:,1,2),wpts_scaled(:,2,2),wpts_scaled(:,3,2),'marker','+','linestyle','none');
set(gca,'ydir','reverse');
xlabel('x');ylabel('y');zlabel('z')
hold on
plot3(wpts_scaled(1,1,2),wpts_scaled(1,2,2),wpts_scaled(1,3,2),'marker','o','linestyle','none','color','r');
plot3(wpts_scaled(2,1,2),wpts_scaled(2,2,2),wpts_scaled(2,3,2),'marker','o','linestyle','none','color','k');
plot3(wpts_scaled(7,1,2),wpts_scaled(7,2,2),wpts_scaled(7,3,2),'marker','o','linestyle','none','color','g');

set(gca,'zlim',[0 200])