% script_allRatSummaries

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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOOK AT THIS - HOW IS REACH DURATION CALCULATED? CHECK RAT 191,
        % LASER SESSIONS 4-10
        numReachingFrames{i_rat}(iSession).postSlot = all_endPtFrame - all_paw_through_slot_frame;
        numReachingFrames{i_rat}(iSession).preSlot = all_paw_through_slot_frame - all_firstPawDorsumFrame;
        numReachingFrames{i_rat}(iSession).total = all_endPtFrame - all_firstPawDorsumFrame;
        
        PL_summary{i_rat}(iSession) = collectTrajectoryLengths(trajectoryLengths);
            
    end
    
end

%%
[h_figs] = plotOverallSummaryFigs(ratInfo, meanOrientations,mean_MRL,endApertures,mean_dig_trajectories,mean_pd_trajectories,first_reachEndPoints,experimentType,sessionType,summariesFolder);

for ii = 1 : 3
    fname = sprintf('meanExtents_%d.pdf',ii);
    fname = fullfile(summariesFolder, fname);
    print(h_figs(ii),fname,'-dpdf','-r300');
end
%     plotOverallSummaryFigs(
%%
alternateSessions = {'R0197_20171213','R0197_20171220','R0216_20180301','R0216_20180307','R0217_20180303','R0217_20180307','R0218_20180302'};

alternate_endPoints = cell(length(alternateSessions),1);
for i_altSession = 1 : length(alternateSessions)
    ratID = alternateSessions{i_altSession}(1:5);
    i_ratFolder = find(strcmp(ratFolders,ratID));
    currentDate = alternateSessions{i_altSession}(7:14);
    iDate = datetime(currentDate,'InputFormat','yyyyMMdd');
    
    for ii = 1 : length(sessionDates{i_ratFolder})
        dateList(ii) = datetime(sessionDates{i_ratFolder}{ii});
    end

    i_session = find(dateList==iDate);
    
    temp = first_reachEndPoints{i_ratFolder}{i_session}{1};
    
    alternate_endPoints{i_altSession} = squeeze(temp(10,3,:));
end

%%
close all
onData = cell(length(alternate_endPoints),1);
offData = cell(length(alternate_endPoints),1);

onColor = 'b';
offColor = 'r';
markSize = 50;
ylimits = [-20 20];
y_meanlimits = [-10 5];
y_medianlimits = [-10 10];
sessionMean_on = zeros(length(alternate_endPoints),5);
sessionMean_off = zeros(length(alternate_endPoints),5);
sessionMedian_on = zeros(length(alternate_endPoints),5);
sessionMedian_off = zeros(length(alternate_endPoints),5);

onPatch_X = [0.5 5.5 5.5 0.5;10.5 15.5 15.5 10.5]';
onPatch_Y = [y_meanlimits(1) y_meanlimits(1) y_meanlimits(2) y_meanlimits(2);y_meanlimits(1) y_meanlimits(1) y_meanlimits(2) y_meanlimits(2)]';
patchAlpha = 0.1;

labelfontsize = 24;
ticklabelfontsize = 18;

for ii = 1 : length(alternate_endPoints)
    [onData{ii},offData{ii}] = extractAlternatingTrials(alternate_endPoints{ii});
    figure(ii)
    set(gcf,'name',alternateSessions{ii})
    subplot(3,1,1)
    for jj = 1 : size(onData{ii},1)
        scatter(1:5,onData{ii}(jj,:));
        hold on
    end
    for jj = 1 : size(offData{ii},1)
        scatter(6:10,offData{ii}(jj,:));
        hold on
    end
    set(gca,'ylim',ylimits);
    
    sessionMean_on(ii,:) = nanmean(onData{ii});
    sessionMean_off(ii,:) = nanmean(offData{ii});
    
    sessionMedian_on(ii,:) = nanmedian(onData{ii});
    sessionMedian_off(ii,:) = nanmedian(offData{ii});
    
    subplot(3,1,2)
    scatter(1:5,sessionMean_on(ii,:),markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
    hold on
    scatter(6:10,sessionMean_off(ii,:),markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);
    set(gca,'ylim',ylimits);
    
    subplot(3,1,3)
    scatter(1:5,sessionMedian_on(ii,:),markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
    hold on
    scatter(6:10,sessionMedian_off(ii,:),markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);
    set(gca,'ylim',ylimits);
end

h_fig = figure;
sessionsMean_on = nanmean(sessionMean_on);
sessionsMean_off = nanmean(sessionMean_off);

sessions_std_on = nanstd(sessionMean_on);
sessions_std_off = nanstd(sessionMean_off);
scatter(1:5,sessionsMean_on,markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
hold on
scatter(11:15,sessionsMean_on,markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
scatter(6:10,sessionsMean_off,markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);
scatter(16:20,sessionsMean_off,markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);
line([0,20],[0,0],'color','k')
patch(onPatch_X,onPatch_Y,'b','facealpha',patchAlpha);
set(gcf,'name','mean');
xticks([1,5,6,10,11,15,20]);
xticklabels([1,5,1,5,1,5,1,5])
set(gca,'ylim',y_meanlimits,'fontsize',ticklabelfontsize);
ylabel('reach extent (mm)','fontsize',labelfontsize);
xlabel('trial number in block','fontsize',labelfontsize);


fname = 'alternating_extents.pdf';
fname = fullfile(summariesFolder, fname);
print(h_fig,fname,'-dpdf','-r300');


figure;
sessionsMedian_on = nanmedian(sessionMedian_on);
sessionsMedian_off = nanmedian(sessionMedian_off);
scatter(1:5,sessionsMedian_on,markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
hold on
scatter(11:15,sessionsMedian_on,markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);
scatter(6:10,sessionsMedian_off,markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);
scatter(16:20,sessionsMedian_off,markSize,'markeredgecolor',offColor,'markerfacecolor',offColor);

patch(onPatch_X,onPatch_Y,'b','facealpha',patchAlpha);
set(gcf,'name','median');
set(gca,'ylim',y_medianlimits);

%%
firstDuringStimSessions = {'R0186_20170815','R0187_20170918','R0189_20170924','R0191_20170918','R0193_20171002','R0195_20171001','R0197_20171211','R0216_20180227','R0217_20180228','R0218_20180228'};
duringStim_endPoints = cell(length(alternateSessions),1);
for i_firstStimSession = 1 : length(firstDuringStimSessions)
    ratID = firstDuringStimSessions{i_firstStimSession}(1:5);
    i_ratFolder = find(strcmp(ratFolders,ratID));
    currentDate = firstDuringStimSessions{i_firstStimSession}(7:14);
    iDate = datetime(currentDate,'InputFormat','yyyyMMdd');
    
    for ii = 1 : length(sessionDates{i_ratFolder})
        dateList(ii) = datetime(sessionDates{i_ratFolder}{ii});
    end

    i_session = find(dateList==iDate);
    
    temp = first_reachEndPoints{i_ratFolder}{i_session}{1};
    
    duringStim_endPoints{i_firstStimSession} = squeeze(temp(10,3,:));
end

%%
figure(1)
subplot(1,1,1);
hold off
maxLength = 0;
for ii = 1 : length(duringStim_endPoints)
    maxLength = max(maxLength,length(duringStim_endPoints{ii}));
end
all_firstDuringEndPoints = NaN(length(duringStim_endPoints),maxLength);
for ii = 1 : length(duringStim_endPoints)
    figure(ii+9)
    subplot(1,1,1);
    hold off
    numTrials = length(duringStim_endPoints{ii});
    scatter(1:numTrials,duringStim_endPoints{ii})
    all_firstDuringEndPoints(ii,1:numTrials) = duringStim_endPoints{ii};
    hold on
    set(gcf,'name',firstDuringStimSessions{ii})
end

%%
lastPt = 50;
h_fig = figure(length(duringStim_endPoints)+10);
hold off
scatter(1:lastPt,nanmean(all_firstDuringEndPoints(:,1:lastPt)),markSize,'markeredgecolor',onColor,'markerfacecolor',onColor);

line([0,lastPt],[0,0],'color','k')

xtickValues = [1 10 20 30 40 50];
xticks(xtickValues);
xticklabels(xtickValues)
set(gca,'ylim',y_meanlimits,'fontsize',ticklabelfontsize);
ylabel('reach extent (mm)','fontsize',labelfontsize);
xlabel('trial number','fontsize',labelfontsize);

fname = 'firstLaserExtents.pdf';
fname = fullfile(summariesFolder, fname);
print(h_fig,fname,'-dpdf','-r300');

    %%
q=first_reachEndPoints{i_ratFolder}{i_session}{1};
q10 = squeeze(q(10,:,:))';




    [ratSummary_h_fig, ratSummary_h_axes,ratSummary_h_figAxis] = plotRatSummaryFigs(ratID,sessionDates,allSessionDates,sessionType,bodyparts,bodypart_to_plot,...
        mean_pd_trajectories,mean_xyz_from_pd_trajectories,first_reachEndPoints,mean_euc_dist_from_pd_trajectories,distFromPellet,paw_endAngle,meanOrientations,mean_MRL,...
        endApertures,meanApertures,varApertures,numReachingFrames,PL_summary,thisRatInfo);

    pdfName_ratSummary = sprintf('%s_trajectories_summary.pdf',ratID);
    pdfName_ratSummary = fullfile(ratRootFolder,pdfName_ratSummary);
    figName_ratSummary = sprintf('%s_trajectories_summary.fig',ratID);
    figName_ratSummary = fullfile(ratRootFolder,figName_ratSummary);
    savefig(ratSummary_h_fig,figName_ratSummary);
    print(ratSummary_h_fig,pdfName_ratSummary,'-dpdf');
    close(ratSummary_h_fig);
    
