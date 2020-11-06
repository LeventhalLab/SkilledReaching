% script to recalibrate reaching boxes for a specific session based on
% matched points in videos in addition to matched points from the
% calibration cubes

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
% DLC Output File Structure - similar to raw data file structure
% -	Parent directory
% o	Rat folder, named with rat identifier (e.g., “R0186”)
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
%
% also need: a .csv file with a table containing metadata about each rat
% (e.g., 'Bova_Leventhal_2020_rat_database.csv')

% file storing intrinsic parameters for the camera
camParamFile = '/Users/dan/Documents/GitHub/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);

% parameters for calibrateBoxFromDLCSession
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

% path to Parent directory for video files
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';

% path to DLC output parent folder
labeledBodypartsFolder = '/Volumes/Untitled/for_creating_3d_vids';
xlDir = labeledBodypartsFolder;
csvfname = fullfile(xlDir,'SR_rat_database.csv');

ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

calImageDir = fullfile(labeledBodypartsFolder, 'calibration_images');

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

for i_rat = 1 : numRatFolders

    ratID = ratFolders(i_rat).name
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
        case 'R0216'
            startSession = numSessions-1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    
    
    for iSession = startSession : 1 : endSession
        
        if exist('boxCal_fromSession','var')
            clear boxCal_fromSession;
        end
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
 
        fprintf('working on session %s_%s\n',ratID,sessionDate);
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        
        logFiles = dir('*.log');
        if isempty(logFiles)
            status = copyLogToDLCOutput(sessionDirectories{iSession},labeledBodypartsFolder,vidRootPath);
            logFiles = dir('*.log');
        end
        curLog = readLogData(logFiles(1).name);
        
        box_1_dates = {'20191122','20191123','20191124','20191125'};
        if isfield(curLog,'boxnumber')
            boxNum = curLog.boxnumber;
        elseif any(ismember(box_1_dates,sessionDate))
            boxNum = 01;
        else
            boxNum = 99;   % used 99 as box number before this was written into .log files 20191126
        end
        
        calibrationFileName = findCalibrationFile(calImageDir,boxNum,sessionDate);
        if exist(calibrationFileName,'file')
            boxCal = load(calibrationFileName);
        else
            error('no calibration file found on or prior to %s\n',directVidDate{i_directcsv});
        end
        
        if isfield(boxCal,'boxCal_fromSession')
            boxCal_fromSession = boxCal.boxCal_fromSession;
            sessionList = {boxCal_fromSession.sessionName};
            
            if any(strcmpi(sessionList,sessionDirectories{iSession}))
                sessionIdx = find(strcmpi(sessionList,sessionDirectories{iSession}));
            else
                sessionIdx = length(boxCal_fromSession) + 1;
            end
            boxCal = rmfield(boxCal,'boxCal_fromSession');    
        else
            sessionIdx = 1;
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
    
        
        
        tic
        [boxCal_fromSession(sessionIdx),~,~] = calibrateBoxFromDLCSession(fullSessionDir,cameraParams,boxCal,pawPref,...
                                                                          'min_valid_p',min_valid_p,...
                                                                          'min_certain_p',min_certain_p,...
                                                                          'maxneighbordist',maxDistFromNeighbor_invalid,...
                                                                          'maxdistperframe',maxDistPerFrame);
        toc
        
        cd(calImageDir);
        save(calibrationFileName,'boxCal_fromSession','-append')
        
    end
    
end

