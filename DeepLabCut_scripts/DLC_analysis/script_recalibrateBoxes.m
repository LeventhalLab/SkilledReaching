% script to recalibrate reaching boxes for a specific session based on
% matched points in videos in addition to matched points from the
% calibration cubes

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);

% parameters for calibrateBoxFromDLCSession
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');

ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
calImageDir = '/Volumes/LL EXHD #2/calibration_images';
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
% would be nice to have these parameters stored with DLC output so they can
% be read in directly. Might they be in the .h files?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

vidView = {'direct','right','left'};
numViews = length(vidView);

for i_rat = 37:37%4:13%numRatFolders

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
        case 'R0311'
            startSession = 25;
            endSession = 25;
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
%                 ROIs = vidROI(1:2,:);
                Pn = squeeze(boxCal.Pn(:,:,2));
                sf = mean(boxCal.scaleFactor(2,:));
                F = squeeze(boxCal.F(:,:,2));
            case 'left'
%                 ROIs = vidROI([1,3],:);
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
%         boxCal_fromSession(numValidSessions).sessionName = 
        
        cd(calImageDir);
        save(calibrationFileName,'boxCal_fromSession','-append')
        
    end
    
end

