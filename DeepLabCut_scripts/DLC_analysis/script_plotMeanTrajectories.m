% script_plotMeanTrajectories

% R0219, 20180314a, VID #69 IS MISSING FRAMES - NEEDS TO BE RE-CLIPPED AND
% RUN THROUGH DLC

% CONSIDER EXCLUDING ANY TRIALS WHERE Z < 40 AT THE START OF THE TRIAL (PAW
% MAY ALREADY BE AT THE SLOT - MISSED TRIGGER)

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

trialTypeColors = {'k','k','b','r','g'};
validTrialTypes = {0:11,0,1,2,[3,4,7]};
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

% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
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
    
%     ratID = ratFolders{i_rat};
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
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
             
        try
            load(sessionSummaryName);
        catch
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        
        pawPref = thisRatInfo.pawPref;
        if iscell(pawPref)
            pawPref = pawPref{1};
        end
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
        
        [first_reachEndPoints{iSession},distFromPellet{iSession}] = collectFirstReachEndPoints(all_endPts,validTrialTypes,all_trialOutcomes);
        [all_reachEndPoints{iSession},numReaches_byPart{iSession},numReaches{iSession},reachFrames{iSession},reach_endPoints{iSession}] = ...
            collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,validTrialTypes,all_trialOutcomes,digIdx);

        
        trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
        for iType = 1 : numTrialTypes_to_analyze
            trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
        end
        matList = dir([ratID '_*_3dtrajectory_new.mat']);

        numTrials = size(allTrajectories,4);
        numTrialsPerSession(iSession) = numTrials;
        numFrames = size(allTrajectories, 1);
        t = linspace(frameTimeLimits(1),frameTimeLimits(2), numFrames);
        
        pdf_baseName_indTrials = [sessionDirectories{iSession} '_singleTrials_normalized'];

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

        numSessionsCalculated = numSessionsCalculated + 1;
        if numSessionsCalculated == 1
            mean_pd_trajectories = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),size(mean_pd_trajectory,3),numSessions);
            mean_xyz_from_pd_trajectories = zeros(size(mean_xyz_from_pd_trajectory,1),size(mean_xyz_from_pd_trajectory,2),size(mean_xyz_from_pd_trajectory,3),numSessions);
            mean_euc_dist_from_pd_trajectories = zeros(size(mean_euc_dist_from_pd_trajectory,1),size(mean_euc_dist_from_pd_trajectory,2),numSessions);
            
            mean_dig_trajectories = zeros(size(mean_session_digit_trajectories,1),size(mean_session_digit_trajectories,2),size(mean_session_digit_trajectories,3),size(mean_session_digit_trajectories,4),numSessions);
            mean_xyz_from_dig_trajectories = zeros(size(mean_xyz_from_dig_session_trajectories,1),size(mean_xyz_from_dig_session_trajectories,2),size(mean_xyz_from_dig_session_trajectories,3),size(mean_xyz_from_dig_session_trajectories,4),numSessions);
            mean_euc_dist_from_dig_trajectories = zeros(size(mean_euc_from_dig_session_trajectories,1),size(mean_euc_from_dig_session_trajectories,2),size(mean_euc_from_dig_session_trajectories,3),numSessions);
        end
        mean_pd_trajectories(:,:,:,iSession) = mean_pd_trajectory;
        mean_xyz_from_pd_trajectories(:,:,:,iSession) = mean_xyz_from_pd_trajectory;
        mean_euc_dist_from_pd_trajectories(:,:,iSession) = mean_euc_dist_from_pd_trajectory;
        
        mean_dig_trajectories(:,:,:,:,iSession) = mean_session_digit_trajectories;
        mean_xyz_from_dig_trajectories(:,:,:,:,iSession) = mean_xyz_from_dig_session_trajectories;
        mean_euc_dist_from_dig_trajectories(:,:,:,iSession) = mean_euc_from_dig_session_trajectories;
        
        all_reachStartFrames = getFirstReachStartFrames(allTrajectories,bodyparts,pawPref,all_endPtFrame,slot_z,all_initPellet3D);
        
        [paw_endAngle{iSession},pawOrientationTrajectories{iSession}] = collectPawOrientations(all_pawAngle,all_reachStartFrames,all_endPtFrame);
        [meanOrientations{iSession},mean_MRL{iSession}] = summarizePawOrientations(pawOrientationTrajectories{iSession});
        [endApertures{iSession},apertureTrajectories{iSession}] = collectApertures(all_aperture,all_reachStartFrames,all_endPtFrame);
        [meanApertures{iSession},varApertures{iSession}] = summarizeApertures(apertureTrajectories{iSession});
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOOK AT THIS - HOW IS REACH DURATION CALCULATED? CHECK RAT 191,
        % LASER SESSIONS 4-10
        numReachingFrames(iSession).postSlot = all_endPtFrame - all_paw_through_slot_frame;
        numReachingFrames(iSession).preSlot = all_paw_through_slot_frame - all_firstPawDorsumFrame;
        numReachingFrames(iSession).total = all_endPtFrame - all_firstPawDorsumFrame;
        
        PL_summary(iSession) = collectTrajectoryLengths(trajectoryLengths);
        
        if ~skipSessionSummaryPlots
            [h_summaryFigs,h_summaryAxes,h_summary_figAxis] = plotSessionSummary(trialTypeIdx,mean_euc_dist_from_pd_trajectory,mean_xyz_from_pd_trajectory,first_reachEndPoints{iSession},bodyparts,thisRatInfo,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,all_maxDigitReachFrame,validTypeNames,sessionDirectories{iSession},sessionType(allSessionIdx),...
                'var_lim',var_lim,'pawframelim',pawFrameLim);
            [h_digitSummaryFigs,h_digitSummaryAxes,h_digitSummary_figAxis] = plotSessionDigitSummary(trialTypeIdx,paw_endAngle{iSession},mean_session_digit_trajectories,pawOrientationTrajectories{iSession},meanOrientations{iSession},mean_MRL{iSession},apertureTrajectories{iSession},endApertures{iSession},meanApertures{iSession},varApertures{iSession},mean_xyz_from_dig_session_trajectories,mean_euc_from_dig_session_trajectories,bodyparts,pawPref,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,validTypeNames,sessionDirectories{iSession},sessionType(allSessionIdx),thisRatInfo,'x_lim',x_lim,'y_lim',y_lim,'z_lim',z_lim);
            [session_h_fig,session_h_axes,session_h_figAxis] = plotSessionSummary_b(mean_pd_trajectory,normalized_pd_trajectories,trialTypeIdx,...
                sessionDirectories{iSession},sessionType(allSessionIdx),validTypeNames,thisRatInfo,'x_lim',x_lim,'y_lim',y_lim,'z_lim',z_lim);
            [h_multiReachFig,h_multiReachAxes,h_multiReachFigAxis] = ...
                plot_multiReachInfo(reachFrames{iSession},reach_endPoints{iSession},bodyparts,thisRatInfo,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,all_maxDigitReachFrame,trialTypeIdx,validTypeNames,sessionDirectories{iSession},sessionType(allSessionIdx),trialTypeColors);

            pdfName_sessionTrials = sprintf('%s_3dtrajectories_summary.pdf',sessionDirectories{iSession});
            figName_sessionTrials = sprintf('%s_3dtrajectories_summary.fig',sessionDirectories{iSession});
            pdfName_sessionTrials = fullfile(sessionDir_pdf,pdfName_sessionTrials);
            figName_sessionTrials = fullfile(sessionDir_fig,figName_sessionTrials);
            print(session_h_fig,pdfName_sessionTrials,'-dpdf');
            savefig(session_h_fig,figName_sessionTrials);
            close(session_h_fig);

            pdfName_sessionSummary = sprintf('%s_summary.pdf',sessionDirectories{iSession});
            pdfName_sessionSummary = fullfile(sessionDir_pdf,pdfName_sessionSummary);
            figName_sessionSummary = sprintf('%s_summary.fig',sessionDirectories{iSession});
            figName_sessionSummary = fullfile(sessionDir_fig,figName_sessionSummary);
            print(h_summaryFigs(1),pdfName_sessionSummary,'-dpdf');
            savefig(h_summaryFigs(1),figName_sessionSummary);
            close(h_summaryFigs(1));

            pdfName_sessionDigitSummary = sprintf('%s_digits_summary.pdf',sessionDirectories{iSession});
            pdfName_sessionDigitSummary = fullfile(sessionDir_pdf,pdfName_sessionDigitSummary);
            figName_sessionDigitSummary = sprintf('%s_digits_summary.fig',sessionDirectories{iSession});
            figName_sessionDigitSummary = fullfile(sessionDir_fig,figName_sessionDigitSummary);
            print(h_digitSummaryFigs(1),pdfName_sessionDigitSummary,'-dpdf');
            savefig(h_digitSummaryFigs(1),figName_sessionDigitSummary);
            close(h_digitSummaryFigs(1)); 
            
            pdfName_multiReachSummary = sprintf('%s_multiReach_summary.pdf',sessionDirectories{iSession});
            pdfName_multiReachSummary = fullfile(sessionDir_pdf,pdfName_multiReachSummary);
            figName_multiReachSummary = sprintf('%s_multiReach_summary.fig',sessionDirectories{iSession});
            figName_multiReachSummary = fullfile(sessionDir_fig,figName_multiReachSummary);
            print(h_multiReachFig,pdfName_multiReachSummary,'-dpdf');
            savefig(h_multiReachFig,figName_multiReachSummary);
            close(h_multiReachFig); 
        end
            
if ~skipTrialPlots
        for iTrial = 1 : numTrials
            
%             load(matList(iTrial).name);
            [trial_rowNum, numTrialPages] = getRow(iTrial, trajectory_figProps.m);
            if trial_rowNum == 1
                [trajectory_h_fig,trajectory_h_axes] = createFigPanels5(trajectory_figProps);
                trajectory_h_figAxis = createFigAxes(trajectory_h_fig);
                currentTrialList = zeros(trajectory_figProps.m,1);
%                 [trajectory2d_h_fig,trajectory2d_h_axes] = createFigPanels5(trajectory2d_figProps);
%                 trajectory2d_h_figAxis = createFigAxes(trajectory2d_h_fig);
            end
                
            num_bp = size(allTrajectories,3);
            
            currentTrialList(trial_rowNum) = trialNumbers(iTrial,1);
            curTrajectories = squeeze(allTrajectories(:,:,:,iTrial));
            cur_normalized_trajectory = squeeze(normalized_pd_trajectories(:,:,iTrial));
            
            firstPt = all_firstPawDorsumFrame(iTrial);
            lastPt = all_endPtFrame(iTrial);
            
            for iType = 2 : numTrialTypes_to_analyze
                if trialTypeIdx(iTrial,iType)
                    plotColor = trialTypeColors{iType};
                    break;
                else
                    plotColor = 'y';   % if not one of the trials we defined at the top of the script
                end
            end
                        
            for iDim = 1 : 3
                axes(trajectory_h_axes(trial_rowNum,iDim))
                plot(cur_normalized_trajectory(:,iDim),'color',plotColor);
                hold on
                plot(mean_pd_trajectory(:,iDim),'linewidth',2,'color','k');
                if trial_rowNum == 1
                    switch iDim
                        case 1
                            title('x')
                        case 2
                            title('y')
                        case 3
                            title('z')
                    end
                end
                switch iDim
                    case 1
                        set(gca,'ylim',x_lim)
                    case 2
                        set(gca,'ylim',y_lim,'ydir','reverse')
                    case 3
                        set(gca,'ylim',z_lim)
                end
            end
            axes(trajectory_h_axes(trial_rowNum,4))
            plot3(cur_normalized_trajectory(:,1),cur_normalized_trajectory(:,3),cur_normalized_trajectory(:,2),'color',plotColor);
            hold on
            plot3(mean_pd_trajectory(:,1,1),mean_pd_trajectory(:,3,1),mean_pd_trajectory(:,2,1),'linewidth',2,'color','k');
            scatter3(0,0,0,25,'k','o','markerfacecolor','k')
            set(gca,'zdir','reverse','xlim',x_lim,'ylim',z_lim,'zlim',y_lim,...
                'view',[-70,30])
            xlabel('x');ylabel('z');zlabel('y');
            
            if (trial_rowNum == trajectory_figProps.m)|| iTrial == numTrials
                textString{1} = sprintf('%s individual trial 3D trajectories; %s, day %d, %d days left in block, Virus: %s', ...
                    sessionDirectories{iSession}, sessionType(allSessionIdx).type, sessionType(allSessionIdx).sessionsInBlock, sessionType(allSessionIdx).sessionsLeftInBlock,virus);
                textString{2} = sprintf('trial numbers: %d', currentTrialList(1));
                for ii = 2 : length(currentTrialList)
                    textString{2} = sprintf('%s, %d', textString{2}, currentTrialList(ii));
                end
                textString{3} = sprintf('color indicators: %s - %s',trialTypeColors{1},validTypeNames{1});
                for ii = 2 : length(trialTypeColors)
                    textString{3} = sprintf('%s, %s - %s', textString{3},trialTypeColors{ii},validTypeNames{ii});
                end
                axes(trajectory_h_figAxis);
                text(trajectory_figProps.leftMargin,trajectory_figProps.height-0.75,textString,'units','centimeters','interpreter','none');
                pdfName_indTrials = sprintf('%s_%02d.pdf',pdf_baseName_indTrials,numTrialPages);
                pdfName_indTrials = fullfile(sessionDir_pdf,pdfName_indTrials);
                print(trajectory_h_fig,pdfName_indTrials,'-dpdf');
                close(trajectory_h_fig);
            end
        end
        
end
            
    end
    

    [ratSummary_h_fig, ratSummary_h_axes,ratSummary_h_figAxis] = plotRatSummaryFigs(ratID,sessionDates,allSessionDates,sessionType,bodyparts,bodypart_to_plot,...
        mean_pd_trajectories,mean_xyz_from_pd_trajectories,first_reachEndPoints,mean_euc_dist_from_pd_trajectories,distFromPellet,paw_endAngle,meanOrientations,mean_MRL,...
        endApertures,meanApertures,varApertures,numReachingFrames,PL_summary,numTrialsPerSession,thisRatInfo);

    pdfName_ratSummary = sprintf('%s_trajectories_summary.pdf',ratID);
    pdfName_ratSummary = fullfile(plotsDir,'pdf',ratID,pdfName_ratSummary);
    figName_ratSummary = sprintf('%s_trajectories_summary.fig',ratID);
    figName_ratSummary = fullfile(plotsDir,'fig',ratID,figName_ratSummary);
    savefig(ratSummary_h_fig,figName_ratSummary);
    print(ratSummary_h_fig,pdfName_ratSummary,'-dpdf');
    close(ratSummary_h_fig);
    
end