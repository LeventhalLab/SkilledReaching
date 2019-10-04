% script_plotSessionReachSummaries

ratList = {'R0158','R0159','R0160','R0161','R0169','R0170','R0171','R0183',...
           'R0184','R0186','R0187','R0189','R0190',...
           'R0191','R0192','R0193','R0194','R0195','R0196','R0197','R0198',...
           'R0216','R0217','R0218','R0219','R0220','R0223','R0225','R0227',...
           'R0228'};
numRats = length(ratList);

firstRat = 29;
lastRat = 30;

x_lim = [-30 10];
y_lim = [-20 10];
z_lim = [-5 50];

var_lim = [0,5;
           0,5;
           0,10;
           0,10];
pawFrameLim = [0 400];

skipTrialPlots = false;
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
% 11 - paw started out through the slot

trialTypeColors = {'k','y','b','r','g','c','m'};
validTrialTypes = {0:10,0,1,2,[3,4,7],11,6};
validTypeNames = {'all','no pellet','1st reach success','any reach success','failed reach','paw through slot','no reach'};
numTrialTypes_to_analyze = length(validTrialTypes);

bodypart_to_plot = 'digit2';


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

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
[plotsDir,~,~] = fileparts(labeledBodypartsFolder);
plotsDir = fullfile(plotsDir,'DLC output plots');
if ~exist(plotsDir,'dir')
    mkdir(plotsDir);
end

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = firstRat:1:lastRat%:numRatFolders
    
    ratID = ratList{i_rat};
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
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    reachScores = readReachScores(reachScoresFile,'csvdateformat',csvDateFormat);
    allSessionDates = [reachScores.date]';
    
    cd(ratRootFolder);
    DLCstatsFolder = fullfile(ratRootFolder,[ratID '_DLCstats']);
    
    if ~exist(DLCstatsFolder,'dir')
        mkdir(DLCstatsFolder);
    end
    
    sessionDirectories = listFolders([ratID '_2*']);   % all were recorded after the year 2000
    numSessions = length(sessionDirectories);
    
    numSessionPages = 0;
    sessionType = determineSessionType(thisRatInfo, allSessionDates);
    for ii = 1 : length(sessionType)
        sessionType(ii).typeFromScoreSheet = reachScores(ii).sessionType;
    end
    
    sessionDates = cell(1,numSessions);
    paw_endAngle = cell(1,numSessions);
    pawOrientationTrajectories = cell(1,numSessions);
    meanOrientations = cell(1,numSessions);
    mean_MRL = cell(1,numSessions);
    meanApertures = cell(1,numSessions);
    varApertures = cell(1,numSessions);
    endApertures = cell(1,numSessions);
    apertureTrajectories = cell(1,numSessions);
    numTrialsPerSession = zeros(numSessions,1);
%     numReachingFrames = cell(1,numSessions);    % number of frames from first paw dorsum detection to max digit extension
    
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
        case 'R0171'
            startSession = 1;
            endSession = numSessions;
        case 'R0192'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    numSessionsCalculated = 0;
    for iSession = startSession:1:endSession
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1};
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDates{iSession} = sessionDate;
        
        allSessionIdx = find(sessionDate == allSessionDates);
        sessionReachScores = reachScores(allSessionIdx).scores;
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        sessionDir_pdf = fullfile(plotsDir,'pdf',ratID,sessionDirectories{iSession});
        if ~exist(sessionDir_pdf,'dir')
            mkdir(sessionDir_pdf);
        end
        sessionDir_fig = fullfile(plotsDir,'fig',ratID,sessionDirectories{iSession});
        cd(fullSessionDir);
        if ~exist(sessionDir_fig,'dir')
            mkdir(sessionDir_fig);
        end
        
        reachDataName = [ratID '_' sessionDateString '_processed_reaches.mat'];
        reachDataName = fullfile(fullSessionDir,reachDataName);
        
        try
            load(reachDataName);
        catch
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        
        pawPref = thisRatInfo.pawPref;
        if iscell(pawPref)
            pawPref = pawPref{1};
        end
        