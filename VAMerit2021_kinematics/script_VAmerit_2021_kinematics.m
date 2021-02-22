% script_VAmerit_2021_kinematics

parent_folder = '/Volumes/Untitled/videos_to_analyze';
labeledBodypartsFolder = fullfile(parent_folder, 'matlab_readable_dlc');
xlDir = parent_folder;%'/Users/dan/Box/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
% xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'SR_rat_database.csv');
ratInfo = readRatInfoTable(csvfname);

ratSummaryDir = fullfile(labeledBodypartsFolder,'rat_kinematic_summaries');

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

sessions_grouping = {'training','saline','OHDA1','OHDA2','OHDA3','OHDA4','OHDA5','OHDA6'};

if exist('group_kinematics','var')
    clear group_kinematics
end
for i_rat = 2:2%1 : numRatFolders
    
    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    
    ratSummaryName = [ratID '_kinematicsSummary.mat'];
        cd(ratSummaryDir)
    if exist(ratSummaryName,'file')
        load(ratSummaryName)
    else
        fprintf('no rat summary found for %s\n',ratID)
    end
    
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
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    % figure out all the session types
    sessions_from_table = cellstr(ratSummary.sessions_analyzed.trainingStage);
    
    for i_stage = 1 : length(sessions_grouping)
        i_stage
        current_session_idxs = find(strcmpi(sessions_from_table, sessions_grouping{i_stage}));
        current_sessions = ratSummary.sessions_analyzed(current_session_idxs,:);
        
        current_dates = current_sessions.date;
        
        group_kinematics(i_stage) = collect_group_trials(sessionDirectories, current_sessions, ratSummary, current_session_idxs, ratRootFolder); %#ok<*SAGROW>

        
    end
        
    
    figure
    % collect kinematics
    
    max_v = zeros(1, length(group_kinematics));
    max_endpt = zeros(length(group_kinematics),3);
    mean_aperture = zeros(1,length(group_kinematics));
    mean_orientation = zeros(1,length(group_kinematics));
    for ii = 1 : length(group_kinematics)
        % paw velocity
        max_v(ii) = nanmean(group_kinematics(ii).max_pd_v);
        max_endpt(ii,:) = nanmean(group_kinematics(ii).pdEndPts);
        mean_aperture(ii,:) = nanmean(group_kinematics(ii).end_aperture);
        mean_orientation(ii,:) = nanmean(group_kinematics(ii).end_orientation);
        
    end
    
    figure;plot(max_v); set(gcf,'name','max v')
    figure;plot(max_endpt(:,1)); set(gcf,'name','max x')
    figure;plot(max_endpt(:,2)); set(gcf,'name','max y')
    figure;plot(max_endpt(:,3)); set(gcf,'name','max z')
    figure;plot(mean_aperture); set(gcf,'name','aperture');
    figure;plot(mean_orientation*180/pi); set(gcf,'name','orientation');
    
end
    