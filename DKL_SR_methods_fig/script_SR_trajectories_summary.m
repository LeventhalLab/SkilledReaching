% script_SR_trajectories_summary

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

kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
pdfDir  = '/Users/dleventh/Documents/SR_plots';

sr_ratInfo = get_sr_RatList();    
ratDir = cell(1,length(sr_ratInfo));
triDir = cell(1,length(sr_ratInfo));
scoreDir = cell(1,length(sr_ratInfo));

failedReachCol_mean = [0 0 1 1];
successReachCol_mean = [1 0 0 1];

failedReachCol_mean_overlay = [failedReachCol_mean(1:3), 0.5];
successReachCol_mean_overlay = [successReachCol_mean(1:3), 0.5];

indReachTransparency = 0.5;
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

% parameters for displaying the reaching slot
slotCoords = [-5  30 zdist_from_box
              -5 -10 zdist_from_box
               5 -10 zdist_from_box
               5  30 zdist_from_box
              -5  30 zdist_from_box];
slotAlpha = 0.8;
slotColor = [0.9 0.9 0.9];
showSlot = true;

% parameters for drawing the shelf
shelfWidth = 10;
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

for i_rat = 2 : length(sr_ratInfo)
    ratID = sr_ratInfo(i_rat).ID;
    ratDir{i_rat} = fullfile(kinematics_rootDir,ratID);
    
    rawData_parentDir = sr_ratInfo(i_rat).directory.rawdata;
    
    triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
    scoreDir{i_rat} = fullfile(ratDir{i_rat},'scoreData');
    
    % parameters for adjusting view
    switch sr_ratInfo(i_rat).pawPref
        case 'right',
            camView = [85 225];
        case 'left',
            camView = [85 45];
    end
    

    % calculate average trajectory for each session for each rat
    cd(triDir{i_rat});
    triDataFiles = dir('*.mat');
    numSessions = length(triDataFiles);
    
    numPlots = 0;
    numPages = 0;
    for iSession = 1 : numSessions
        
        sessionDate = triDataFiles(iSession).name(7:14);
        shortDate = sessionDate(5:end);
        
        fprintf('%s, %s\n', ratID, sessionDate);
        
        cd(rawData_parentDir);
        rawDataDir = [ratID '_' sessionDate '*'];
        rawDataDir = dir(rawDataDir);
        if isempty(rawDataDir); continue; end
        if length(rawDataDir) > 1
            fprintf('more than one data folder for %s, %s\n', ratID, sessionDate)
            break;
        end
        
        % find the raw data video numbers for this session
        rawDataDir = fullfile(rawData_parentDir, rawDataDir.name);
        
        scoreName = [sr_ratInfo(i_rat).shortID, shortDate '.mat'];
        scoreName = fullfile(scoreDir{i_rat}, scoreName);
        triDataName = fullfile(triDir{i_rat}, triDataFiles(iSession).name);
        
        load(scoreName);
        load(triDataName);
        
        if length(Scores) > length(x)    % more scores assigned than there are trajectories
                                         % this is probably because videos
                                         % that aren't numbered
                                         % sequentially, so "skipped"
                                         % videos may be counted in the
                                         % Scores. Assume (for now) that
                                         % skipped videos should just be
                                         % eliminated
            fileNumbers = getFileNumbers(rawDataDir, '.avi', '_');
            Scores = Scores(fileNumbers);
        end
        
        if length(Scores) ~= length(x)
            fprintf('number of scores and trajectories do not match for %s, %s\n', ratID, sessionDate)
            break
        end
        numPlots = numPlots + 1;
        col_idx = rem(numPlots, traj3d_figProps.n);
        if col_idx == 0
            col_idx = traj3d_figProps.n;
        end
        
        if col_idx == 1
            [h_fig, h_axes] = createFigPanels5(traj3d_figProps);
            numPages = numPages + 1;
        end
            
            
        % find the failure reaches
        failedReaches  = find(ismember(Scores, failedReachScores));
        successReaches = find(ismember(Scores, successReachScores));
        
        x_fail = cell(1,length(failedReaches));
        y_fail = cell(1,length(failedReaches));
        z_fail = cell(1,length(failedReaches));
        
        x_succ = cell(1,length(successReaches));
        y_succ = cell(1,length(successReaches));
        z_succ = cell(1,length(successReaches));
        
        for i_fail = 1 : length(failedReaches)
            x_fail{i_fail} = x{failedReaches(i_fail)};
            y_fail{i_fail} = y{failedReaches(i_fail)};
            z_fail{i_fail} = z{failedReaches(i_fail)};
        end
        for i_succ = 1 : length(successReaches)
            x_succ{i_succ} = x{successReaches(i_succ)};
            y_succ{i_succ} = y{successReaches(i_succ)};
            z_succ{i_succ} = z{successReaches(i_succ)};
        end
        
        axes(h_axes(1,col_idx));
        set(gca,'visible','off');
        sessionString{1} = sprintf('date: %s',sessionDate);
        sessionString{2} = sprintf('num success: %d', length(successReaches));
        sessionString{3} = sprintf('num failure: %d', length(failedReaches));
        text('units','normalized',...
             'position',sessionTextPos,...
             'fontsize',sessionTextFontSize,...
             'string',sessionString);
             
        % all successful reaches in the left column
        successReachCol_ind(4) = indReachTransparency / length(x_succ);
        plot3Dtrajectories(x_succ,y_succ,z_succ,...
                           'axes',h_axes(2,col_idx), ...
                           'indtrialcol',successReachCol_ind, ...
                           'indtrajweight', indTrajWeight, ...
                           'meancol',successReachCol_mean, ...
                           'meanweight', meanWeight, ...
                           'showIndTraj',true, ...
                           'showmean',true, ...
                           'showslot', showSlot, ...
                           'slotcoords', slotCoords, ...
                           'slotalpha', slotAlpha,...
                           'slotcolor', slotColor,...
                           'disttoslot',zdist_from_box,...
                           'camupvector',camUpVector,...
                           'camview',camView);
                       
        % all failed reaches in the middle column
        failedReachCol_ind(4) = indReachTransparency / length(x_fail);
        plot3Dtrajectories(x_fail,y_fail,z_fail,...
                           'axes',h_axes(3,col_idx), ...
                           'indtrialcol',failedReachCol_ind, ...
                           'indtrajweight', indTrajWeight, ...
                           'meancol',failedReachCol_mean, ...
                           'meanweight', meanWeight, ...
                           'showIndTraj',true, ...
                           'showmean',true,...
                           'showslot', showSlot, ...
                           'slotcoords', slotCoords, ...
                           'slotalpha', slotAlpha,...
                           'slotcolor', slotColor,...
                           'disttoslot',zdist_from_box,...
                           'camupvector',camUpVector,...
                           'camview',camView);
              
        % overlay of mean failed and successful reaches in the right column
        plot3Dtrajectories(x_fail,y_fail,z_fail,...
                           'axes',h_axes(4,col_idx), ...
                           'meancol',failedReachCol_mean_overlay, ...
                           'showIndTraj',false, ...
                           'showmean',true, ...
                           'meanweight', meanWeight);
        hold on
        plot3Dtrajectories(x_succ,y_succ,z_succ,...
                           'axes',h_axes(4,col_idx), ...
                           'meancol',successReachCol_mean_overlay, ...
                           'showIndTraj',false, ...
                           'showmean',true, ...
                           'meanweight', meanWeight,...
                           'showslot', showSlot, ...
                           'slotcoords', slotCoords, ...
                           'slotalpha', slotAlpha, ...
                           'slotcolor', slotColor,...
                           'disttoslot',zdist_from_box,...
                           'camupvector',camUpVector,...
                           'camview',camView);
%         set(gca,'cameratarget',[0,0,zdist_from_box],...
%                 'cameraposition',[0,0,0],...
%                 'ydir','reverse');
        
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
            pdfName = sprintf('%s_traj_summary_%02d.pdf',ratID,numPages);
            pdfName = fullfile(pdfDir,pdfName);
            tic
                export_fig(pdfName, '-pdf','-q101','-painters','-append');
            toc
            numPages = numPages + 1;
            close(h_fig);
        end
    end
end    % for i_rat



