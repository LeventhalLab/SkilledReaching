function boxCalibration = calibrate_sr_box(BGimg, varargin)
%
% usage: boxCalibration = calibrate_sr_box(BGimg, varargin)
%
% INPUTS:
%   BGimg - undistorted background image. In future versions, will take
%       multiple calibration images of the same checkerboard. Currently,
%       detecting the checkerboards mounted on the box
%
% VARARGs:
%   'cb_path' - path to the folder containing the checkerboard calibration
%       images
%   'num_rad_coeff' - number of radial distortion coefficients to calculate
%   'est_tan_distorion' - whether to estimate tangential distortion. In
%       general, this should be very close to zero and not necessary
%   'estimateskew' - should also be very close to zero and probably isn't
%       necessary
%
% OUTPUTS:
%   boxCalibration - structure with the following contents:
%       .boxMarkers - 
%       .cameraParams - camera parameters obtained from full screen
%           checkerboard calibration images
%       .mp - m x 2 x 4 array containing [x,y] pairs of matched points in each
%           view. The third dimension is for:
%               1 - left mirror
%               2 - direct view, points visible in left mirror
%               3 - direct view, points visible in right mirror
%               4 - right mirror
%       .mp_cb - same as above, but only includes checkerboard points. In
%           future versions, may add a dimension to include multiple
%           checkerboard images for the same view pairs
%       .scale - 2 element vector containing the scale factor to go from 3D
%           reconstructed camera-normalized coordinates to real world
%           coordinates (in mm)
%       .F - structure containing F.left and F.right - the fundamental
%           matrices going from the direct to mirror views
%       .P - structure containing camera matrices for the left and right
%           mirrors (P.left and P.right), assuming the direct view camera
%           matrix is eye(4,3)

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;
minBeadArea = 0300;
maxBeadArea = 2000;
pointsPerRow = 4;    % for the checkerboard detection
maxBeadEcc = 0.8;
hsvBounds_beads = [0.00    0.16    0.50    1.00    0.00    1.00
                   0.33    0.16    0.00    0.50    0.00    0.50
                   0.66    0.16    0.50    1.00    0.00    1.00];
               
for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'cb_path',
            cb_path = varargin{iarg + 1};
        case 'numradialdistortioncoefficients',
            num_rad_coeff = varargin{iarg + 1};
        case 'estimatetangentialdistortion',
            est_tan_distortion = varargin{iarg + 1};
        case 'estimateskew',
            estimateSkew = varargin{iarg + 1};
        case 'minbeadarea',
            minBeadArea = varargin{iarg + 1};
        case 'maxbeadarea',
            maxBeadArea = varargin{iarg + 1};
        case 'hsvbounds',
            hsvBounds_beads = varargin{iarg + 1};
        case 'maxeccentricity',
            maxBeadEcc = varargin{iarg + 1};
        case 'pointsperrow',
            pointsPerRow = varargin{iarg + 1};
    end
end

w = size(BGimg,2);

[cameraParams, ~, ~] = cb_calibration(...
                       'cb_path', cb_path, ...
                       'num_rad_coeff', num_rad_coeff, ...
                       'est_tan_distortion', est_tan_distortion, ...
                       'estimateskew', estimateSkew);
K = cameraParams.IntrinsicMatrix;

BGimg_ud = undistortImage(BGimg, cameraParams);   % accounts for lens distortion

% find the box fidelity markers and assemble matching points matrix
[boxMarkers_ud.beadLocations, boxMarkers_ud.beadMasks, boxMarkers_ud.beadReflectionMasks] = ...
                                                       identifyBeads(BGimg_ud, ...
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
BG_rgt = uint8(BGimg_ud(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
                     register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :));
BG_leftctr  = uint8(BGimg_ud(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    register_ROI(2,1):round(w/2), :));
BG_rightctr = uint8(BGimg_ud(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    round(w/2):register_ROI(2,1) + register_ROI(2,3), :));
                
% find the checkerboard points - comment these lines out to make it run
% faster, put them back in if checkerboard points need to be recalculated****************
% 
[cbLocations.left_mirror_cb, ~] = detect_SR_checkerboard(BG_lft,'pointsperrow',pointsPerRow);
cbLocations.left_mirror_cb(:,1) = cbLocations.left_mirror_cb(:,1) + register_ROI(1,1) - 1;
cbLocations.left_mirror_cb(:,2) = cbLocations.left_mirror_cb(:,2) + register_ROI(1,2) - 1;
[cbLocations.right_mirror_cb, ~] = detect_SR_checkerboard(BG_rgt,'pointsperrow',pointsPerRow);
cbLocations.right_mirror_cb(:,1) = cbLocations.right_mirror_cb(:,1) + register_ROI(3,1) - 1;
cbLocations.right_mirror_cb(:,2) = cbLocations.right_mirror_cb(:,2) + register_ROI(3,2) - 1;
[cbLocations.left_center_cb, ~]  = detect_SR_checkerboard(BG_leftctr,'pointsperrow',pointsPerRow);
cbLocations.left_center_cb(:,1) = cbLocations.left_center_cb(:,1) + register_ROI(2,1) - 1;
cbLocations.left_center_cb(:,2) = cbLocations.left_center_cb(:,2) + register_ROI(2,2) - 1;
[cbLocations.right_center_cb, boardSize] = detect_SR_checkerboard(BG_rightctr,'pointsperrow',pointsPerRow);
cbLocations.right_center_cb(:,1) = cbLocations.right_center_cb(:,1) + round(w/2) - 1;
cbLocations.right_center_cb(:,2) = cbLocations.right_center_cb(:,2) + register_ROI(2,2) - 1;

boxMarkers_ud.cbLocations = cbLocations;
% not sure identify box front is going to be necessary, but leaving it in
% for now. DL 20150831
boxMarkers_ud = identifyBoxFront(BGimg_ud, register_ROI, boxMarkers_ud);

% BELOW LINE WILL HAVE TO BE MODIFIED WHEN WE HAVE MULTIPLE CHECKERBOARD
% CALIBRATION IMAGES INSTEAD OF A SINGLE "BACKGROUND" IMAGE
mp = matchBoxMarkers(boxMarkers_ud);    % create matched points matrix
%   mp - m x 2 x n matrix, where m is the number of points, the
%       second dimension contains (x,y) coordinates, and n is the number of
%       views. Assumed that n = 1 --> left mirror, n = 2 --> left direct
%       view, n = 3 --> right direct view, n = 4 --> right mirror view

mp_cb = mp(7:end,:,:);    % contains only the checkerboard points

[scale,F,P1,P2] = calculate_sr_box_3Dparameters(K,mp_cb,boardSize);

boxCalibration.boxMarkers = boxMarkers_ud;
boxCalibration.cameraParams = cameraParams;
boxCalibration.mp = mp;
boxCalibration.mp_cb = mp_cb;
boxCalibration.scale = scale;
boxCalibration.F = F;
boxCalibration.P.left = P1;
boxCalibration.P.right = P2;