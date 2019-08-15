% script to test reach end point algorithms

min_z_diff_pre_reach = 1;     % minimum number of millimeters the paw must have moved since the previous reach to count as a new reach
min_z_diff_post_reach = 1.5;     
maxFramesPriorToAdvance = 10;   % if the paw extends further within this many frames after a local minimum, don't count it as a reach
pts_to_extract = 15;  % look pts_to_extract frames on either side of each z
smoothSize = 3;

ratID = 'R0158';
sessionDate = '20170509';
sessionName = [ratID '_' sessionDate 'a'];
useSpecificTrial = true;
validTrialNumber = 36;

validTrialTypes = {0:10,0,1,2,[3,4,7]};

labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190708.csv');
ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

ratFolder = fullfile(labeledBodypartsFolder, ratID);
sessionFolder = fullfile(ratFolder,sessionName);

ratIDnum = str2double(ratID(2:end));
ratInfo_idx = find(ratInfo_IDs == ratIDnum);
if isempty(ratInfo_idx)
    error('no entry in ratInfo structure for rat %d\n',C{1});
end
thisRatInfo = ratInfo(ratInfo_idx,:);
pawPref = thisRatInfo.pawPref;
if iscategorical(pawPref)
    pawPref = char(pawPref);
end
if iscell(pawPref)
    pawPref = pawPref{1};
end

cd(sessionFolder);
sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
sessionSummaryName = fullfile(sessionFolder,sessionSummaryName);
load(sessionSummaryName);

iTrial = find(trialNumbers(:,2) == validTrialNumber);
if length(iTrial) > 1
    keyboard
end
if useSpecificTrial
        trajectory = squeeze(allTrajectories(:,:,:,iTrial));
    slot_z_wrt_pellet = slot_z - all_initPellet3D(iTrial,3);

    [partEndPts,partEndPtFrame,partFinalEndPts,partFinalEndPtFrame,endPts,endPtFrame,final_endPts,final_endPtFrame,pawPartsList,reachFrameIdx] = ...
        findReachEndpoint_20190319(trajectory, bodyparts,pawPref,all_paw_through_slot_frame(iTrial),squeeze(all_isEstimate(:,:,:,iTrial)),...
        'smoothsize',smoothSize,'slot_z',slot_z_wrt_pellet,'min_dist_pre_reach',min_z_diff_pre_reach,'min_dist_post_reach',min_z_diff_post_reach);
    
    return
end

% redo the calculations for the entire session
numTrials = size(allTrajectories,4);
[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
numPawParts = length(mcpIdx) + length(pipIdx) + length(digIdx) + length(pawDorsumIdx);
all_all_partEndPts = zeros(numPawParts,3,numTrials);
all_partEndPtFrame = NaN(numPawParts,numTrials);
all_endPtFrame = NaN(numTrials,1);
all_final_endPtFrame = NaN(numTrials,1);
all_endPts = zeros(numPawParts,3,numTrials);
all_final_endPts = zeros(numPawParts,3,numTrials);
all_partFinalEndPts = NaN(numPawParts,3,numTrials);
all_partFinalEndPtFrame = NaN(numPawParts,numTrials);
all_reachFrameIdx = cell(1,numTrials);
    
for iTrial = 1 : numTrials
    
    trajectory = squeeze(allTrajectories(:,:,:,iTrial));
    slot_z_wrt_pellet = slot_z - all_initPellet3D(iTrial,3);

    [all_partEndPts(:,:,iTrial),all_partEndPtFrame(:,iTrial),all_partFinalEndPts(:,:,iTrial),all_partFinalEndPtFrame(:,iTrial),all_endPts(:,:,iTrial),all_endPtFrame(iTrial),all_final_endPts(:,:,iTrial),all_final_endPtFrame(iTrial),all_pawPartsList,all_reachFrameIdx{iTrial}] = ...
        findReachEndpoint_20190319(trajectory, bodyparts,pawPref,all_paw_through_slot_frame(iTrial),squeeze(all_isEstimate(:,:,:,iTrial)),...
        'smoothsize',smoothSize,'slot_z',slot_z_wrt_pellet,'min_dist_pre_reach',min_z_diff_pre_reach,'min_dist_post_reach',min_z_diff_post_reach,...
        'maxframespriortoadvance',maxFramesPriorToAdvance,'pts_to_extract',pts_to_extract);
    
end
[first_reachEndPoints,distFromPellet] = collectFirstReachEndPoints(all_endPts,validTrialTypes,all_trialOutcomes);
[all_reachEndPoints,numReaches_byPart,numReaches,reachFrames,reach_endPoints] = ...
    collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,validTrialTypes,all_trialOutcomes,digIdx);