% script_compareSessionEndPoints


% compare last training session end point to first laser session end point
% to last laser session end point

% compare alternating trial type end points
%

% calculate paw trajectories
%

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Users/dleventh/Documents/DLC analysis';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

num_on_sessions = 10;
num_occlude_sessions = 10;
bodypart_to_test = 'digit2';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
% xlDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');

ratInfo = readtable(csvfname);
ratInfo = cleanUpRatTable(ratInfo);
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
    pawPref = ratInfo.pawPref(ratInfo_idx);
    valid_bodyparts = [char(pawPref), bodypart_to_test];
    
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
    sessionInfo = cleanUpSessionTable(sessionInfo);

    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    % find the first laser session
    trainingRows = find(sessionInfo.trainingStage == 'training');
    training_table = sessionInfo(trainingRows,:);
    lastTrainingRow = training_table.session_in_block == max(training_table.session_in_block);
    lastTrainingDate = training_table.date{lastTrainingRow};
    
    laserRows = find(sessionInfo.laserStim == 'on' & sessionInfo.session_in_block <= num_on_sessions);
    laser_table = sessionInfo(laserRows,:);
    occlusionRows = find(sessionInfo.laserStim == 'occlude' & sessionInfo.session_in_block <= num_occlude_sessions);
    occlusion_table = sessionInfo(occlusionRows,:);
    
    fprintf('working on %s, last training session: %s\n', ratID,lastTrainingDate);
        
    lastTrainingSessionDir = dir([ratID '_' lastTrainingDate '*']);
    if ~isempty(lastTrainingSessionDir)
        lastTrainingfullSessionDir = fullfile(ratRootFolder,lastTrainingSessionDir(1).name);

        cd(lastTrainingfullSessionDir);
        % load the kinematics summary
        sessionSummaryName = [ratID '_' lastTrainingDate '_kinematicsSummary.mat'];
        if ~exist(sessionSummaryName,'file')
            fprintf('no session summary kinematics found for %s\n',sessionDirectories{iSession});
            continue;
        end
        load(sessionSummaryName);

        numTrials = size(all_initPellet3D,1);
        validTrials = 1 : numTrials;
        lastTrainingAnalyisis(i_rat).endPt_wrt_pellet = endPointsRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts);
        lastTrainingAnalyisis(i_rat).ratID = ratIDnum;
    end
    
    for iSession = 1 : length(laserRows)
        curRow = find(laser_table.session_in_block == iSession);
        curDate = laser_table.date{curRow};
        
        cd(ratRootFolder)
        
        curSessionDir = dir([ratID '_' curDate '*']);
        if isempty(curSessionDir)
            continue;
        end
        fullCurSessionDir = fullfile(ratRootFolder,curSessionDir.name);
        
        cd(fullCurSessionDir);
        % load the kinematics summary
        sessionSummaryName = [ratID '_' curDate '_kinematicsSummary.mat'];
        if ~exist(sessionSummaryName,'file')
            fprintf('no session summary kinematics found for %s\n',curSessionDir.name);
            continue;
        end
        load(sessionSummaryName);
        
        numTrials = size(all_initPellet3D,1);
        validTrials = 1 : numTrials;
        laserAnalysis(i_rat).endPt_wrt_pellet{iSession} = endPointsRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts);
        laserAnalysis(i_rat).sessionDate{iSession} = curDate;
    end
    
    for iSession = 1 : length(occlusionRows)
        curRow = find(occlusion_table.session_in_block == iSession);
        curDate = occlusion_table.date{curRow};
        
        cd(ratRootFolder)
        
        curSessionDir = dir([ratID '_' curDate '*']);
        if isempty(curSessionDir)
            continue;
        end
        fullCurSessionDir = fullfile(ratRootFolder,curSessionDir.name);
        
        cd(fullCurSessionDir);
        % load the kinematics summary
        sessionSummaryName = [ratID '_' curDate '_kinematicsSummary.mat'];
        if ~exist(sessionSummaryName,'file')
            fprintf('no session summary kinematics found for %s\n',curSessionDir.name);
            continue;
        end
        load(sessionSummaryName);
        
        numTrials = size(all_initPellet3D,1);
        validTrials = 1 : numTrials;
        occlusionAnalysis(i_rat).endPt_wrt_pellet{iSession} = endPointsRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts);
        occlusionAnalysis(i_rat).sessionDate{iSession} = curDate;
    end

    
end
        
        