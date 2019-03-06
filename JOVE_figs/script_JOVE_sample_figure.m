% script_JOVE_sample_figure

ratIDnum = 284;
ratID = sprintf('R0%3d',ratIDnum);
sessionName = 'R0284_20190215a';
sessionDate = sessionName(7:14);

frameList = 300;

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
vidRootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');

ratInfo = readtable(csvfname);
% ratInfo = readExcelDB(xlfname, 'well learned');
ratInfo_IDs = [ratInfo.ratID];

vidNum = 9;
% template name for viable trajectory files (for searching)
trajectory_file_name = 'R*3dtrajectory_new.mat';

ratFolder = fullfile(labeledBodypartsFolder,ratID);
sessionFolder = fullfile(ratFolder,sessionName);

ratVidPath = fullfile(vidRootPath,ratID);   % root path for the original videos
vidDirectory = fullfile(ratVidPath,sessionName);

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

cd(sessionFolder)
matList = dir([ratID '_*_3dtrajectory_new.mat']);

sessionSummaryFile = sprintf('%s_%s_kinematicsSummary.mat',ratID,sessionDate);
load(sessionSummaryFile);

vidIdx = find(vidNum == trialNumbers(:,1));
load(matList(vidIdx).name);

vidName = [matList(vidIdx).name(1:27) '.avi'];
fullVidName = fullfile(vidDirectory,vidName);
vidIn = VideoReader(fullVidName);

fprintf('working on session %s\n', sessionDirectories{iSession});


for iFrame = 1 : length(frameList)
    
    vidIn.CurrentTime = (iFrame)/vidIn.FrameRate;
    curFrame = readFrame(vidIn);
    
    
    
end
