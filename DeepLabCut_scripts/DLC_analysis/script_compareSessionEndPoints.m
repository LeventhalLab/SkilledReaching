% script_compareSessionEndPoints


% compare last training session end point to first laser session end point
% to last laser session end point

% compare alternating trial type end points
%

% calculate paw trajectories
%

% labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
labeledBodypartsFolder = '/Users/dleventh/Documents/DLC analysis';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

% xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');

ratInfo = readtable(csvfname);
% ratInfo = readExcelDB(xlfname, 'well learned');
% ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo.ratID == ratIDnum);
    
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
%     thisRatInfo = ratInfo(ratInfo_idx);
    pawPref = ratInfo.pawPref{ratInfo_idx};
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    % load in info about each session
    sessionDBfile = dir([ratID '_sessions*.csv']);
    if isempty(sessionDBfile)
        fprintf('no session database file for %s\n',ratID);
        continue;
    elseif length(sessionDBfile) > 1
        fprintf('more than one session database file for %s\n',ratID);
        continue
    end
    sessionInfo = readtable(sessionDBfile.name);
    sessionInfo.ratID = categorical(sessionInfo.ratID);
    sessionInfo.trainingStage = categorical(sessionInfo.trainingStage);
    sessionInfo.laserStim = categorical(sessionInfo.laserStim);
    sessionInfo.laserTrialSetting = categorical(sessionInfo.laserTrialSetting);
    sessionInfo.experimenter = categorical(sessionInfo.experimenter);
    sessionInfo.laserOnTiming = categorical(sessionInfo.laserOnTiming);
    sessionInfo.laserOffTiming = categorical(sessionInfo.laserOffTiming);
    
    sessionDirs = dir([ratID '_2*']);
    numValidDirs = 0;
    for ii = 1 : length(sessionDirs)
        if isdir(sessionDirs(ii).name)
            numValidDirs = numValidDirs + 1;
            sessionDirectories{numValidDirs} = sessionDirs(ii).name;
        end
    end
        
%     sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    % find the first laser session
    firstLaserRow = find(sessionInfo.laserStim == 'on' & strcmp(sessionInfo.session_in_block, '1'));
    firstLaserDate = sessionInfo.date{firstLaserRow};
    lastLaserRow = find(sessionInfo.laserStim == 'on' & strcmp(sessionInfo.session_in_block, '10'));
    lastLaserDate = sessionInfo.date{lastLaserRow};
    lastTrainingRow = firstLaserRow - 1;
    lastTrainingDate = sessionInfo.date{lastTrainingRow};
    
    
        fprintf('working on %s, last training session: %s\n', ratID,lastTrainingDate);
        
        lastTrainingSessionDir = dir([ratID '_' lastTrainingDate '*']);
        
        lastTrainingfullSessionDir = fullfile(ratRootFolder,lastTrainingSessionDir);
        
        cd(lastTrainingfullSessionDir);
        % load the kinematics summary
        sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
        
        if ~exist(sessionSummaryName,'file')
            fprintf('no session summary kinematics found for %s\n',sessionDirectories{iSession});
            continue;
        end
        load(sessionSummaryName);
        
        endPt_wrt_pellet{1} = endPointsRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts);
        % WORKING HERE...
        

    
end
        
        