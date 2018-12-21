% script_summaryDLCstatistics

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
trajectory_figProps.m = 4;
trajectory_figProps.n = 3;

trajectory_figProps.panelWidth = ones(trajectory_figProps.n,1) * 13;
trajectory_figProps.panelHeight = ones(trajectory_figProps.m,1) * 5;

trajectory_figProps.colSpacing = ones(trajectory_figProps.n-1,1) * 0.5;
trajectory_figProps.rowSpacing = ones(trajectory_figProps.m-1,1) * 1;

trajectory_figProps.width = 20 * 2.54;
trajectory_figProps.height = 12 * 2.54;

trajectory_figProps.topMargin = 5;
trajectory_figProps.leftMargin = 2.54;

% trajectory_timeLimits = [-0.5,2];

% 2D trajectories for individual trials in direct and mirror views
trajectory2d_figProps.m = 8;
trajectory2d_figProps.n = 6;

trajectory2d_figProps.panelWidth = ones(trajectory2d_figProps.n,1) * 7;
trajectory2d_figProps.panelHeight = ones(trajectory2d_figProps.m,1) * 2.5;

trajectory2d_figProps.colSpacing = 0.5 * [0;1;0;1;0];%ones(trajectory2d_figProps.n-1,1) * 0.5;
trajectory2d_figProps.rowSpacing = [0.25;1;0.25;1;0.25;1;0.25];

trajectory2d_figProps.width = 20 * 2.54;
trajectory2d_figProps.height = 12 * 2.54;

trajectory2d_figProps.topMargin = 5;
trajectory2d_figProps.leftMargin = 2.54;

trajectory2d_figProps.fullWidth = sum(trajectory2d_figProps.panelWidth) + ...
                                  sum(trajectory2d_figProps.colSpacing) + ...
                                  trajectory2d_figProps.leftMargin;
                              
trajectory2d_figProps.fullHeight = sum(trajectory2d_figProps.panelHeight) + ...
                                      sum(trajectory2d_figProps.rowSpacing) + ...
                                      trajectory2d_figProps.topMargin;
                                  
trajectory2d_figProps.legendBot = 0.03 + (trajectory2d_figProps.fullHeight - trajectory2d_figProps.topMargin) / trajectory2d_figProps.fullHeight;
trajectory2d_figProps.legendLeft = (trajectory2d_figProps.leftMargin + (1:3) * 1.5*trajectory2d_figProps.panelWidth(1)) / trajectory2d_figProps.fullWidth;

trajectory_timeLimits = [-0.5,2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


traj_xlim = [-30 10];
traj_ylim = [-20 60];
traj_zlim = [-20 20];

traj2D_xlim = [250 320];

bp_to_group = {{'mcp','pawdorsum'},{'pip'},{'digit'}};

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');
ratInfo = readtable(csvfname);
ratInfo = cleanUpRatTable(ratInfo);

ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 4 : numRatFolders
    
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
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    DLCstatsFolder = fullfile(ratRootFolder,[ratID '_DLCstats']);
    
    if ~exist(DLCstatsFolder,'dir')
        mkdir(DLCstatsFolder);
    end
    
    sessionDirectories = listFolders([ratID '_2*']);   % all were recorded after the year 2000
    numSessions = length(sessionDirectories);
    
    numSessionPages = 0;
    for iSession = 1 : numSessions
    
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
        
        try
            load(sessionSummaryName);
        catch
%             keyboard
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        
        matList = dir([ratID '_*_3dtrajectory.mat']);
        numTrials = length(matList);
        load(matList(1).name);
%         try
%         load(matList(1).name);
%         catch
%             keyboard
%         end
        numFrames = size(allTrajectories, 1);
        t = linspace(frameTimeLimits(1),frameTimeLimits(2), numFrames);
        all_p_direct = zeros(size(direct_p,1),size(direct_p,2),numTrials);
        all_p_mirror = zeros(size(mirror_p,1),size(mirror_p,2),numTrials);
        
        currentTrialList = zeros(trajectory_figProps.m,1);
        
%         trajectory_h_figAxis = zeros(num_bp,1);
%         trajectory_h_fig = zeros(num_bp,1);
%         trajectory_h_axes = zeros(trajectory_figProps.m,trajectory_figProps.n,3);
        pdf_baseName3D = [sessionDirectories{iSession} '_3dtrajectories_smoothed'];
        pdf_baseName2D = [sessionDirectories{iSession} '_2dtrajectories_smoothed'];

        
           
    end
    
end