% script to crop videos and store cropped versions for testing in
% deeplabcut

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
triggerTime = 1;    % seconds
frameTimeLimits = [-1/6,1/3];    % time around trigger to extract frames

script_ratinfo_for_deepcut

% which types of videos to extract? left vs right paw, tat vs no tat
selectPawPref = 'left';
selectTattoo = 'yes';

savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','deepLabCut_testing_vids',[selectPawPref, '_paw_', selectTattoo, '_tattoo']);

% STEP 1: loa