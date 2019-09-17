% script to perform 3D reconstruction on videos

% slot_z = 200;    % distance from camera of slot in mm. hard coded for now
% time_to_average_prior_to_reach = 0.1;   % in seconds, the time prior to the reach over which to average pellet location

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
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');

ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
% calImageDir = '/Volumes/Tbolt_02/Skilled Reaching/calibration_images';   % where the calibration files are
% calImageDir = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/calibration_images';   % where the calibration files are
% calImageDir = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC calibration/calibration_images';
calImageDir = '/Volumes/LL EXHD #2/calibration_images';
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

% % find the list of calibration files
% cd(calImageDir);
% calFileList = dir('SR_boxCalibration_*.mat');
% calDateList = cell(1,length(calFileList));
% calDateNums = zeros(length(calFileList),1);
% for iFile = 1 : length(calFileList)
%     C = textscan(calFileList(iFile).name,'SR_boxCalibration_%8c.mat');
%     calDateList{iFile} = C{1};
%     calDateNums(iFile) = str2double(calDateList{iFile});
% end

for i_rat = 5:5%4:13%numRatFolders

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
        case 'R0169'
            startSession = 20;
            endSession = 20;
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
        
        calibrationFileName = findCalibrationFile(calImageDir,sessionDate);
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
        
        tic
        [boxCal_fromSession(sessionIdx),~,~] = calibrateBoxFromDLCSession(fullSessionDir,cameraParams,boxCal,pawPref,ROIs,'imsize',frameSize);
        toc
%         boxCal_fromSession(numValidSessions).sessionName = 
        
        cd(calImageDir);
        save(calibrationFileName,'boxCal_fromSession','-append')
        
    end
    
end

