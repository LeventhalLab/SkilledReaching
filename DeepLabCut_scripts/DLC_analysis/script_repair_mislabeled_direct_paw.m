% script_repair_mislabeled_direct_paw

% script to perform 3D reconstruction on videos

% in many videos,, the paw dorsum was misidentified in the direct
% view. This can probably be fixed with retraining networks, especially for
% unmarked paws. In the mean time, this script will invalidate those direct
% view points and recalculate the 3D trajectories using estimated paw
% dorsum locations

% points to the camera parameter file with camera intrinsics
camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);

% parameter for calc3D_DLC_trajectory_20181204
maxDistFromNeighbor = 40;   % maximum distance an estimated point can be from its neighbor
maxReprojError = 10;

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% parameters to determine invalid paw dorsum points in the direct view
maxPawFromDigitsDist = 70;
maxPawDorsumReprojError = 10;

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');

ratInfo = readtable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
calImageDir = '/Volumes/LL EXHD #2/calibration_images';   % where the calibration files are

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE THESE LINES DEPENDING ON PARAMETERS USED TO EXTRACT VIDEOS
% change this if the videos were cropped at different coordinates
% vidROI = [750,450,550,550;
%           1,450,450,400;
%           1650,435,390,400];
% triggerTime = 1;    % seconds
% frameTimeLimits = [-1,3.3];    % time around trigger to extract frames
% frameRate = 300;
% 
% frameSize = [1024,2040];
%
% these are now loaded in from the trajectory files themselves
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

for i_rat = 34:34%20:numRatFolders

    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    if istable(ratInfo)
        thisRatInfo = ratInfo(ratInfo_idx,:);
    else
        thisRatInfo = ratInfo(ratInfo_idx);
    end
    if iscell(thisRatInfo.pawPref)
        pawPref = thisRatInfo.pawPref{1};
    else
        pawPref = thisRatInfo.pawPref;
    end
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    switch ratID
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0235'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1 : endSession
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
        sessionYear = sessionDate(1:4);
        sessionMonth = sessionDate(1:6);
        
        calibrationDir = fullfile(calImageDir,sessionYear,[sessionMonth '_calibration'],[sessionMonth '_calibration_files']);
                % find the list of calibration files
        cd(calibrationDir);
        calFileList = dir('SR_boxCalibration_*.mat');
        calDateList = cell(1,length(calFileList));
        calDateNums = zeros(length(calFileList),1);
        for iFile = 1 : length(calFileList)
            C = textscan(calFileList(iFile).name,'SR_boxCalibration_%8c.mat');
            calDateList{iFile} = C{1};
            calDateNums(iFile) = str2double(calDateList{iFile});
        end
        fprintf('working on session %s_%s\n',ratID,sessionDate);

        % find the most recent date compared to the current file for which a
        % calibration file exists. Later, write code so files are stored by
        % date so that this file can be found before entering the loop through
        % DLC csv files
        [calibrationFileName, lastValidCalDate] = findCalibrationFile(calImageDir,sessionDate);
        if exist(calibrationFileName,'file')
            boxCal = load(calibrationFileName);
        else
            error('no calibration file found on or prior to %s\n',directVidDate{i_directcsv});
        end
        
        switch pawPref
            case 'right'
                Pn = squeeze(boxCal.Pn(:,:,2));
                sf = mean(boxCal.scaleFactor(2,:));
                F = squeeze(boxCal.F(:,:,2));
            case 'left'
                Pn = squeeze(boxCal.Pn(:,:,3));
                sf = mean(boxCal.scaleFactor(3,:));
                F = squeeze(boxCal.F(:,:,3));
        end
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        % find all the single trial .mat trajectory files
        trajFiles = dir([ratID '_' sessionDate '_*_3dtrajectory_new.mat']);
        numTrajFiles = length(trajFiles);
        
        for iTrial = 1 : numTrajFiles   
    
            % ROI info is now saved into the trajectory file
            load(trajFiles(iTrial).name);
            
            if ~exist('manually_invalidated_points','var')
                numFrames = size(direct_p,2);
                num_bodyparts = length(direct_bp);
                manually_invalidated_points = false(numFrames,num_bodyparts,2);
            end

            [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
            pawDorsum_reproj_error = squeeze(reproj_error(pawDorsumIdx,:,:));
            
            pts_to_invalidate = pawDorsum_reproj_error(:,1) > maxPawDorsumReprojError;

            % check if paw dorsum is far away from the other paw points
            otherPawIdx = [mcpIdx,pipIdx,digIdx];
            frames_to_check = find(pts_to_invalidate);
            
            for iFrame = 1 : length(frames_to_check)
                % how far is the paw dorsum from other points identified in
                % the direct view?
                pawDorsum_direct = squeeze(final_direct_pts(pawDorsumIdx,frames_to_check(iFrame),:));
                otherPaw_direct = squeeze(final_direct_pts(otherPawIdx,frames_to_check(iFrame),:));
                [nndist,~] = findNearestNeighbor(pawDorsum_direct,otherPaw_direct);
                
                if nndist < maxPawFromDigitsDist
                    pts_to_invalidate(frames_to_check(iFrame)) = false;
                end
            end
            
            if ~any(pts_to_invalidate(:))
                % nothing to invalidate in this trial, so just keep going
                continue
            end
            
            fprintf('working on %s\n',trajFiles(iTrial).name);
            manually_invalidated_points(:,13,1) = pts_to_invalidate;
            frames_to_recalculate = find(pts_to_invalidate);
            
            [invalid_mirror, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            [invalid_direct, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            
            frames_in_this_vid = size(invalid_mirror,2);
            frames_in_other_vids = size(manually_invalidated_points,1);
            if frames_in_this_vid < frames_in_other_vids
                % pad invalid_mirror and/or invalid_direct because of a
                % video that's too short for some reason
                invalid_mirror(:,frames_in_this_vid+1:frames_in_other_vids) = false;
                invalid_direct(:,frames_in_this_vid+1:frames_in_other_vids) = false;
            end
            invalid_mirror = invalid_mirror | squeeze(manually_invalidated_points(:,:,2))';
            invalid_direct = invalid_direct | squeeze(manually_invalidated_points(:,:,1))';
            
            direct_pts_ud = reconstructUndistortedPoints(direct_pts,ROIs(1,:),boxCal.cameraParams,~invalid_direct);
            mirror_pts_ud = reconstructUndistortedPoints(mirror_pts,ROIs(2,:),boxCal.cameraParams,~invalid_mirror);
            
            % find the appropriate box calibration for this session
            temp = boxCal.boxCal_fromSession;
            calibratedSessionNames = {temp.sessionName};
            if any(strcmpi(calibratedSessionNames,sessionDirectories{iSession}))
                sessionIdx = find(strcmpi(calibratedSessionNames,sessionDirectories{iSession}));
                activeBoxCal = boxCal.boxCal_fromSession(sessionIdx);
            else
                activeBoxCal = boxCal;
            end
            
            [final_direct_pts_new, final_mirror_pts_new, isEstimate_new] = ...
                recalc3D_DLC_trajectory_frames(direct_pts_ud, ...
                                      mirror_pts_ud, invalid_direct, invalid_mirror,...
                                      direct_bp, mirror_bp, ...
                                      frameSize,frames_to_recalculate,activeBoxCal,pawPref,...
                                      'maxdistfromneighbor',maxDistFromNeighbor);
            
            isEstimate = isEstimate | isEstimate_new;
            final_direct_pts(:,frames_to_recalculate,:) = final_direct_pts_new(:,frames_to_recalculate,:);
            final_mirror_pts(:,frames_to_recalculate,:) = final_mirror_pts_new(:,frames_to_recalculate,:);
            [pawTrajectory, bodyparts] = calc3Dpoints(final_direct_pts, final_mirror_pts, isEstimate, invalid_direct, invalid_mirror, direct_bp, mirror_bp, activeBoxCal, pawPref);
            
                                  
            [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, final_direct_pts, final_mirror_pts, direct_p, mirror_p, invalid_direct, invalid_mirror, direct_bp, mirror_bp, activeBoxCal, pawPref);
            
            cd(fullSessionDir)
            
            save(trajFiles(iTrial).name, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','activeBoxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','isEstimate','reproj_error','high_p_invalid','low_p_valid','manually_invalidated_points');
            clear manually_invalidated_points
            
        end
        
    end
    
end