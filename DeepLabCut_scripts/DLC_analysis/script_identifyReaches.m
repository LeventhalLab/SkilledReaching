% script to test reach end point algorithms

ratID = 'R0158';
sessionDate = '20170502';
sessionName = [ratID '_' sessionDate 'a'];
useSpecificTrial = false;
validTrialNumber = 18;

smoothSize = 3;

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
        'smoothsize',smoothSize,'slot_z',slot_z_wrt_pellet);
    
    return
end

% redo the calculations for the entire session
numTrials = size(allTrajectories,4);
for iTrial = 1 : numTrials
    
    trajectory = squeeze(allTrajectories(:,:,:,iTrial));
    slot_z_wrt_pellet = slot_z - all_initPellet3D(iTrial,3);

    [partEndPts,partEndPtFrame,partFinalEndPts,partFinalEndPtFrame,endPts,endPtFrame,final_endPts,final_endPtFrame,pawPartsList,reachFrameIdx] = ...
        findReachEndpoint_20190319(trajectory, bodyparts,pawPref,all_paw_through_slot_frame(iTrial),squeeze(all_isEstimate(:,:,:,iTrial)),...
        'smoothsize',smoothSize,'slot_z',slot_z_wrt_pellet);
    
end