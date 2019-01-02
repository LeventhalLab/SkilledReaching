% script_summaryDLCstatistics
x_lim = [-30 10];
y_lim = [-15 10];
z_lim = [-5 50];

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

% trajectory_timeLimits = [-0.5,2];

% 2D trajectories for individual trials in direct and mirror views
% trajectory2d_figProps.m = 8;
% trajectory2d_figProps.n = 6;
% 
% trajectory2d_figProps.panelWidth = ones(trajectory2d_figProps.n,1) * 7;
% trajectory2d_figProps.panelHeight = ones(trajectory2d_figProps.m,1) * 2.5;
% 
% trajectory2d_figProps.colSpacing = 0.5 * [0;1;0;1;0];%ones(trajectory2d_figProps.n-1,1) * 0.5;
% trajectory2d_figProps.rowSpacing = [0.25;1;0.25;1;0.25;1;0.25];
% 
% trajectory2d_figProps.width = 20 * 2.54;
% trajectory2d_figProps.height = 12 * 2.54;
% 
% trajectory2d_figProps.topMargin = 5;
% trajectory2d_figProps.leftMargin = 2.54;
% 
% trajectory2d_figProps.fullWidth = sum(trajectory2d_figProps.panelWidth) + ...
%                                   sum(trajectory2d_figProps.colSpacing) + ...
%                                   trajectory2d_figProps.leftMargin;
%                               
% trajectory2d_figProps.fullHeight = sum(trajectory2d_figProps.panelHeight) + ...
%                                       sum(trajectory2d_figProps.rowSpacing) + ...
%                                       trajectory2d_figProps.topMargin;
%                                   
% trajectory2d_figProps.legendBot = 0.03 + (trajectory2d_figProps.fullHeight - trajectory2d_figProps.topMargin) / trajectory2d_figProps.fullHeight;
% trajectory2d_figProps.legendLeft = (trajectory2d_figProps.leftMargin + (1:3) * 1.5*trajectory2d_figProps.panelWidth(1)) / trajectory2d_figProps.fullWidth;

% trajectory_timeLimits = [-0.5,2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


traj_xlim = [-30 10];
traj_ylim = [-20 60];
traj_zlim = [-20 20];

traj2D_xlim = [250 320];

bp_to_group = {{'mcp','pawdorsum'},{'pip'},{'digit'}};

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');
ratInfo = readRatInfoTable(csvfname);

ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 4 : 5%numRatFolders
    
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
%     pdf_baseName_sessionTrials = [ratID '_3dtrajectories_smoothed'];
    for iSession = 1 : numSessions
        
%         [session_rowNum, numSessionPages] = getRow(iSession, trajectory_figProps.m);
%         if session_rowNum == 1
            [session_h_fig,session_h_axes] = createFigPanels5(trajectory_figProps);
            session_h_figAxis = createFigAxes(session_h_fig);
            currentSessionList = {};
%         end
        currentSessionList{session_rowNum} = sessionDirectories{iSession};
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1};
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        
        sessionType = determineSessionType(thisRatInfo, sessionDate);
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
             
        try
            load(sessionSummaryName);
        catch
%             keyboard
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        
        pawPref = thisRatInfo.pawPref;
        if iscell(pawPref)
            pawPref = pawPref{1};
        end
        
        trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
        for iType = 1 : numTrialTypes_to_analyze
            trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
        end
        matList = dir([ratID '_*_3dtrajectory.mat']);
%         numTrials = length(matList);
        numTrials = size(allTrajectories,4);
%         load(matList(1).name);
%         try
%         load(matList(1).name);
%         catch
%             keyboard
%         end
        numFrames = size(allTrajectories, 1);
        t = linspace(frameTimeLimits(1),frameTimeLimits(2), numFrames);
        all_p_direct = zeros(size(direct_p,1),size(direct_p,2),numTrials);
        all_p_mirror = zeros(size(mirror_p,1),size(mirror_p,2),numTrials);
        
%         trajectory_h_figAxis = zeros(num_bp,1);
%         trajectory_h_fig = zeros(num_bp,1);
%         trajectory_h_axes = zeros(trajectory_figProps.m,trajectory_figProps.n,3);
        
        pdf_baseName_indTrials = [sessionDirectories{iSession} '_singleTrials_normalized'];

        [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref);

        mean_pd_trajectory = zeros(size(normalized_pd_trajectories,1),size(normalized_pd_trajectories,2),numTrialTypes_to_analyze);
        for iType = 1 : numTrialTypes_to_analyze
            mean_pd_trajectory(:,:,iType) = mean(normalized_pd_trajectories(:,:,trialTypeIdx(:,iType)),3);
        end
        if iSession == 1
            mean_pd_trajectories = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),size(mean_pd_trajectory,3),numSessions);
        end
        mean_pd_trajectories(:,:,:,iSession) = mean_pd_trajectory;
        
        for iType = 1 : numTrialTypes_to_analyze
            for iDim = 1 : 3
                axes(session_h_axes(iType,iDim))
                plot(mean_pd_trajectory(:,iDim,iType),'linewidth',2,'color','k');
                hold on
                for iTrial = 1 : numTrials
                    if trialTypeIdx(iTrial,iType)
                        plot(normalized_pd_trajectories(:,iDim,iTrial));
                    end
                end
                if session_rowNum == 1
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

            axes(session_h_axes(iType,4))
            plot3(mean_pd_trajectory(:,1,iType),mean_pd_trajectory(:,3,iType),mean_pd_trajectory(:,2,iType),'linewidth',2,'color','k');
            hold on
            for iTrial = 1 : numTrials
                if trialTypeIdx(iTrial,iType)
                    plot3(normalized_pd_trajectories(:,1,iTrial),normalized_pd_trajectories(:,3,iTrial),normalized_pd_trajectories(:,2,iTrial))
                end
            end

            scatter3(0,0,0,25,'k','o','markerfacecolor','k')
            set(gca,'zdir','reverse','xlim',x_lim,'ylim',z_lim,'zlim',y_lim,...
                'view',[-70,30])
            xlabel('x');ylabel('z');zlabel('y');
        end
            textString = {};
%         if (session_rowNum == trajectory_figProps.m) || iSession == numSessions
try
            textString{1} = sprintf('%s all trial 3D trajectories; %s, day %d, %d days left in block', ...
                sessionDirectories{iSession}, sessionType.type, sessionType.daysInBlock, sessionType.daysUntilBlockEnd);
catch
    keyboard
end
            textString{2} = sprintf('trial types: %s', validTypeNames{1});
            for ii = 2 : length(validTypeNames)
                textString{2} = sprintf('%s, %s', textString{2}, validTypeNames{ii});
            end
            axes(session_h_figAxis);
            text(trajectory_figProps.leftMargin,trajectory_figProps.height-0.5,textString,'units','centimeters','interpreter','none');
%             pdfName_sessionTrials = sprintf('%s_%02d.pdf',pdf_baseName_sessionTrials,iSession);
            pdfName_sessionTrials = sprintf('%s_3dtrajectories_summary.pdf',sessionDirectories{iSession});
            pdfName_sessionTrials = fullfile(ratRootFolder,pdfName_sessionTrials);
            print(session_h_fig,pdfName_sessionTrials,'-dpdf');
            close(session_h_fig);
%         end
            
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
            
            currentTrialList(trial_rowNum) = trialNumbers(iTrial);
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
                textString{1} = sprintf('%s individual trial 3D trajectories; %s, day %d, %d days left in block', ...
                    sessionDirectories{iSession}, sessionType.type, sessionType.daysInBlock, sessionType.daysUntilBlockEnd);
                textString{2} = sprintf('trial numbers: %d', currentTrialList(1));
                for ii = 2 : length(currentTrialList)
                    textString{2} = sprintf('%s, %d', textString{2}, currentTrialList(ii));
                end
                textString{3} = sprintf('color indicators: %s - %s',trialTypeColors{1},validTypeNames{1});
                for ii = 2 : length(currentTrialList)
                    textString{3} = sprintf('%s, %s - %s', textString{3},trialTypeColors{ii},validTypeNames{ii});
                end
                axes(trajectory_h_figAxis);
                text(trajectory_figProps.leftMargin,trajectory_figProps.height-0.75,textString,'units','centimeters','interpreter','none');
                pdfName_indTrials = sprintf('%s_%02d_normalized.pdf',pdf_baseName_indTrials,numTrialPages);
                print(trajectory_h_fig,pdfName_indTrials,'-dpdf');
                close(trajectory_h_fig);
            end
        end
            
            
            % include trial outcomes in the plots
            % start with plots that have the mean 3D trajectory on the far
            % right along with the current trial in 3D. Also, show each
            % individual dimension, overlaid on raw trajectories if
            % possible
           
    end
    
end