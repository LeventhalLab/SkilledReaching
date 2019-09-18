% script_collectRatSummaries_by_experiment
% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
[plotsDir,~,~] = fileparts(labeledBodypartsFolder);
plotsDir = fullfile(plotsDir,'DLC output plots');
if ~exist(plotsDir,'dir')
    mkdir(plotsDir);
end

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

experimentInfo = getExperimentFeatures();
sessions_to_analyze = getSessionsToAnalyze();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the figures for each type of plot
% kinematics summaries for each experiment type
exptSummary_figProps.m = 5;
exptSummary_figProps.n = 4;

exptSummary_figProps.panelWidth = ones(exptSummary_figProps.n,1) * 10;
exptSummary_figProps.panelHeight = ones(exptSummary_figProps.m,1) * 4;

exptSummary_figProps.colSpacing = ones(exptSummary_figProps.n-1,1) * 0.5;
exptSummary_figProps.rowSpacing = ones(exptSummary_figProps.m-1,1) * 1;

exptSummary_figProps.width = 20 * 2.54;
exptSummary_figProps.height = 12 * 2.54;

exptSummary_figProps.topMargin = 5;
exptSummary_figProps.leftMargin = 2.54;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i_expt = 1 : length(experimentInfo)
    
    curRatList = getExptRats(ratInfo,experimentInfo(i_expt));
    
    if i_expt == 1
        % workaround for now to exclude R0185
        curRatList = curRatList(2:end,:);
    end
    % plots to make:
    %   1. plot all mean x,y,z-endpoints per session and overall mean
    %   2. plot all mean end apertures per session and overall mean
    %   3. plot all mean orientations per session and overall mean. should
    %       probably reflect the angles for left-pawed rats
    
    
    ratIDs = [curRatList.ratID];
    numRats = length(ratIDs);
    sessionTables = cell(numRats,1);   % load in full session tables into this cell array
    sessions_for_analysis = cell(numRats,1);   % just the sessions to analyze for this particular analysis
    for i_rat = 1 : numRats
        
        % load session info for this rat
        ratIDstring = sprintf('R%04d',ratIDs(i_rat));
        ratFolder = fullfile(labeledBodypartsFolder,ratIDstring);
        if ~exist(ratFolder,'dir')
            continue;
        end
        cd(ratFolder);
        sessionCSV = [ratIDstring '_sessions.csv'];
        sessionTables{i_rat} = readSessionInfoTable(sessionCSV);
        
        sessions_for_analysis{i_rat} = extractSpecificSessions(sessionTables{i_rat},sessions_to_analyze);
    end
    experimentSummary = collectDataAcrossRats(curRatList,sessions_for_analysis);
    
end
    
    