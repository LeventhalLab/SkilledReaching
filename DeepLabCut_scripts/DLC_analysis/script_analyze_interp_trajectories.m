% script_analyze_interp_trajectories

% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';


% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284];

% calculate the following kinematic parameters:
% 1. max velocity
% 2. average trajectory for a session
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    
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
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
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
        case 'R0189'
            startSession = 7;
            endSession = numSessions;
        case 'R0195'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1 : endSession
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        if ~isfolder(fullSessionDir)
            continue;
        end
        reachDataName = [ratID '_' sessionDateString '_processed_reaches.mat'];
        reachDataName = fullfile(fullSessionDir,reachDataName);
        
        cd(fullSessionDir);
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1}; % this will be in format yyyymmdd
                            % note date formats from the scores spreadsheet
                            % are in m/d/yy

        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDateNum = datenum(sessionDateString,'yyyymmdd');
        
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
        
        % initialize variables to hold the various kinematic values
        all_mcpAngle = zeros(numFrames,numTrials);
        all_pipAngle = zeros(numFrames,numTrials);
        all_digitAngle = zeros(numFrames,numTrials);
        all_pawAngle = zeros(numFrames,numTrials);
        
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
        
        temp_reachData = initializeReachDataStruct();
        for iTrial = 1 : numTrials
            trialNumbers(iTrial,:)
            slot_z_wrt_pellet = all_slot_z_wrt_pellet(iTrial);
            initPellet3D = all_initPellet3D(iTrial,:);
            interp_trajectory = squeeze(all_interp_traj_wrt_pellet(:,:,:,iTrial));
            
            reachData(iTrial) = identifyReaches(temp_reachData,interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref);
            reachData(iTrial) = calculateKinematics(reachData(iTrial),interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,frameRate);
            reachData(iTrial) = scoreTrial(reachData(iTrial),interp_trajectory,bodyparts,all_didPawStartThroughSlot(iTrial),pelletMissingFlag(iTrial),initPellet3D,slot_z_wrt_pellet,pawPref);
        end
        
        save(reachDataName,'reachData','all_didPawStartThroughSlot','all_frameRange','all_initPellet3D','all_slot_z_wrt_pellet','frameRate','pelletMissingFlag','slot_z','trialNumbers');
        clear reachData
    end
    
end
