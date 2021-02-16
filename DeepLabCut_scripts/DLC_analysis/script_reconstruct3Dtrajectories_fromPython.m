% script_reconstruct3Dtrajectories

% script to perform 3D reconstruction on videos

% in addition to a file tree for videos as follows:
% Raw Data File Structure
% -	Parent directory
% o	Rat folder, named with rat identifier (e.g., “R0186”)
% 	Sessions folders RXXXX_YYYYMMDDz (e.g., “R0186_20170921a” would be the first session recorded on September 21, 2017 for rat R0186)
% 
% Each sessions folder contains a .log file (read with readLogData) with session metadata, and videos named with the format RXXXX_YYYYMMDD_HH-MM-DD_nnn.avi, where RXXXX is the rat identifier, YYYYMMDD is the date, HH-MM-DD is the time the video was recorded, and nnn is the number of the video within the session (e.g., 001, 002, etc.). Sometimes the software crashed mid-session, and the numbering restarted. However, each video still has a unique identifier based on the time it was recorded.
% 
% Each rat has a RXXXX_sessions.csv file associated with it, which is a table containing metadata for each session (e.g., was laser on/occluded during that session, training vs test session, etc.)
%
% DLC Output File Structure
% Similar to Raw Data File Structure
% -	Parent directory
% o	Rat folder, named with rat identifier (e.g., “R0186”)
% 	Sessions folders RXXXX_YYYYMMDDz (e.g., “R0186_20170921a” would be the first session recorded on September 21, 2017 for rat R0186)
% •	Subfolders RXXXX_YYYYMMDDz_direct/left/right that contain the actual DLC output files and metadata from cropping (i.e., cropping coordinates, frame rate, etc) that particular view (left mirror, right mirror, or direct view)
%
% Calibration Files Directory Structure
% -	Parent directory
% o	Year (e.g., ‘2018’)
% 	YYYYMM_calibration (e.g., ‘201810_calibration’ would contain calibration images/files for October, 2018)
% •	YYYYMM_all_marked – contains images/.mat files with coordinates of all checkerboard points (automatically detected and manually marked)
% •	YYYYMM_auto_marked – contains images/.mat files with coordinates of all automatically detected checkerboard points
% •	YYYYMM_calibration_files – calibration files. These are .mat files containing fundamental, essential matrices, etc.
% •	YYYYMM_manually_marked – calibration images that have been manually marked in Fiji, as well as .csv files containing checkerboard corner coordinates
% •	YYYYMM_original_images – original calibration images

% also need: a .csv file with a table containing metadata about each rat
% ('Bova_Leventhal_2020_rat_database.csv')

% flag for whether to skip calculations if analysis files already exists
repeatCalculations = false;

% points to the camera parameter file with camera intrinsics
camParamFile = '/Users/dan/Documents/GitHub/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);

% parameters for calc3D_DLC_trajectory_20181204
maxDistFromNeighbor = 50;   % maximum distance an estimated point can be from its neighbor, in pixels
maxReprojError = 10;        % maximum tolerated 3D reprojection error

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% location of the master folder containing DLC .csv output files
% file struture:
% labeledBodypartsFolder-->'RXXXX'-->'RXXXX_sessiondate'-->'RXXXX_sessiondate_direct/left'
parent_folder = '/Volumes/Untitled/videos_to_analyze';
labeledBodypartsFolder = fullfile(parent_folder, 'matlab_readable_dlc');
ratIDs_to_analyze = [382];

% read in the rat database table
xlDir = parent_folder;
csvfname = fullfile(xlDir,'SR_rat_database.csv');
ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

% for saving a backup to a shared drive
% sharedX_DLCoutput_path = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/DLC output/';

% directory that contains calibration images
% file structure: 
calImageDir = fullfile(labeledBodypartsFolder, 'calibration_images');
      
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

for i_rat = 1:length(ratIDs_to_analyze)%1 : numRatFolders   % change limits to work on specific rats
    
    ratIDnum = ratIDs_to_analyze(i_rat);

    ratID = sprintf('R%04d', ratIDnum);%ratFolders(i_rat).name;
%     ratIDnum = str2double(ratID(2:end));
    
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
    
    % comment out if not auto-backing up to a shared drive
%     sharedX_ratRootFolder = fullfile(sharedX_DLCoutput_path,ratID);
    
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    switch ratID    % if want to analyze specific sessions for a given rat
        case 'R0221'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1: endSession
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
        sessionYear = sessionDate(1:4);
        sessionMonth = sessionDate(1:6);
        
        calibrationDir = fullfile(parent_folder,'calibration_files', sessionYear, [sessionMonth '_calibration'],[sessionMonth '_calibration_files']);
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
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        
        % find .mat file for this session
        test_name = sprintf('%s_box*_dlc-out.mat', ratID);
        mat_from_python_list = dir(test_name);
        
        num_vids = length(mat_from_python_list);
        
        for i_vid = 1 : num_vids
            C = textscan(mat_from_python_list(i_vid).name,[ratID '_box%02d_%8c_%8c_dlc-out.mat']);
            boxNum = C{1};
            dateStr = C{2};
            timeStr = C{3};

            full_mat_from_python_name = fullfile(fullSessionDir, mat_from_python_list(i_vid).name);
            [direct_bp, mirror_bp, direct_p, mirror_p, direct_pts_ud, mirror_pts_ud, pawPref, im_size, video_number, ROIs] = ...
                load_mat_from_python(full_mat_from_python_name);
            triggerTime = 1.0;
            frameRate = 300;
            frameTimeLimits = [-1.0,1000/3];
        
            % find the most recent date compared to the current file for which a
            % calibration file exists. Later, write code so files are stored by
            % date so that this file can be found before entering the loop through
            % DLC csv files
            [calibrationFileName, lastValidCalDate] = findCalibrationFile(fullfile(parent_folder,'calibration_files'),...
                boxNum,sessionDate);
            if exist(calibrationFileName,'file')
                boxCal = load(calibrationFileName);
            else
                error('no calibration file found on or prior to %s\n',sessionDate);
            end

            switch pawPref
                case 'right'
                    Pn = squeeze(boxCal.Pn(:,:,2));
                    sf = mean(boxCal.scaleFactor(2,:));
                    F = squeeze(boxCal.F(:,:,2));
                    mirrorView = 'left';
                case 'left'
                    Pn = squeeze(boxCal.Pn(:,:,3));
                    sf = mean(boxCal.scaleFactor(3,:));
                    F = squeeze(boxCal.F(:,:,3));
                    mirrorView = 'right';
            end
    
            trajName = sprintf('%s_box%02d_%s_%s_3dtrajectory.mat', ratID,...
                boxNum, dateStr,timeStr)

            fullTrajName = fullfile(fullSessionDir, trajName);
            
            % comment out below if not backing up to shared drive
%             sharedX_fullTrajName = fullfile(sharedX_fullSessionDir,trajName);
            
            if exist(fullTrajName,'file')
                % already did this calculation
                if repeatCalculations
                    load(fullTrajName)
                else
                    continue;
                end
            end


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
    
            [invalid_mirror, mirror_dist_perFrame] = find_invalid_DLC_points(mirror_pts_ud, mirror_p,mirror_bp,pawPref,...
                'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
            [invalid_direct, direct_dist_perFrame] = find_invalid_DLC_points(direct_pts_ud, direct_p,direct_bp,pawPref,...
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
            
            % find the appropriate box calibration for this session
            if isfield(boxCal, 'boxCal_fromSession')
                temp = boxCal.boxCal_fromSession;
                calibratedSessionNames = {temp.sessionName};
                if any(strcmpi(calibratedSessionNames,sessionDirectories{iSession}))
                    sessionIdx = find(strcmpi(calibratedSessionNames,sessionDirectories{iSession}));
                    activeBoxCal = boxCal.boxCal_fromSession(sessionIdx);
                else
                    activeBoxCal = boxCal;
                end
            else
                activeBoxCal = boxCal;
            end
            
            [pawTrajectory, bodyparts, final_direct_pts, final_mirror_pts, isEstimate] = ...
                calc3D_DLC_trajectory_20190924(direct_pts_ud, ...
                                      mirror_pts_ud, invalid_direct, invalid_mirror,...
                                      direct_bp, mirror_bp, ...
                                      activeBoxCal, pawPref, im_size,...
                                      'maxdistfromneighbor',maxDistFromNeighbor);
                                  
            [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, final_direct_pts, final_mirror_pts, direct_p, mirror_p, invalid_direct, invalid_mirror, direct_bp, mirror_bp, activeBoxCal, pawPref);

            cd(fullSessionDir)

            frameSize = im_size;
            save(fullTrajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','activeBoxCal','direct_pts_ud','mirror_pts_ud','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','isEstimate','reproj_error','high_p_invalid','low_p_valid','manually_invalidated_points');
            
            clear direct_p
            clear mirror_p
            clear direct_pts_ud
            clear mirror_pts_ud
            clear final_direct_pts
            clear final_mirror_pts
            % comment out next line if not backing up to a shared directory
%             save(sharedX_fullTrajName, 'pawTrajectory', 'bodyparts','thisRatInfo','frameRate','frameSize','triggerTime','frameTimeLimits','ROIs','boxCal','activeBoxCal','direct_pts','mirror_pts','mirror_bp','direct_bp','mirror_p','direct_p','lastValidCalDate','final_direct_pts','final_mirror_pts','isEstimate','reproj_error','high_p_invalid','low_p_valid','manually_invalidated_points');
            clear manually_invalidated_points
            
        end
        
    end
    
end