% script to calculate calibration matrices given points labelled in Fiji
% (or anywhere else)
% these are distorted images, so all points need to be undistorted using
% the camera matrix before calculating 3D transformations

% given a set of matched points in mirror views, the following will
% calculate the world points:
%   [points3d,reprojectedPoints,errors] = triangulate_DL(mp1, mp2, P1, P2, varargin)
% where mp1, mp2 are arrays of matched points in the 2 views (direct and
% mirror, respectively), P1 is the direct view camera matrix, P2 is the
% mirror view camera matrix (calculated below)
% 
% to get the world points in real coordinates (origin at the camera),
% multiply the world points by the scale factor (currently set up to give
% an answer in mm)

% will need the camera matrix to remove distortion
computeCamParams = false;
cal_imgFolder = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';   % cube images in the box
% cal_imgFolder = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
camParamFile = 'cameraParameters.mat';
camParamFile = fullfile(cal_imgFolder, camParamFile);

cb_spacing = 4;   % real world spacing between calibration checkerboard vertices, in mm

% camParamFile = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
% cb_path = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
% cb_path is to checkerboard patterns for computing the camera parameters

if computeCamParams
    [cameraParams, ~, ~] = cb_calibration(...
                           'cb_path', cb_path, ...
                           'num_rad_coeff', num_rad_coeff, ...
                           'est_tan_distortion', est_tan_distortion, ...
                           'estimateskew', estimateSkew);
else
    load(camParamFile);    % contains a cameraParameters object named cameraParams
end
K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)
% 



calibrationFileLabel = 'GridCalibration';   % all calibration file names should begin with this string
% m_checkerboard = 4;   % number of rows in each checkerboard
% n_checkerboard = 5;   % number of columns in each checkerboard

% first, load in the marked points

% any x-coordinate less than 400 is from the left mirror
% any x-coordinate greater than 1600 is the right mirror
% any y-coordinate less than 400 is the top mirror

% in .csv files, put points in the following order:

% 1-12: left direct view
% 13-24: top direct view
% 25-36: right direct view
% 37-48: left mirror
% 49-60: top mirror
% 61-72: right mirror
% 73-76: left direct view outline
% 77-80: top direct view outline
% 81-84: right direct view outline

% numCheckPts = 12;
% directViewLeftIdx = 1 : numCheckPts;
% directViewTopIdx = directViewLeftIdx(end) + 1 : numCheckPts * 2;
% directViewRightIdx = directViewTopIdx(end) + 1 : numCheckPts * 3;
% leftMirrorIdx = directViewRightIdx(end) + 1 : numCheckPts * 4;
% topMirrorIdx = leftMirrorIdx(end) + 1 : numCheckPts * 5;
% rightMirrorIdx = topMirrorIdx(end) + 1 : numCheckPts * 6;

cd(cal_imgFolder);
cal_imgList = dir([calibrationFileLabel '_*.png']);
num_cal_img = length(cal_imgList);

% extract session dates from cal_imgList names
sessionDates = cell(1);
numUniqueSessions = 0;
for i_img = 1 : num_cal_img
    dateStartIdx = length(calibrationFileLabel) + 2;
    dateEndIdx = dateStartIdx + 7;
    curDate = cal_imgList(i_img).name(dateStartIdx : dateEndIdx);
    
    if any(strcmp(sessionDates,curDate))
        continue;
    end
    
    numUniqueSessions = numUniqueSessions + 1;
    sessionDates{numUniqueSessions} = curDate;
end

for iDate = 1 : numUniqueSessions
    
    test_MAT_string = [calibrationFileLabel '_' sessionDates{iDate} '_*.mat'];

    sessionMATlist = dir(test_MAT_string);
    
    num_mat = length(sessionMATlist);
    
    
    for i_mat = 1 : num_mat
        
        matName = sessionMATlist(i_mat).name;
        pngName = strrep(matName,'mat','png');
        
        % read in .mat file with identified points
        load(matName);
        
        % check that points project correctly onto the calibration image
        % MAKE SURE POINTS ARE UNDISTORTED EARLY ON
        % read in the .png
        calImg = imread(pngName,'png');
        calImg_ud = undistortImage(calImg, cameraParams);
        figure(1)
        set(gcf,'name',pngName);
        imshow(calImg_ud)
        hold on
        
        
        calibration_points = zeros(size(all_check_centers));
        for iMask = 1 : 6
            calibration_points(:,:,iMask) = undistortPoints(squeeze(all_check_centers(:,:,iMask)), cameraParams);
        end
        
        % separate the points into the checkerboard images for each view
%         [ directLeftPoints, directRightPoints, directTopPoints, leftMirrorPoints, rightMirrorPoints, topMirrorPoints ] = ...
%             assign_points_to_checkerboards(calibration_points, directViewLeftIdx, directViewRightIdx, directViewTopIdx, leftMirrorIdx, rightMirrorIdx, topMirrorIdx);
        
        directTopPoints = calibration_points(:,:,1);
        topMirrorPoints = calibration_points(:,:,2);
        directLeftPoints = calibration_points(:,:,3);
        leftMirrorPoints = calibration_points(:,:,4);
        directRightPoints = calibration_points(:,:,5);
        rightMirrorPoints = calibration_points(:,:,6);
        % match points between views
        leftMatchedPoints = matchMirrorPoints(directLeftPoints, leftMirrorPoints, 'left');
        rightMatchedPoints = matchMirrorPoints(directRightPoints, rightMirrorPoints, 'right');
        topMatchedPoints = matchMirrorPoints(directTopPoints, topMirrorPoints, 'top');
        
        boardSize = zeros(3,2);
        boardSize(1,:) = determineCheckerboardSize(leftMatchedPoints(:,:,1));
        boardSize(2,:) = determineCheckerboardSize(rightMatchedPoints(:,:,1));
        boardSize(3,:) = determineCheckerboardSize(topMatchedPoints(:,:,1));
        
        % now have matched points. Calculate fundamental matrices, scale
        % factors, camera mscratrices
        mp = zeros(size(calibration_points));
        mp(:,:,1:2) = leftMatchedPoints;
        mp(:,:,3:4) = rightMatchedPoints;
        mp(:,:,5:6) = topMatchedPoints;
        
        [scale,F,P1,P2,wpts,reproj] = calibrate_SRbox_20180530(K,mp,boardSize,'cb_spacing',cb_spacing);
        % scale(1) - left mirror, scale(2) - right mirror, scale(3) - top
        % mirror
        

        
        for iView = 1 : 2
            left_reprojPoints(:,:,iView) = unnormalize_points(squeeze(reproj.left(:,:,iView)), K);
            right_reprojPoints(:,:,iView) = unnormalize_points(squeeze(reproj.right(:,:,iView)), K);
            top_reprojPoints(:,:,iView) = unnormalize_points(squeeze(reproj.top(:,:,iView)), K);
            
            scatter(squeeze(left_reprojPoints(:,1,iView)),squeeze(left_reprojPoints(:,2,iView)))
            scatter(squeeze(right_reprojPoints(:,1,iView)),squeeze(right_reprojPoints(:,2,iView)))
            scatter(squeeze(top_reprojPoints(:,1,iView)),squeeze(top_reprojPoints(:,2,iView)))
        end
        
    end
end
