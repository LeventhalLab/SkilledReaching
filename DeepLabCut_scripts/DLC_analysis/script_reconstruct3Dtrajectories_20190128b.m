% script to perform 3D reconstruction on videos

repeatCalculations = true;

% points to the camera parameter file with camera intrinsics
camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
% camParamFile = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/multiview geometry/cameraParameters.mat';
load(camParamFile);

% parameter for calc3D_DLC_trajectory_20181204
maxDistFromNeighbor = 40;   % maximum distance an estimated point can be from its neighbor
maxReprojError = 10;

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
% xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');

ratInfo = readtable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
calImageDir = '/Volumes/Tbolt_02/Skilled Reaching/calibration_images';   % where the calibration files are

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHANGE THESE LINES DEPENDING ON PARAMETERS USED TO EXTRACT VIDEOS
% change this if the videos were cropped at different coordinates
vidROI = [750,450,550,550;
          1,450,450,400;
          1650,435,390,400];
triggerTime = 1;    % seconds
frameTimeLimits = [-1,3.3];    % time around trigger to extract frames
frameRate = 300;

frameSize = [1024,2040];
% would be nice to have these parameters stored with DLC output so they can
% be read in directly. Might they be in the .h files?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

% find the list of calibration files
% cd(calImageDir);
% calFileList = dir('SR_boxCalibration_*.mat');
% calDateList = cell(1,length(calFileList));
% calDateNums = zeros(length(calFileList),1);
% for iFile = 1 : length(calFileList)
%     C = textscan(calFileList(iFile).name,'SR_boxCalibration_%8c.mat');
%     calDateList{iFile} = C{1};
%     calDateNums(iFile) = str2double(calDateList{iFile});
% end

for i_rat = 8:8%numRatFolders

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
    
%     sessionDirectories = dir([ratID '_*']);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    if i_rat == 8
        startSession = 13;
        endSession = 13;
    else
        startSession = 1;
        endSession = numSessions;
    end
    for iSession = startSession : 2 : endSession
        
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
                ROIs = vidROI(1:2,:);
                Pn = squeeze(boxCal.Pn(:,:,2));
                sf = mean(boxCal.scaleFactor(2,:));
                F = squeeze(boxCal.F(:,:,2));
            case 'left'
                ROIs = vidROI([1,3],:);
                Pn = squeeze(boxCal.Pn(:,:,3));
                sf = mean(boxCal.scaleFactor(3,:));
                F = squeeze(boxCal.F(:,:,3));
        end
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        [directViewDir,mirrorViewDir,direct_csvList,mirror_csvList] = getDLC_csvList(fullSessionDir);

        if isempty(direct_csvList)
            continue;
        end
        
        numMarkedVids = length(direct_csvList);
        % ratID, date, etc. for each individual video
        directVidTime = cell(1, numMarkedVids);
        directVidNum = zeros(numMarkedVids,1);

        % find all the direct view videos that are available
        uniqueDateList = {};
        for ii = 1 : numMarkedVids   

            [directVid_ratID(ii),directVidDate{ii},directVidTime{ii},directVidNum(ii)] = ...
                extractDLC_CSV_identifiers(direct_csvList(ii).name);

            if isempty(uniqueDateList)
                uniqueDateList{1} = directVidDate{ii};
            elseif ~any(strcmp(uniqueDateList,directVidDate{ii}))
                uniqueDateList{end+1} = directVidDate{ii};
            end
        end

        cd(mirrorViewDir)

        for i_mirrorcsv = 30 : length(mirror_csvList)

            % make sure we have matching mirror and direct view files
            [mirror_ratID,mirror_vidDate,mirror_vidTime,mirror_vidNum] = extractDLC_CSV_identifiers(mirror_csvList(i_mirrorcsv).name);
            foundMatch = false;
            for i_directcsv = 1 : numMarkedVids
                if mirror_ratID == ratIDnum && ...      % match ratID
                   strcmp(mirror_vidDate, sessionDate) && ...  % match date
                   strcmp(mirror_vidTime, directVidTime{i_directcsv}) && ...  % match time
                   mirror_vidNum == directVidNum(i_directcsv)                % match vid number
                    foundMatch = true;
                    break;
                end
            end
            if ~foundMatch
                continue;
            end

            trajName = sprintf('R%04d_%s_%s_%03d_3dtrajectory_new.mat', directVid_ratID(i_directcsv),...
                directVidDate{i_directcsv},directVidTime{i_directcsv},directVidNum(i_directcsv))
            fullTrajName = fullfile(fullSessionDir, trajName);
            
%             COMMENT THIS BACK IN TO AVOID REPEAT CALCULATIONS
            
            if exist(fullTrajName,'file')
                % already did this calculation
                if repeatCalculations
                    load(fullTrajName)
                else
                    continue;
                end
            end
            
            cd(mirrorViewDir)
            [mirror_bp,mirror_pts,mirror_p] = read_DLC_csv(mirror_csvList(i_mirrorcsv).name);
            cd(directViewDir)
            [direct_bp,direct_pts,direct_p] = read_DLC_csv(direct_csvList(i_directcsv).name);
    
            if ~exist('manually_invalidated_points','var')
                numFrames = size(direct_p,2);
                num_bodyparts = length(direct_bp);
                manually_invalidated_points = false(numFrames,num_bodyparts,2);
            end
                    
            numDirectFrames = size(direct_p,2);
            numMirrorFrames = size(mirror_p,2);
    
            if numDirectFrames ~= numMirrorFrames
                fprintf('number of frames in the direct and mirror views do not match for %s\n', direct_csvList(i_directcsv).name);
            end
    
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

%             boxCal_fromVid = calibrateBoxFromDLCoutput(direct_pts_ud,mirror_pts_ud,direct_p,mirror_p,invalid_direct,invalid_mirror,direct_bp,mirror_bp,cameraParams,boxCal,pawPref);
            
            % find the appropriate box calibration for this session
            temp = boxCal.boxCal_fromSession;
            calibratedSessionNames = {temp.sessionName};
            if any(strcmpi(calibratedSessionNames,sessionDirectories{iSession}))
                sessionIdx = find(strcmpi(calibratedSessionNames,sessionDirectories{iSession}));
                activeBoxCal = boxCal.boxCal_fromSession(sessionIdx);
            else
                activeBoxCal = boxCal;
            end
            
            [pawTrajectory, bodyparts, final_direct_pts, final_mirror_pts, isEstimate] = ...
                calc3D_DLC_trajectory_20181204(direct_pts_ud, ...
                                      mirror_pts_ud, invalid_direct, invalid_mirror,...
                                      direct_bp, mirror_bp, ...
                                      vidROI, activeBoxCal, pawPref, frameSize,...
                                      'maxdistfromneighbor',maxDistFromNeighbor);
                                  
            [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, final_direct_pts, final_mirror_pts, direct_p, mirror_p, invalid_direct, invalid_mirror, direct_bp, mirror_bp, activeBoxCal, pawPref);
            
%             [paw_through_slot_frame,firstSlotBreak] = findPawThroughSlotFrame(pawTrajectory, bodyparts, pawPref, invalid_direct, invalid_mirror, reproj_error, 'slot_z',slot_z,'maxReprojError',maxReprojError);
%             initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,paw_through_slot_frame,...
%                 'time_to_average_prior_to_reach',time_to_average_prior_to_reach);
            cd(fullSessionDir)
            
%             if exist(trajName,'file')
%                 save(trajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','triggerTime','frameTimeLimits','ROIs','boxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','dist_from_epipole','lastValidCalDate','-append');
%             else
%                 save(fullTrajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','isEstimate','firstSlotBreak','initPellet3D','reproj_error','high_p_invalid','low_p_valid','paw_through_slot_frame');
                save(fullTrajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','activeBoxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','isEstimate','reproj_error','high_p_invalid','low_p_valid','manually_invalidated_points');
                clear manually_invalidated_points
%             end
            
        end
        
    end
    
end


% RUN script_recalibrateBoxes_20190128 once .csv files with DLC output from
%   both views are loaded into appropriate folders
% RUN this script
% RUN script_calculateKinematics_20190218 
% RUN script_plotMeanTrajectories

