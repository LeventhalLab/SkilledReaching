% script_create_SR_sessionTables

xlDir = '/Users/alexbova/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');

tableDestination = xlDir;

ratInfo = ratInfoFromExcel(xlfname,'well learned');
ratInfo_IDs = [ratInfo.ratID];
numRats = length(ratInfo);

vidRootPath = '/Volumes/RecordingsLeventhal04/SkilledReaching';

colHeaders = {'ratID','date','trainingStage','totalSessions','session_in_block','laserStim','laserOnTiming','laserOffTiming','frameRate','preTriggerFrames','postTriggerFrames','experimenter'};

% trainingStage:
%   paw-preferencing
%   operant_training
%   training - training to proficiency once they understand the task
%   re-training - rat retraining after sugery (fiber implant)
%   testing
%   
% laserStim
%   none
%   on
%   occlude
%
% laserOnTiming: e.g., "beambreak", "vidTrigger", "noseIn"
% laserOffTiming: e.g, "beambreak", "vidTrigger", "noseIn"
%   note that timing can be "vidTrigger+2000", which would mean video trigger
%       + 2000 ms

for iRat = 1 : numRats
    
    ratIDstring = sprintf('R%04d',ratInfo(iRat).ratID);
    
    cd(vidRootPath);
    if ~exist(ratIDstring,'dir')
        continue;
    end
    
    cd(ratIDstring);
    rawDataFolder = [ratIDstring '-rawdata'];
    
    if ~exist(rawDataFolder,'dir')
        continue;
    end
    
    cd(rawDataFolder);
    sessionFolderPrefix = [ratIDstring '_2*'];   % all sessions are in the 2000s
    sessionFolders = listFolders(sessionFolderPrefix);
    
    % find the datenums for the first laser day and first occlusion day
    if isempty(ratInfo(iRat).firstDateLaser)
        firstLaserDateNum = 0;
    else
        firstLaserDateNum = datenum(ratInfo(iRat).firstDateLaser,'yyyymmdd');
    end
    if isempty(ratInfo(iRat).lastDateLaser)
        lastLaserDateNum = 0;
    else
        lastLaserDateNum = datenum(ratInfo(iRat).lastDateLaser,'yyyymmdd');
    end
    if isempty(ratInfo(iRat).firstDateOcclusion)
        firstOcclusionDateNum = 0;
    else
        firstOcclusionDateNum = datenum(ratInfo(iRat).firstDateOcclusion,'yyyymmdd');
    end
    if isempty(ratInfo(iRat).lastDateOcclusion)
        lastOcclusionDateNum = 0;
    else
        lastOcclusionDateNum = datenum(ratInfo(iRat).lastDateOcclusion,'yyyymmdd');
    end
    
    % create the .csv file and write in the headers
    sessionTableName = [ratIDstring '_sessionList.csv'];
    fullTableName = fullfile(tableDestination,sessionTableName);
    fid = fopen(fullTableName,'w');
    for ii = 1 : length(colHeaders) - 1
        fprintf(fid,'%s,',colHeaders{ii});
    end
    fprintf(fid,'%s\n',colHeaders{end});
    
    numLaserDays = 0;
    numOcclusionDays = 0;
    numPreLaserDays = 0;
    numPostLaserDays = 0;
    for iSession = 1 : length(sessionFolders)
        
        fullSessionFolder = fullfile(vidRootPath,ratIDstring,rawDataFolder,sessionFolders{iSession});
        
        cd(fullSessionFolder);
        
        % find the .log file
        logInfo = dir([ratIDstring '_*.log']);
        if isempty(logInfo)
            fprintf('log file not found for %s\n', sessionFolders{iSession});
            continue;
        elseif length(logInfo) > 1
            fprintf('more than one log file found for %s\n', sessionFolders{iSession});
            logInfo = logInfo(end);
        end
            
        try
            logData = readLogData(logInfo.name);
        catch
            fprintf('corrupted log file for %s\n',sessionFolders{iSession});
            continue;
        end
        
        curDateNum = datenum(logData.date,'yyyymmdd');
        
        if curDateNum < firstLaserDateNum || firstLaserDateNum == 0
            laserStim = 'none';
            numPreLaserDays = numPreLaserDays + 1;
            session_day = numPreLaserDays;
            trainingStage = 'training';
        elseif curDateNum >= firstLaserDateNum && curDateNum <= lastLaserDateNum
            laserStim = 'on';
            numLaserDays = numLaserDays + 1;
            session_day = numLaserDays;
            trainingStage = 'testing';
        elseif curDateNum >= firstOcclusionDateNum && curDateNum <= lastOcclusionDateNum
            laserStim = 'occlude';
            numOcclusionDays = numOcclusionDays + 1;
            session_day = numOcclusionDays;
            trainingStage = 'testing';
        else
            laserStim = 'unknown';
            numPostLaserDays = numPostLaserDays + 1;
            session_day = numPostLaserDays;
            trainingStage = 'testing';
        end
        if isfield(logData,'frameRate')
            frameRate = logData.frameRate;
        else
            frameRate = 300;
        end
    
        if ~strcmpi(laserStim,'none')
            switch lower(ratInfo(iRat).laserTiming)
                case 'during reach'
                    laserOnTiming = 'beambreak';
                    if isfield(logData,'LaserTimeOut')
                        laserOffTiming = sprintf('vidTrigger+%d',logData.LaserTimeOut);
                    else
                        laserOffTiming = sprintf('vidTrigger+%d',3000);
                    end
                case 'between reach'
                    if isfield(logData,'LaserStartTime')
                        laserOnTiming = sprintf('vidTrigger+%d',logData.LaserStartTime);
                    else
                        laserOnTiming = sprintf('vidTrigger+%d',5000);
                    end
                    if isfield(logData,'LaserTimeOut')
                        laserOffTiming = sprintf('laserOn+%d',logData.LaserTimeOut);
                    else
                        laserOffTiming = sprintf('laserOn+%d',4000);
                    end
            end
        else
            laserOffTiming = '';
            laserOnTiming = '';
        end

        % write next row to table
        fprintf(fid,'%d,%s,%s,%d,%d,%s,%s,%s,%d,%d,%d,\n',ratInfo(iRat).ratID,...
                                logData.date,...
                                trainingStage,...
                                iSession,...
                                session_day,...
                                laserStim,...
                                laserOnTiming,...
                                laserOffTiming,...
                                frameRate,...
                                logData.preTriggerFrames,...
                                logData.postTriggerFrames);
                            
    end
    
    fclose(fid);

end
        
        
    
    
    