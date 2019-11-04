% script_processKinematicData

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');

ratInfo = ratInfoFromExcel(xlfname, 'well learned');
ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));