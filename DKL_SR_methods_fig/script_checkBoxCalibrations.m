% script_checkBoxCalibrations

computeCamParams = false;
camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';

kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
pdfDir  = '/Users/dleventh/Documents/SR_plots';

xl_directory = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';

rubikSpacing = 17.5;    % in mm

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
                                    
                                    
sr_ratInfo = get_sr_RatList();    
ratDir = cell(1,length(sr_ratInfo));
triDir = cell(1,length(sr_ratInfo));
scoreDir = cell(1,length(sr_ratInfo));

for i_rat = 1 : 1%length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
    triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
    scoreDir{i_rat} = fullfile(ratDir{i_rat},'scoreData');
    
    matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                                 'xldir', xl_directory, ...
                                                 'xlname', xlName);
                                             
	[x1_left,x2_left,x1_right,x2_right,mp_metadata] = generateMatchedPointVectors(matchedPoints);
    srCal = sr_calibration(x1_left,x2_left,x1_right,x2_right);
    
    % first, load the background image from a video in this session, and
    % overlay the points on the image to see if they match. Then write that
    % video into the raw data folder
    
    numSessions = length(mp_metadata.sessionNames);
    for iSession = 1 : numSessions
        
        sessionDate = mp_metadata.sessionNames{iSession}(7:end);
        cd(rawData_parentDir);
        rawDataDir = [ratID '_' sessionDate '*'];
        rawDataDir = dir(rawDataDir);
        if isempty(rawDataDir)
            fprintf('no data folder for %s, %s\n',ratID, sessionDate)
            continue
        end
        if length(rawDataDir) > 1
            fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
            continue;
        end
        
        rawDataDir = fullfile(rawData_parentDir, rawDataDir.name);
        cd(rawDataDir);
       
        rbkFile = dir('*rubiksCalibration_ud.png');
        if isempty(rbkFile); continue; end
        
        BGname_ud = [ratID '_' sessionDate '_BG_ud.bmp'];
        if ~exist(BGname_ud,'file');continue;end
        
        BGimg_ud = imread(BGname_ud, 'bmp');
        rbkImg_ud = imread(rbkFile.name, 'png');
        
        P1 = eye(4,3);
        if numSessions == 1
            left_P2 = squeeze(srCal.P(:,:,1));
            right_P2 = squeeze(srCal.P(:,:,2));
        else
            left_P2 = squeeze(srCal.P(:,:,1,iSession));
            right_P2 = squeeze(srCal.P(:,:,2,iSession));
        end
        
        x1_left_norm = normalize_points(x1_left{iSession}, K);
        x2_left_norm = normalize_points(x2_left{iSession}, K);

        x1_right_norm = normalize_points(x1_right{iSession}, K);
        x2_right_norm = normalize_points(x2_right{iSession}, K);
    
        [left_points3d,left_norm_reprojPoints,left_errors] = triangulate_DL(x1_left_norm,x2_left_norm, P1, left_P2);
        [right_points3d,right_norm_reprojPoints,right_errors] = triangulate_DL(x1_right_norm,x2_right_norm, P1, right_P2);
        
        left_reprojPoints = zeros(size(left_norm_reprojPoints));
        right_reprojPoints = zeros(size(right_norm_reprojPoints));
        for iView = 1 : 2
            left_reprojPoints(:,:,iView) = unnormalize_points(squeeze(left_norm_reprojPoints(:,:,iView)),K);
            right_reprojPoints(:,:,iView) = unnormalize_points(squeeze(right_norm_reprojPoints(:,:,iView)),K);
        end
        
        figure(1)
        imshow(BGimg_ud);
        figName = sprintf('undistorted background image %s', BGname_ud);
        set(gcf,'name',figName);
        hold on
        plot(x1_left{iSession}(:,1), x1_left{iSession}(:,2), 'marker','o','color','b','linestyle','none');
        plot(x2_left{iSession}(:,1), x2_left{iSession}(:,2), 'marker','o','color','b','linestyle','none');
        plot(x1_right{iSession}(:,1), x1_right{iSession}(:,2), 'marker','o','color','r','linestyle','none');
        plot(x2_right{iSession}(:,1), x2_right{iSession}(:,2), 'marker','o','color','r','linestyle','none');
        
        plot(left_reprojPoints(:,1,1),left_reprojPoints(:,2,1),'marker','*','color','b','linestyle','none');
        plot(left_reprojPoints(:,1,2),left_reprojPoints(:,2,2),'marker','*','color','b','linestyle','none');
        plot(right_reprojPoints(:,1,1),right_reprojPoints(:,2,1),'marker','*','color','r','linestyle','none');
        plot(right_reprojPoints(:,1,2),right_reprojPoints(:,2,2),'marker','*','color','r','linestyle','none');

        figure(2)
        imshow(rbkImg_ud);
        figName = sprintf('undistorted calibration image %s', rbkFile.name);
        set(gcf,'name',figName);
        hold on
        plot(x1_left{iSession}(:,1), x1_left{iSession}(:,2), 'marker','o','color','b','linestyle','none');
        plot(x2_left{iSession}(:,1), x2_left{iSession}(:,2), 'marker','o','color','b','linestyle','none');
        plot(x1_right{iSession}(:,1), x1_right{iSession}(:,2), 'marker','o','color','r','linestyle','none');
        plot(x2_right{iSession}(:,1), x2_right{iSession}(:,2), 'marker','o','color','r','linestyle','none');

        plot(left_reprojPoints(:,1,1),left_reprojPoints(:,2,1),'marker','*','color','b','linestyle','none');
        plot(left_reprojPoints(:,1,2),left_reprojPoints(:,2,2),'marker','*','color','b','linestyle','none');
        plot(right_reprojPoints(:,1,1),right_reprojPoints(:,2,1),'marker','*','color','r','linestyle','none');
        plot(right_reprojPoints(:,1,2),right_reprojPoints(:,2,2),'marker','*','color','r','linestyle','none');
        
    end
end