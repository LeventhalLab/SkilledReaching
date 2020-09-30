% script_analyze_interp_trajectories

% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';
num_traj_segments = 100;   % number of points into which trajectories will be segmented for averaging
max_pd_z = 30;   % z-coordinate at which to start paw dorsum analysis
max_dig_z = 20;  % z-coordinate at which to start digit trajectory analysis

% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284,309,310,311,312];

% calculate the following kinematic parameters:
% 1. max velocity, by reach type
% 2. average trajectory for a session, by reach time
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z, by type
% 7. number of reaches, by type

% sharedX_string = 'SharedX';
% sharedX_root = fullfile('/Volumes',sharedX_string,'Neuro-Leventhal');
% if ~exist(sharedX_root,'dir')
%     sharedX_string = 'SharedX-1';
%     sharedX_root = fullfile('/Volumes',sharedX_string,'Neuro-Leventhal');
% end

labeledBodypartsFolder = '/Volumes/Untitled/for_creating_3d_vids';
% labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
xlDir = labeledBodypartsFolder;%'/Users/dan/Box/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
% xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'SR_rat_database.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

temp_reachData = initializeReachDataStruct();

for i_rat = 6 : 6%numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    temp_reachData.ratIDnum = ratIDnum;
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx,:);
    pawPref = thisRatInfo.pawPref;
    if iscategorical(pawPref)
        pawPref = char(pawPref);
    end
    if iscell(pawPref)
        pawPref = pawPref{1};
    end
    
    if any(ratIDs_with_new_date_format == ratIDnum)
        csvDateFormat = 'yyyyMMdd';
    end
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
%     sharedX_ratRootFolder = fullfile(sharedX_DLCoutput_path,ratID);
    
    % read in scores from manual review of each trial
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    reachScores = readReachScores(reachScoresFile,'csvdateformat',csvDateFormat);
    allSessionDates = [reachScores.date]';
    numTableSessions = length(reachScores);
    dateNums_from_scores_table = zeros(numTableSessions,1);
    for iSession = 1 : numTableSessions
        dateNums_from_scores_table(iSession) = datenum(reachScores(iSession).date);
    end
    
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    sessionType = determineSessionType(thisRatInfo, allSessionDates);
    
    switch ratID
        case 'R0158'
            startSession = 1;
            endSession = numSessions;
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0160'
            startSession = 1;
            endSession = 22;
        case 'R0216'
            startSession = numSessions-2;
            endSession = numSessions-2;
        case 'R0312'
            startSession = numSessions-2;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1 : endSession
        if exist('reachData','var')
            clear reachData
        end
        curSessionDir = sessionDirectories{iSession};
        fullSessionDir = fullfile(ratRootFolder,curSessionDir);
%         sharedX_fullSessionDir = fullfile(sharedX_ratRootFolder,sessionDirectories{iSession});
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        
        cd(fullSessionDir);
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1}; % this will be in format yyyymmdd
                            % note date formats from the scores spreadsheet
                            % are in m/d/yy

        base_reachDataName = [ratID '_' sessionDateString '_processed_reaches.mat'];
        reachDataName = fullfile(fullSessionDir,base_reachDataName);
%         sharedX_reachDataName = fullfile(sharedX_fullSessionDir,base_reachDataName);
        
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        allSessionIdx = find(sessionDate == allSessionDates);
        sessionDateNum = datenum(sessionDateString,'yyyymmdd');
        
        temp_reachData.sessionDate = sessionDate;
        
        thisSessionType = sessionType(allSessionIdx);
        
        if ~isempty(allSessionIdx)
            sessionReachScores = reachScores(allSessionIdx).scores;
        else
            sessionReachScores = [];   % if a session hasn't been scored
        end
        
        % find the pawTrajectory files
        pawTrajectoryList = dir(trajectory_file_name);
        if isempty(pawTrajectoryList)
            continue
        end
        
        fprintf('working on %s\n',sessionDirectories{iSession});
        numTrials = length(pawTrajectoryList);
        interpTrajectoryName = [ratID '_' sessionDateString '_interp_trajectories.mat'];
        
        load(interpTrajectoryName);
        numFrames = size(all_interp_traj_wrt_pellet,1);
        num_bodyparts = size(all_interp_traj_wrt_pellet,3);
        numTrials = size(all_interp_traj_wrt_pellet,4);
        
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        numReachingPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);
        
        all_endPts = zeros(numReachingPawParts, 3, numTrials);
        all_final_endPts = zeros(numReachingPawParts, 3, numTrials);
        all_partEndPts = zeros(numReachingPawParts, 3, numTrials);
        all_partFinalEndPts = zeros(numReachingPawParts, 3, numTrials);
        all_partFinalEndPtFrame = zeros(numReachingPawParts, numTrials);
        all_first_pawPart_outside_box = zeros(numReachingPawParts, numTrials);
        all_firstSlotBreak = zeros(numReachingPawParts, numTrials);
        all_firstPawDorsumFrame = zeros(numTrials,1);
        all_aperture = NaN(numFrames,3,numTrials);
        all_maxDigitReachFrame = zeros(numTrials,1);
        all_initPellet3D = NaN(numTrials, 3);
        
        for iTrial = 1 : numTrials
%             trialNumbers(iTrial,:)
            slot_z_wrt_pellet = all_slot_z_wrt_pellet(iTrial);
            initPellet3D = all_initPellet3D(iTrial,:);
            interp_trajectory = squeeze(all_interp_traj_wrt_pellet(:,:,:,iTrial));
            
            reachData(iTrial) = identifyReaches(temp_reachData,interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref);
            try
            reachData(iTrial) = calculateKinematics(reachData(iTrial),interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,frameRate);
            catch
                keyboard
            end
            if ~isempty(sessionReachScores)
                trialOutcome = sessionReachScores(trialNumbers(iTrial,2));
            else
                trialOutcome = [];
            end
            reachData(iTrial) = scoreTrial(reachData(iTrial),interp_trajectory,bodyparts,all_didPawStartThroughSlot(iTrial),pelletMissingFlag(iTrial),initPellet3D,slot_z_wrt_pellet,pawPref,trialOutcome);
            reachData(iTrial).trialNumbers = trialNumbers(iTrial,:);
            reachData(iTrial).slot_z_wrt_pellet = slot_z_wrt_pellet;
%             sessionSummary = sessionKinematicsSummary(reachData);
        end
        [sessionSummary,reachData] = sessionKinematicsSummary(reachData,num_traj_segments);
        
        save(reachDataName,'reachData','sessionSummary','all_didPawStartThroughSlot','all_frameRange','all_initPellet3D','all_slot_z_wrt_pellet','frameRate','pelletMissingFlag','slot_z','trialNumbers','thisSessionType','curSessionDir','thisRatInfo');
%         save(sharedX_reachDataName,'reachData','sessionSummary','all_didPawStartThroughSlot','all_frameRange','all_initPellet3D','all_slot_z_wrt_pellet','frameRate','pelletMissingFlag','slot_z','trialNumbers','thisSessionType','curSessionDir','thisRatInfo');
        
    end
    
end
