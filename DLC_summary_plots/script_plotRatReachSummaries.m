% script_plotRatReachSummaries

ratList = {'R0158','R0159','R0160','R0161','R0169','R0170','R0171','R0183',...
           'R0184','R0186','R0187','R0189','R0190',...
           'R0191','R0192','R0193','R0194','R0195','R0196','R0197','R0198',...
           'R0216','R0217','R0218','R0219','R0220','R0221','R0223','R0225','R0227',...
           'R0228','R0229','R0230','R0235','R0283','R0284','R0285','R0286',...
           'R0287','R0288','R0289','R0309','R0310','R0311','R0312'};
numRats = length(ratList);

firstRat = 42;
lastRat = 45;

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

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

ratSummaryDir = fullfile('/Volumes/LL EXHD #2/','rat kinematic summaries');
ratSummaryPlotsDir = fullfile('/Volumes/LL EXHD #2/','rat kinematic summary plots');
ratSummaryPlotsDir_fig = fullfile(ratSummaryPlotsDir,'fig');
ratSummaryPlotsDir_pdf = fullfile(ratSummaryPlotsDir,'pdf');
if ~exist(ratSummaryPlotsDir_fig,'dir')
    mkdir(ratSummaryPlotsDir_fig);
end
if ~exist(ratSummaryPlotsDir_pdf,'dir')
    mkdir(ratSummaryPlotsDir_pdf);
end

ratInfo_IDs = [ratInfo.ratID];

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
    
    ratSummaryName = [ratID '_kinematicsSummary.mat'];
    full_ratSummaryName = fullfile(ratSummaryDir,ratSummaryName);

    if ~exist(full_ratSummaryName,'file')
        fprintf('%s not found\n',full_ratSummaryName);
        continue;
    end

    load(full_ratSummaryName);
        
    h_fig = plotRatReachSummaries(ratSummary, thisRatInfo);
        
    figName_ratSummary = [ratID '_kinematicsSummary.fig'];
    pdfName_ratSummary = [ratID '_kinematicsSummary.pdf'];
    
    figName_ratSummary = fullfile(ratSummaryPlotsDir_fig,figName_ratSummary);
    pdfName_ratSummary = fullfile(ratSummaryPlotsDir_pdf,pdfName_ratSummary);
    
    savefig(h_fig,figName_ratSummary);
    print(h_fig,pdfName_ratSummary,'-dpdf');
    close(h_fig);
    
end
    
        