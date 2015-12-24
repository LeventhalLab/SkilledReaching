% script_SR_trajectories_summary

% script to make SR methods figure

% REACHING SCORES:
% 0 ? no pellet presented or other mechanical failure
% 1 - first trial success (obtained pellet on initial limb advance)
% 2 - success (obtained pellet, but not on first attempt)
% 3 - forelimb advanced, pellet was grasped then dropped in the box
% 4 - forelimb advanced, but the pellet was knocked off the shelf
% 5 ? pellet was obtained with its tongue
% 6 ? the rat approached the slot but retreated without advancing its forelimb
% 7 - the rat reached, but the pellet remained on the shelf
% 8 ? the rat used its contralateral paw.

rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';
pdfDir  = '/Users/dleventh/Documents/SR_plots';

sr_ratInfo = get_sr_RatList();    
ratDir = cell(1,length(sr_ratInfo));
triDir = cell(1,length(sr_ratInfo));
scoreDir = cell(1,length(sr_ratInfo));

failedReachCol_mean = [0 0 1];
successReachCol_mean = [1 0 0];

failedReachCol_ind = [0 0 0.5];
successReachCol_ind = [0.5 0 0];

traj3d_figProps.m = 5;
traj3d_figProps.n = 3;

traj3d_figProps.width = 8.5 * 2.54;
traj3d_figProps.height = 11 * 2.54;

traj3d_figProps.colSpacing = 0.5 * ones(1,traj3d_figProps.n - 1);
traj3d_figProps.rowSpacing = 0.5 * ones(1,traj3d_figProps.m - 1);
sideMargins = 1;
traj3d_figProps.topMargin = 2.54;
botMargin = 1;

traj3d_figProps.panelWidth = ((traj3d_figProps.width - ...
                              sum(traj3d_figProps.colSpacing) - ...
                              2 * sideMargins) / ...
                              traj3d_figProps.n) * ones(1,traj3d_figProps.n);
traj3d_figProps.panelHeight = ((traj3d_figProps.height - ...
                               sum(traj3d_figProps.rowSpacing) - ...
                               traj3d_figProps.topMargin - botMargin) / ...
                               traj3d_figProps.m) * ones(1,traj3d_figProps.m);

failedReachScores  = [2, 4, 7];   % need to think about whether to include 2's in failures or not; I think so.
successReachScores = [1];

for i_rat = 1 : length(sr_ratInfo)
    ratID = sr_ratInfo(i_rat).ID;
    ratDir{i_rat} = fullfile(rootDir,ratID);
    
    triDir{i_rat} = fullfile(ratDir{i_rat},'triData');
    scoreDir{i_rat} = fullfile(ratDir{i_rat},'scoreData');
    
    % calculate average trajectory for each session for each rat
    cd(triDir{i_rat});
    triDataFiles = dir('*.mat');
    numSessions = length(triDataFiles);
    
    numPlots = 0;
    numPages = 0;
    for iSession = 1 : numSessions
        sessionDate = triDataFiles(iSession).name(7:14);
        shortDate = sessionDate(5:end);
        
        scoreName = [sr_ratInfo(i_rat).shortID, shortDate '.mat'];
        scoreName = fullfile(scoreDir{i_rat}, scoreName);
        triDataName = fullfile(triDir{i_rat}, triDataFiles(iSession).name);
        
        load(scoreName);
        load(triDataName);
        
        numPlots = numPlots + 1;
        if (rem(numPlots, traj3d_figProps.m) == 1)
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
        
        plot3Dtrajectories(x_fail,y_fail,z_fail,...
                           'axes',h_axes(numPlots, 1), ...
                           'indtrialcol',successReachCol_ind, ...
                           'meancol',successReachCol_mean, ...
                           'showIndTraj',true, ...
                           'showmean',true);
                       
        plot3Dtrajectories(x_succ,y_succ,z_succ,...
                           'axes',h_axes(numPlots, 2), ...
                           'indtrialcol',failedReachCol_ind, ...
                           'meancol',failedReachCol_mean, ...
                           'showIndTraj',true, ...
                           'showmean',true);
              
        plot3Dtrajectories(x_fail,y_fail,z_fail,...
                           'axes',h_axes(numPlots, 3), ...
                           'meancol',failedReachCol_mean, ...
                           'showIndTraj',false, ...
                           'showmean',true);
        hold on
        plot3Dtrajectories(x_succ,y_succ,z_succ,...
                           'axes',h_axes(numPlots, 3), ...
                           'meancol',successReachCol_mean, ...
                           'showIndTraj',false, ...
                           'showmean',true);
                    
	% NEED TO CONSTRUCT THE HEADER FOR EACH PAGE, ADD THE DAY #, # FAILED
	% TRIALS, NUMBER OF SUCCESS TRIALS, CHANGE THE ORIENTATION OF THE 3D
	% PLOTS TO MAKE THEM MORE READILY VISIBLE, CHANGE THE X,Y,Z LIMITS.
	% FIGURE OUT HOW TO DRAW THE SLOT ONTO THE PLOT
    
    end
end    % for i_rat



