% script_collectRatSummaries_by_experiment

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
rootAnalysisFolder = '/Volumes/LL EXHD #2/SR opto analysis';
ratSummaryDir = fullfile('/Volumes/LL EXHD #2/','rat kinematic summaries');
if ~exist(ratSummaryDir,'dir')
    mkdir(ratSummaryDir)
end
% [plotsDir,~,~] = fileparts(labeledBodypartsFolder);
% plotsDir = fullfile(plotsDir,'DLC output plots');
% if ~exist(plotsDir,'dir')
%     mkdir(plotsDir);
% end

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');
ratInfo = readRatInfoTable(csvfname);

experimentInfo = getExperimentFeatures();
sessions_to_analyze = getSessionsToAnalyze();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i_expt = 1 : 4%length(experimentInfo)
    
    curRatList = getExptRats(ratInfo,experimentInfo(i_expt));
    
    if i_expt == 1
        % workaround for now to exclude R0185
        curRatList = curRatList(2:end,:);
    end
    if i_expt == 2
        % workaround for now to exclude R0230 until completed
        curRatList = curRatList(1:9,:);
    end
    if i_expt == 4
        % workaround for now to exclude rats that haven't been completed
        curRatList = curRatList([2,4,5,6,7,9],:);
    end
    
    % plots to make:
    %   1. plot all mean x,y,z-endpoints per session and overall mean
    %   2. plot all mean end apertures per session and overall mean
    %   3. plot all mean orientations per session and overall mean. should
    %       probably reflect the angles for left-pawed rats
    
    
    ratIDs = [curRatList.ratID];
    numRats = length(ratIDs);
%     sessionTables = cell(numRats,1);   % load in full session tables into this cell array
%     sessions_for_analysis = cell(numRats,1);   % just the sessions to analyze for this particular analysis
    for i_rat = 1 : numRats
        
        % load session info for this rat
        cd(ratSummaryDir);
        ratIDstring = sprintf('R%04d',ratIDs(i_rat));
        ratSummaryName = [ratIDstring '_kinematicsSummary.mat'];
        summary(i_rat) = load(ratSummaryName);

    end
    cur_summary = summarizeKinematicsAcrossSessionsByExperiment(summary);
    cur_summary.experimentInfo = experimentInfo(i_expt);
    
    exptSummary(i_expt) = cur_summary;
    
%     h_fig = plotExptSummary(exptSummary(i_expt));
%     
%     summary_pdf_name = [experimentInfo(i_expt).type '_summary.pdf'];
%     summary_fig_name = [experimentInfo(i_expt).type '_summary.fig'];
%     summary_pdf_name = fullfile(ratSummaryDir,summary_pdf_name);
%     summary_fig_name = fullfile(ratSummaryDir,summary_fig_name);
%     
%     savefig(h_fig,summary_fig_name);
%     print(h_fig,summary_pdf_name,'-dpdf');
%     close(h_fig);
    
    
    clear summary
    
    
end
cd(ratSummaryDir)
save('experiment_summaries.mat','exptSummary')
    
    