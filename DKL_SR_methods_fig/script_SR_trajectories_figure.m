% script_SR_trajectories_figure

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

sr_ratInfo = get_sr_RatList();    
ratDir = cell(1,length(sr_ratInfo));
triDir = cell(1,length(sr_ratInfo));
scoreDir = cell(1,length(sr_ratInfo));

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
    
    for iSession = 1 : numSessions
        sessionDate = triDataFiles(iSession).name(7:14);
        shortDate = sessionDate(5:end);
        
        scoreName = [sr_ratInfo(i_rat).shortID, shortDate '.mat'];
        scoreName = fullfile(scoreDir{i_rat}, scoreName);
        triDataName = fullfile(triDir{i_rat}, triDataFiles(iSession).name);
        
        load(scoreName);
        load(triDataName);
        
        % find the failure reaches
        failedReaches = ismember(Scores, failedReachScores);
        successReaches = ismember(Scores, successReachScores);
        
        
    end
end    % for i_rat



