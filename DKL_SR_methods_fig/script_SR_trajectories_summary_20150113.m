% script_SR_trajectories_summary_20150113

% script to make SR methods figure

% REACHING SCORES:
% 0 - no pellet presented or other mechanical failure
% 1 - first trial success (obtained pellet on initial limb advance)
% 2 - success (obtained pellet, but not on first attempt)
% 3 - forelimb advanced, pellet was grasped then dropped in the box
% 4 - forelimb advanced, but the pellet was knocked off the shelf
% 5 - pellet was obtained with its tongue
% 6 - the rat approached the slot but retreated without advancing its forelimb
% 7 - the rat reached, but the pellet remained on the shelf
% 8 - the rat used its contralateral paw.

% kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
pdfDir  = '/Users/dleventh/Documents/SR_plots';

sr_ratInfo = get_sr_RatList();    
ratDir = cell(1,length(sr_ratInfo));
% triDir = cell(1,length(sr_ratInfo));
% scoreDir = cell(1,length(sr_ratInfo));

failedReachCol_mean = [0 0 1 1];
successReachCol_mean = [1 0 0 1];

failedReachCol_mean_overlay = [failedReachCol_mean(1:3), 0.5];
successReachCol_mean_overlay = [successReachCol_mean(1:3), 0.5];

indReachTransparency = 1;
failedReachCol_ind = [0 0 1 indReachTransparency];
successReachCol_ind = [1 0 0 indReachTransparency];

meanWeight = 3;
indTrajWeight = 0.5;

% figure properties
traj3d_figProps.m = 4;
traj3d_figProps.n = 14;

traj3d_figProps.width = 35 * 2.54;
traj3d_figProps.height = 12 * 2.54;

traj3d_figProps.colSpacing = [0,0.5 * ones(1,traj3d_figProps.n - 2)];
traj3d_figProps.rowSpacing = 0.5 * ones(1,traj3d_figProps.m - 1);

sideMargins = 1;
traj3d_figProps.topMargin = 2.54;
botMargin = 1;

zdist_from_box = 175;    % in mm

traj3d_figProps.panelWidth = ((traj3d_figProps.width - ...
                              sum(traj3d_figProps.colSpacing) - ...
                              2 * sideMargins) / ...
                              traj3d_figProps.n) * ones(1,traj3d_figProps.n);
% traj3d_figProps.panelWidth = [3,traj3d_figProps.panelWidth];
traj3d_figProps.panelHeight = ((traj3d_figProps.height - ...
                               sum(traj3d_figProps.rowSpacing) - ...
                               traj3d_figProps.topMargin - botMargin) / ...
                               traj3d_figProps.m) * ones(1,traj3d_figProps.m-1);
traj3d_figProps.panelHeight = [3,traj3d_figProps.panelHeight];

xyz_figProps = traj3d_figProps;
comparison_figProps = traj3d_figProps;

% parameters for displaying the reaching slot
slotAlpha = 0.8;
slotColor = [0.9 0.9 0.9];
showSlot = true;

% parameters for drawing the shelf
shelfWidth = 20;
% NEED Y VALUES FOR THE SHELF
shelfCoords = [-20  zdist_from_box
               -20  zdist_from_box-shelfWidth
                20  zdist_from_box-shelfWidth
                20  zdist_from_box
               -20  zdist_from_box];
shelfAlpha = 0.9;
    
% graph orientation parameters
camUpVector = [0 -1 0];

% locations and parameters for header text
headerTextPos = [0.1,0.98];
headerFontSize = 14;

% locations and parameters for labels for each column of trajectories
sessionTextPos = [0.1 0.9];
sessionTextFontSize = 12;

failedReachScores  = [2, 4, 7];   % need to think about whether to include 2's in failures or not; I think so.
successReachScores = [1];

for i_rat = 1 : 1%length(sr_ratInfo)
    ratID = sr_ratInfo(i_rat).ID;
%     ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    processed_parentDir = sr_ratInfo(i_rat).directory.processed;
    
    cd(rawData_parentDir);
    
%     triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
%     scoreDir{i_rat} = fullfile(ratDir{i_rat},'scoreData');
    
    % parameters for adjusting view
    switch sr_ratInfo(i_rat).pawPref
        case 'right',
            camView = [-60 20];
        case 'left',
            camView = [-60 20];
    end
    

    % calculate average trajectory for each session for each rat
%     cd(triDir{i_rat});
%     triDataFiles = dir('*.mat');
%     numSessions = length(triDataFiles);
    
    numSessions = length(sr_ratInfo(i_rat).sessionList);
    numPlots = 0;
    numPages = 0;
    
    
    for iSession = 12 : numSessions
        
        sessionName = sr_ratInfo(i_rat).sessionList{iSession};
        sessionDate = sessionName(1:end-1);
%         shortDate = sessionDate(5:end);
        
        fprintf('%s, %s\n', ratID, sessionDate);
        
        cd(rawData_parentDir);
        rawDataDir = [ratID '_' sessionName];
%         rawDataDir = dir(rawDataDir);
        if ~exist(rawDataDir,'dir'); continue; end
%         if length(rawDataDir) > 1
%             fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
%             break;
%         end
        
        % find the raw data video numbers for this session
        processedDataDir = fullfile(processed_parentDir, rawDataDir);
        rawDataDir = fullfile(rawData_parentDir, rawDataDir);
        
        cd(processedDataDir);
        trajFile = dir('*_trajectories.mat');
        if isempty(trajFile);continue;end
        load(trajFile.name);
        
        Scores = trajectory_metadata.csv_scores(~isnan(trajectory_metadata.csv_scores));

        numPlots = numPlots + 1;
        col_idx = rem(numPlots, traj3d_figProps.n);
        if col_idx == 0
            col_idx = traj3d_figProps.n;
        end
        
        if col_idx == 1
            [h_fig, h_axes] = createFigPanels5(traj3d_figProps);
            [h_xyzFig, h_xyzAxes] = createFigPanels5(xyz_figProps);
            [h_compFig, h_compAxes] = createFigPanels5(comparison_figProps);
            numPages = numPages + 1;
        end

        % all successful reaches in the left column
        numSuccTraj = length(find(ismember(Scores, successReachScores)));
        successReachCol_ind(4) = 0.3;%indReachTransparency / numSuccTraj;
        [succ_meanTraj,succ_stdTraj,~,succ_alignFrame,slot_z] = plotSessionTrajectories(sr_ratInfo(i_rat), sessionName, successReachScores, ...
                               'axes',h_axes(2,col_idx), ...
                               'indtrialcol',successReachCol_ind, ...
                               'indtrajweight', indTrajWeight, ...
                               'meancol',successReachCol_mean, ...
                               'meanweight', meanWeight, ...
                               'showIndTraj',true, ...
                               'showmean',true, ...
                               'showslot', showSlot, ...
                               'slotalpha', slotAlpha,...
                               'slotcolor', slotColor,...
                               'camupvector',camUpVector,...
                               'camview',camView);
                       
        % all failed reaches in the middle column
        numFailTraj = length(find(ismember(Scores, failedReachScores)));
        failedReachCol_ind(4) = 0.2;%indReachTransparency / numFailTraj;
        [fail_meanTraj,fail_stdTraj,~,fail_alignFrame,~] = plotSessionTrajectories(sr_ratInfo(i_rat), sessionName, failedReachScores, ...
                               'axes',h_axes(3,col_idx), ...
                               'indtrialcol',failedReachCol_ind, ...
                               'indtrajweight', indTrajWeight, ...
                               'meancol',failedReachCol_mean, ...
                               'meanweight', meanWeight, ...
                               'showIndTraj',true, ...
                               'showmean',true, ...
                               'showslot', showSlot, ...
                               'slotalpha', slotAlpha,...
                               'slotcolor', slotColor,...
                               'camupvector',camUpVector,...
                               'camview',camView);
              
        plotXYZtraj(succ_meanTraj, succ_stdTraj, succ_alignFrame, trajectory_metadata.frameRate, ...
                    'color',successReachCol_mean,...
                    'axes',h_xyzAxes(2:end,col_idx),...
                    'slot_z',slot_z);
        plotXYZtraj(fail_meanTraj, fail_stdTraj, fail_alignFrame, trajectory_metadata.frameRate, ...
                    'color',failedReachCol_mean,...
                    'axes',h_xyzAxes(2:end,col_idx));
        % overlay of mean failed and successful reaches in the right column
        plotSessionTrajectories(sr_ratInfo(i_rat), sessionName, successReachScores, ...
                           'axes',h_axes(4,col_idx), ...
                           'meancol',successReachCol_mean_overlay, ...
                           'showIndTraj',false, ...
                           'showmean',true, ...
                           'meanweight', meanWeight, ...
                           'showslot', false);
        hold on
        plotSessionTrajectories(sr_ratInfo(i_rat), sessionName, failedReachScores, ...
                           'axes',h_axes(4,col_idx), ...
                           'meancol',failedReachCol_mean_overlay, ...
                           'showIndTraj',false, ...
                           'showmean',true, ...
                           'meanweight', meanWeight,...
                           'showslot', showSlot, ...
                           'slotalpha', slotAlpha, ...
                           'slotcolor', slotColor,...
                           'camupvector',camUpVector,...
                           'camview',camView);

        trajectories{1} = succ_meanTraj;
        trajectories{2} = fail_meanTraj;
        alignmentFrames = [succ_alignFrame,fail_alignFrame];
        [succFailDiff,alignFrame] = compareTrajectories(trajectories, alignmentFrames);
        
        plotComptraj(succFailDiff,alignFrame,trajectory_metadata.frameRate,...
                    'axes',h_compAxes(2:3,col_idx));
	
%         set(gca,'cameratarget',[0,0,zdist_from_box],...
%                 'cameraposition',[0,0,0],...
%                 'ydir','reverse');
        axes(h_axes(1,col_idx));
        set(gca,'visible','off');
        sessionString{1} = sprintf('date: %s',sessionDate);
        sessionString{2} = sprintf('num success: %d', numSuccTraj);
        sessionString{3} = sprintf('num failure: %d', numFailTraj);
        text('units','normalized',...
             'position',sessionTextPos,...
             'fontsize',sessionTextFontSize,...
             'string',sessionString);
         
        axes(h_xyzAxes(1,col_idx));
        set(gca,'visible','off');
        sessionString{1} = sprintf('date: %s',sessionDate);
        sessionString{2} = sprintf('num success: %d', numSuccTraj);
        sessionString{3} = sprintf('num failure: %d', numFailTraj);
        text('units','normalized',...
             'position',sessionTextPos,...
             'fontsize',sessionTextFontSize,...
             'string',sessionString);
         
        axes(h_compAxes(1,col_idx));
        set(gca,'visible','off');
        sessionString{1} = sprintf('date: %s',sessionDate);
        sessionString{2} = sprintf('num success: %d', numSuccTraj);
        sessionString{3} = sprintf('num failure: %d', numFailTraj);
        text('units','normalized',...
             'position',sessionTextPos,...
             'fontsize',sessionTextFontSize,...
             'string',sessionString);
         
	% NEED TO CONSTRUCT THE HEADER FOR EACH PAGE, ADD THE DAY #, # FAILED
	% TRIALS, NUMBER OF SUCCESS TRIALS, CHANGE THE ORIENTATION OF THE 3D
	% PLOTS TO MAKE THEM MORE READILY VISIBLE, CHANGE THE X,Y,Z LIMITS.
	% FIGURE OUT HOW TO DRAW THE SLOT ONTO THE PLOT. FIGURE OUT HOW TO ADD
	% THE PELLET TO THE PLOT
        if (rem(numPlots, traj3d_figProps.n) == 0) || iSession == numSessions
            h_figAxes = createFigAxes(h_fig);
            axes(h_figAxes);
            headerString{1} = sprintf('%s, paw preference: %s', ratID, sr_ratInfo(i_rat).pawPref);
            text('units','normalized',...
                 'position',headerTextPos,...
                 'fontsize',headerFontSize, ...
                 'string',headerString);
            traj3dName = sprintf('%s_traj_summary_%02d.pdf',ratID,numPages);
            traj3dName = fullfile(pdfDir,traj3dName);
            tic
                export_fig(traj3dName, '-pdf','-q101','-painters','-append');
            toc
            numPages = numPages + 1;
            close(h_fig);
        end
    end
end    % for i_rat



