% script_analyzeAlternateStimSessions

alternatingStimFolder = '/Volumes/LL EXHD #2/alternating stim analysis';
DLCoutput_folder = '/Volumes/LL EXHD #2/DLC output';
if ~exist(alternatingStimFolder,'dir')
    mkdir(alternatingStimFolder);
end

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_20191028.csv');
ratInfo = readRatInfoTable(csvfname);

alternateSessions = identifyAlternateSessions(ratInfo, 'beamBreak', 'vidTrigger+3000', ...
    'dlcoutput_folder',DLCoutput_folder);

numSessions = size(alternateSessions,1);

if exist('alternateKinematics','var')
    clear alternateKinematics
end
for iSession = 1 : numSessions
    
    cur_sessionInfo = alternateSessions(iSession,:);
    
    ratID = cur_sessionInfo.ratID;
    ratIDstring = sprintf('R%04d',ratID);
    current_rat_folder = fullfile(DLCoutput_folder,ratIDstring);
    
    thisRatInfo = ratInfo(ratInfo.ratID == ratID,:);
    
    if ~isfolder(current_rat_folder)
        continue
    end
    cd(current_rat_folder);
    
    sessionDate = cur_sessionInfo.date;
    sessionDateString = datestr(sessionDate,'yyyymmdd');
    
    testDirName = [ratIDstring '_' sessionDateString '*'];
    validSessionDir = dir(testDirName);
    if isempty(validSessionDir)
        continue;
    end
    
    alternateKinematics(iSession) = initializeAlternateKinematicsStructure(ratID,sessionDate);
    
    curSessionDir = validSessionDir.name;
    fullSessionDir = fullfile(current_rat_folder,curSessionDir);
    reachDataName = [ratIDstring '_' sessionDateString '_processed_reaches.mat'];
    reachDataName = fullfile(fullSessionDir,reachDataName);
    
    if ~exist(reachDataName,'file')
        sprintf('no reach data summary found for %s\n',curSessionDir);
        continue;
    end

    load(reachDataName);
        
    if alternateSessions(iSession,:).ratID == 197 && alternateSessions(iSession,:).date == datetime('20171217','inputformat','yyyyMMdd')
        % skip past trials before labview restarted
        firstTrial = 7;
    else
        firstTrial = 1;
    end
    alternateKinematics(iSession) = extractAlternatingKinematics(reachData,alternateKinematics(iSession),firstTrial);
    alternateKinematics(iSession).slot_z_wrt_pellet = all_slot_z_wrt_pellet;
    alternateKinematics(iSession).thisRatInfo = thisRatInfo;
end

alternateKinematics = analyzeAlternatingKinematics(alternateKinematics);

alternateKinematicsName = 'alternating_stim_kinematics_summary.mat';
alternateKinematicsName = fullfile(alternatingStimFolder,alternateKinematicsName);
alternateKinematicsName
save(alternateKinematicsName,'alternateSessions','alternateKinematics');
