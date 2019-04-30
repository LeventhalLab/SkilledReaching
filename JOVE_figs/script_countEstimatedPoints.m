% script_countEstimatedPoints

% CONSIDER EXCLUDING ANY TRIALS WHERE Z < 40 AT THE START OF THE TRIAL (PAW
% MAY ALREADY BE AT THE SLOT - MISSED TRIGGER)

x_lim = [-30 10];
y_lim = [-15 10];
z_lim = [-5 50];

var_lim = [0,5;
           0,5;
           0,10;
           0,10];
pawFrameLim = [0 400];

skipTrialPlots = true;
skipSessionSummaryPlots = false;

% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284];

% REACHING SCORES:
%
% 0 - No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue

trialTypeColors = {'k','k','b','r','g'};
validTrialTypes = {0:10,0,1,2,[3,4,7]};
validTypeNames = {'all','no pellet','1st reach success','any reach success','failed reach'};
numTrialTypes_to_analyze = length(validTrialTypes);

bodypart_to_plot = 'digit2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the figures for each type of plot
% mean p heat maps
mean_p_figProps.m = 4;
mean_p_figProps.n = 2;

mean_p_figProps.panelWidth = ones(mean_p_figProps.n,1) * 9;
mean_p_figProps.panelHeight = ones(mean_p_figProps.m,1) * 5;

mean_p_figProps.colSpacing = ones(mean_p_figProps.n-1,1) * 0.5;
mean_p_figProps.rowSpacing = ones(mean_p_figProps.m-1,1) * 1;

mean_p_figProps.width = 8.5 * 2.54;
mean_p_figProps.height = 11 * 2.54;

mean_p_figProps.topMargin = 2;
mean_p_figProps.leftMargin = 2.54;

mean_p_timeLimits = [-0.5,2];

% 3D trajectories for individual trials, and mean trajectories
trajectory_figProps.m = 5;
trajectory_figProps.n = 4;

trajectory_figProps.panelWidth = ones(trajectory_figProps.n,1) * 10;
trajectory_figProps.panelHeight = ones(trajectory_figProps.m,1) * 4;

trajectory_figProps.colSpacing = ones(trajectory_figProps.n-1,1) * 0.5;
trajectory_figProps.rowSpacing = ones(trajectory_figProps.m-1,1) * 1;

trajectory_figProps.width = 20 * 2.54;
trajectory_figProps.height = 12 * 2.54;

trajectory_figProps.topMargin = 5;
trajectory_figProps.leftMargin = 2.54;

ratSummary_figProps.m = 5;
ratSummary_figProps.n = 5;

ratSummary_figProps.panelWidth = ones(ratSummary_figProps.n,1) * 10;
ratSummary_figProps.panelHeight = ones(ratSummary_figProps.m,1) * 4;

ratSummary_figProps.colSpacing = ones(ratSummary_figProps.n-1,1) * 0.5;
ratSummary_figProps.rowSpacing = ones(ratSummary_figProps.m-1,1) * 1;

ratSummary_figProps.topMargin = 5;
ratSummary_figProps.leftMargin = 2.54;

ratSummary_figProps.width = sum(ratSummary_figProps.panelWidth) + ...
    sum(ratSummary_figProps.colSpacing) + ...
    ratSummary_figProps.leftMargin + 2.54;
ratSummary_figProps.height = sum(ratSummary_figProps.panelHeight) + ...
    sum(ratSummary_figProps.rowSpacing) + ...
    ratSummary_figProps.topMargin + 2.54;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


traj_xlim = [-30 10];
traj_ylim = [-20 60];
traj_zlim = [-20 20];

traj2D_xlim = [250 320];

bp_to_group = {{'mcp','pawdorsum'},{'pip'},{'digit'}};

summariesFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output/kinematics_summaries';

ratFolders = findRatFolders(summariesFolder);
numRatFolders = length(ratFolders);

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190315.csv');
ratInfo = readRatInfoTable(csvfname);

virusCategories = {'ChR2','Arch'};
timingCategories = {'During Reach','Between Reach'};

ratInfo_IDs = [ratInfo.ratID];
first_reachEndPoints = cell(numRatFolders,1);
mean_session_digit_trajectories = cell(numRatFolders,1);
mean_pd_trajectories = cell(numRatFolders,1);
mean_xyz_from_pd_trajectories = cell(numRatFolders,1);
mean_euc_dist_from_pd_trajectories = cell(numRatFolders,1);
mean_dig_trajectories = cell(numRatFolders,1);
mean_xyz_from_dig_trajectories = cell(numRatFolders,1);
mean_euc_dist_from_dig_trajectories = cell(numRatFolders,1);
paw_endAngle = cell(numRatFolders,1);
pawOrientationTrajectories = cell(numRatFolders,1);
meanOrientations = cell(numRatFolders,1);
mean_MRL = cell(numRatFolders,1);
endApertures = cell(numRatFolders,1);
apertureTrajectories = cell(numRatFolders,1);
meanApertures = cell(numRatFolders,1);
varApertures = cell(numRatFolders,1);
sessionDates = cell(numRatFolders,1);
sessionType = cell(numRatFolders,1);
numReachingFrames = cell(numRatFolders,1);
PL_summary = cell(numRatFolders,1);

numEstimatesPreSlot = cell(numRatFolders,1);
numEstimatesPostSlot = cell(numRatFolders,1);
totalPointsPreSlot = cell(numRatFolders,1);
totalPointsPostSlot = cell(numRatFolders,1);

experimentType = zeros(numRatFolders,1);

for i_rat = 1:numRatFolders
    
    ratID = ratFolders{i_rat};
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
    virus = thisRatInfo.Virus;
    if iscell(virus)
        virus = virus{1};
    end
    
    if any(ratIDs_with_new_date_format == ratIDnum)
        csvDateFormat = 'yyyyMMdd';
    end
    ratRootFolder = fullfile(summariesFolder,ratID);
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    if ~exist(reachScoresFile,'file')
        continue;
    end
    reachScores = readReachScores(reachScoresFile,'csvdateformat',csvDateFormat);
    allSessionDates = [reachScores.date]';
    
    cd(ratRootFolder);
    summariesList = dir('*_kinematicsSummary.mat');
    
    numSessions = length(summariesList);
    
    numSessionPages = 0;
    sessionType{i_rat} = determineSessionType(thisRatInfo, allSessionDates);
    for ii = 1 : length(sessionType{i_rat})
        sessionType{i_rat}(ii).typeFromScoreSheet = reachScores(ii).sessionType;
    end
    
    sessionDates{i_rat} = cell(1,numSessions);
    paw_endAngle{i_rat} = cell(1,numSessions);
    pawOrientationTrajectories{i_rat} = cell(1,numSessions);
    meanOrientations{i_rat} = cell(1,numSessions);
    mean_MRL{i_rat} = cell(1,numSessions);
    meanApertures{i_rat} = cell(1,numSessions);
    varApertures{i_rat} = cell(1,numSessions);
    endApertures{i_rat} = cell(1,numSessions);
    apertureTrajectories{i_rat} = cell(1,numSessions);
    
    numEstimatesPreSlot{i_rat} = cell(1,numSessions);
    numEstimatesPostSlot{i_rat} = cell(numSessions,1);
    totalPointsPreSlot{i_rat} = cell(numSessions,1);
    totalPointsPostSlot{i_rat} = cell(numSessions,1);
%     numReachingFrames = cell(1,numSessions);    % number of frames from first paw dorsum detection to max digit extension
    
    for iSession = 1:numSessions
        
        C = textscan(summariesList(iSession).name,[ratID '_%8c']);
        sessionDateString = C{1};
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDates{i_rat}{iSession} = sessionDate;
        
        allSessionIdx = find(sessionDate == allSessionDates);
        
%         fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
%         cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
             
        try
            load(sessionSummaryName);
        catch
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        
        pawPref = thisRatInfo.pawPref;
        Virus = thisRatInfo.Virus;
        laserTiming = thisRatInfo.laserTiming;
        if iscell(pawPref)
            pawPref = pawPref{1};
        end
        if iscell(Virus)
            Virus = Virus{1};
        end
        if iscell(laserTiming)
            laserTiming = laserTiming{1};
        end
        
        if strcmpi(Virus,'chr2') && strcmpi(laserTiming,'during reach')
            experimentType(i_rat) = 1;
        elseif strcmpi(Virus,'chr2') && strcmpi(laserTiming,'Between Reach')
            experimentType(i_rat) = 2;
        elseif strcmpi(Virus,'eyfp')
            experimentType(i_rat) = 3;
        else
            experimentType(i_rat) = 0;
        end

        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        
        [first_reachEndPoints{i_rat}{iSession},distFromPellet{i_rat}{iSession}] = collectFirstReachEndPoints(all_endPts,validTrialTypes,all_trialOutcomes);
        [all_reachEndPoints{i_rat}{iSession},numReaches_byPart{i_rat}{iSession},numReaches{i_rat}{iSession},reachFrames{i_rat}{iSession},reach_endPoints{i_rat}{iSession}] = ...
            collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,validTrialTypes,all_trialOutcomes,digIdx);

        numEstimatesPreSlot{i_rat}{iSession} = zeros(1,numSessions);
        numEstimatesPostSlot{i_rat}{iSession} = cell(numSessions,1);
        totalPointsPreSlot{i_rat}{iSession} = cell(numSessions,1);
        totalPointsPostSlot{i_rat}{iSession} = cell(numSessions,1);
    
        trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
        for iType = 1 : numTrialTypes_to_analyze
            trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
        end
%         matList = dir([ratID '_*_3dtrajectory_new.mat']);

        numTrials = size(allTrajectories,4);
        numFrames = size(allTrajectories, 1);
        t = linspace(frameTimeLimits(1),frameTimeLimits(2), numFrames);
        
%         pdf_baseName_indTrials = [sessionDirectories{iSession} '_singleTrials_normalized'];

        [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref);
        bodypart_idx_toPlot = find(findStringMatchinCellArray(bodyparts, bodypart_to_plot));
        
        [mean_pd_trajectory, mean_xyz_from_pd_trajectory, mean_euc_dist_from_pd_trajectory] = ...
            calcTrajectoryVariability(normalized_pd_trajectories,trialTypeIdx);
        
        numDigitParts = size(normalized_digit_trajectories,1);
        mean_session_digit_trajectories = zeros(numDigitParts,size(normalized_digit_trajectories,2),size(normalized_digit_trajectories,3),numTrialTypes_to_analyze);
        mean_xyz_from_dig_session_trajectories = zeros(numDigitParts,size(normalized_digit_trajectories,2),size(normalized_digit_trajectories,3),numTrialTypes_to_analyze);
        mean_euc_from_dig_session_trajectories = zeros(numDigitParts,size(normalized_digit_trajectories,2),numTrialTypes_to_analyze);
        for iDigit = 1 : numDigitParts
            [mean_session_digit_trajectories(iDigit,:,:,:),mean_xyz_from_dig_session_trajectories(iDigit,:,:,:),mean_euc_from_dig_session_trajectories(iDigit,:,:)] = ...
                calcTrajectoryVariability(squeeze(normalized_digit_trajectories(iDigit,:,:,:)),trialTypeIdx);
        end

        if iSession == 1
            mean_pd_trajectories{i_rat} = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),size(mean_pd_trajectory,3),numSessions);
            mean_xyz_from_pd_trajectories{i_rat} = zeros(size(mean_xyz_from_pd_trajectory,1),size(mean_xyz_from_pd_trajectory,2),size(mean_xyz_from_pd_trajectory,3),numSessions);
            mean_euc_dist_from_pd_trajectories{i_rat} = zeros(size(mean_euc_dist_from_pd_trajectory,1),size(mean_euc_dist_from_pd_trajectory,2),numSessions);
            
            mean_dig_trajectories{i_rat} = zeros(size(mean_session_digit_trajectories,1),size(mean_session_digit_trajectories,2),size(mean_session_digit_trajectories,3),size(mean_session_digit_trajectories,4),numSessions);
            mean_xyz_from_dig_trajectories{i_rat} = zeros(size(mean_xyz_from_dig_session_trajectories,1),size(mean_xyz_from_dig_session_trajectories,2),size(mean_xyz_from_dig_session_trajectories,3),size(mean_xyz_from_dig_session_trajectories,4),numSessions);
            mean_euc_dist_from_dig_trajectories{i_rat} = zeros(size(mean_euc_from_dig_session_trajectories,1),size(mean_euc_from_dig_session_trajectories,2),size(mean_euc_from_dig_session_trajectories,3),numSessions);
        end
        mean_pd_trajectories{i_rat}(:,:,:,iSession) = mean_pd_trajectory;
        mean_xyz_from_pd_trajectories{i_rat}(:,:,:,iSession) = mean_xyz_from_pd_trajectory;
        mean_euc_dist_from_pd_trajectories{i_rat}(:,:,iSession) = mean_euc_dist_from_pd_trajectory;
        
        mean_dig_trajectories{i_rat}(:,:,:,:,iSession) = mean_session_digit_trajectories;
        mean_xyz_from_dig_trajectories{i_rat}(:,:,:,:,iSession) = mean_xyz_from_dig_session_trajectories;
        mean_euc_dist_from_dig_trajectories{i_rat}(:,:,:,iSession) = mean_euc_from_dig_session_trajectories;
        
        [paw_endAngle{i_rat}{iSession},pawOrientationTrajectories{i_rat}{iSession}] = collectPawOrientations(all_pawAngle,all_paw_through_slot_frame,all_endPtFrame);
        [meanOrientations{i_rat}{iSession},mean_MRL{i_rat}{iSession}] = summarizePawOrientations(pawOrientationTrajectories{i_rat}{iSession});
        [endApertures{i_rat}{iSession},apertureTrajectories{i_rat}{iSession}] = collectApertures(all_aperture,all_paw_through_slot_frame,all_endPtFrame);
        [meanApertures{i_rat}{iSession},varApertures{i_rat}{iSession}] = summarizeApertures(apertureTrajectories{i_rat}{iSession});
        

            
    end
    
end

