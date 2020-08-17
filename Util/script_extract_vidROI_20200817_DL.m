% script to crop video with the same ROI as the extracted frames

% this script will find skilled reaching videos from specified sessions,
% crop out "direct" and "mirror" views, save the videos to a new folder,
% along with .mat files containing metadata (e.g., cropping coordinates)

% in addition to a file tree for videos as follows:
% Raw Data File Structure
% -	Parent directory
% o	Rat folder, named with rat identifier (e.g., “R0186”)
% 	Sessions folders RXXXX_YYYYMMDDz (e.g., “R0186_20170921a” would be the first session recorded on September 21, 2017 for rat R0186)
% 
% Each sessions folder contains a .log file (read with readLogData) with session metadata, and videos named with the format RXXXX_YYYYMMDD_HH-MM-DD_nnn.avi, where RXXXX is the rat identifier, YYYYMMDD is the date, HH-MM-DD is the time the video was recorded, and nnn is the number of the video within the session (e.g., 001, 002, etc.). Sometimes the software crashed mid-session, and the numbering restarted. However, each video still has a unique identifier based on the time it was recorded.
% 
% Each rat has a RXXXX_sessions.csv file associated with it, which is a table containing metadata for each session (e.g., was laser on/occluded during that session, training vs test session, etc.)

% also need: a .csv file with a table containing metadata about each rat
% ('Bova_Leventhal_2020_rat_database.csv')


% if cropped video file already exists, don't repeat
repeatCalculations = false;   
useSessionsFrom_DLCoutput_folder = false;

% set parent directory for where original videos are stored
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';

% directory for where to back up to server
sharedX_root_metadata_SavePath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';

% path for where to save cropped videos and metadata files
cropped_vidSaveRootPath = fullfile('/Volumes','LL EXHD #2','Skilled Reaching');
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

% read in the rat database file containing metadata
xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'Bova_Leventhal_2020_rat_database.csv');
ratInfo = readRatInfoTable(csvfname);
ratInfo_IDs = [ratInfo.ratID];

triggerTime = 1;    % time when video was triggered - hardcoded in seconds
frameTimeLimits = [-1,3.3];    % time around trigger to extract frames
    
for i_rat = 1 : numRatFolders   % change limits on loop if want to analyze specific rats
    
    ratID = ratFolders(i_rat).name
    ratFolder = fullfile(labeledBodypartsFolder,ratFolders(i_rat).name);
    
    % if backing up to a remote drive
    sharedX_rat_metadata_savePath = fullfile(sharedX_root_metadata_SavePath,ratID);
    % for saving to a local drive
    local_rat_metadata_savePath = fullfile(labeledBodypartsFolder,ratID);

    ratIDnum = str2double(ratID(2:end));
    thisRatInfo = ratInfo(ratInfo_IDs == ratIDnum,:);

    % is this rat tattooed? if so, what colors? on which date was it
    % tattooed?
    if iscell(thisRatInfo.pawPref)
        selectPawPref = thisRatInfo.pawPref{1};
    elseif iscategorical(thisRatInfo.pawPref)
        selectPawPref = char(thisRatInfo.pawPref);
    else
        selectPawPref = thisRatInfo.pawPref;
    end
    
    if iscell(thisRatInfo.tattooDate)
        if ischar(thisRatInfo.tattooDate{1})
            tattooDateString = thisRatInfo.tattooDate{1};
            tattooDate = datetime(tattooDateString,'inputformat','MM/dd/yy');
        elseif isdatetime(thisRatInfo.tattooDate{1})
            tattooDate = thisRatInfo.tattooDate{1};
        end
    elseif isdatetime(thisRatInfo.tattooDate)
        tattooDate = thisRatInfo.tattooDate;
    elseif ischar(thisRatInfo.tattooDate)
        tattooDateString = thisRatInfo.tattooDate;
        tattooDate = datetime(tattooDateString);
    end
    if isdatetime(tattooDate)
        if isnat(tattooDate)
            tattooDateString = '';
        else
            tattooDateString = datestr(tattooDate,'yyyymmdd');
        end
    else
        tattooDateString = '';
    end
    
    if iscell(thisRatInfo.digitColors)
        digitColors = thisRatInfo.digitColors{1};
    else
        digitColors = thisRatInfo.digitColors;
    end
    
    % DL modifications for using the ratInfo table
    validRatInfo = findSubTable(ratInfo,'pawPref',selectPawPref,'digitColors',digitColors);
    numValidRats = size(validRatInfo,1);

    if exist('sessionsToExtract','var')
        clear sessionsToExtract
    end
    
    % assign useSessionsFrom_DLCoutput_folder if need to recreate cropped
    % videos based on prior DLC analysis
    if useSessionsFrom_DLCoutput_folder
        DLCout_folder = fullfile(labeledBodypartsFolder,ratID);
        cd(DLCout_folder);

        sessionDirectories = listFolders([ratID '_2*']);
        for ii = 1 : length(sessionDirectories)
            sessionsToExtract(ii).ratID = ratID;
            sessionsToExtract(ii).session = sessionDirectories{ii}(7:end);
            sessionsToExtract(ii).sessionDateString = sessionDirectories{ii}(7:end-1);
            sessionsToExtract(ii).sessionDate = datetime(sessionsToExtract(ii).sessionDateString,'inputformat','yyyymmdd');
        end

    else
        % use sessions defined by the sessions table
        cd(ratFolder);
        sessionCSV = [ratID '_sessions.csv'];
        sessionTable = readSessionInfoTable(sessionCSV);
        
        % switch which line is commented depending on which sessions want
        % to crop
        % use this line if cropping videos for optogenetic stim analysis
        sessions_to_crop = getSessionsToCrop(sessionTable);
        
        % use this line if cropping videos during early learning sessions
%         sessions_to_crop = getSessionsToCrop_earlyLearning(sessionTable);
        
        for ii = 1 : size(sessions_to_crop,1)
            sessionsToExtract(ii).ratID = ratID;
            sessionsToExtract(ii).sessionDate = sessions_to_crop(ii,:).date;
        end
    end
    
    % use the switch...case below if want to crop specific sessions for a
    % given rat
    switch ratID
        case 'R0312'
            startSess = length(sessionsToExtract)-2;
            endSess = length(sessionsToExtract);
            ROI = [750,450,550,550;
                  1,450,450,400;
                  1650,435,390,400];
        case {'R0216'}
            ROI = [750,350,550,600;
                   1,400,450,450;
                   1650,400,390,450];
            startSess = 16;
            endSess = 16;%length(sessionsToExtract);
        case {'R0217'}
            ROI = [750,450,550,550;
                  1,450,450,400;
                  1650,435,390,400];
            startSess = 4;
            endSess = 4;
        otherwise
            ROI = [750,450,550,550;
                  1,450,450,400;
                  1650,435,390,400];
            startSess = 1;
            endSess = length(sessionsToExtract);
    end
    vidRatPath = fullfile(vidRootPath,ratID);
    for iSess = startSess:endSess         
    
        sessionDateString = datestr(sessionsToExtract(iSess).sessionDate,'yyyymmdd');
        
        if isempty(tattooDateString)
            selectTattoo = 'no';
        else
            if tattooDate < sessionsToExtract(iSess).sessionDate
                selectTattoo = 'yes';
            else
                selectTattoo = 'no';
            end
        end
        
        if strcmpi(selectTattoo,'yes')
            cropped_vidSavePath = fullfile(cropped_vidSaveRootPath,[ratID '_cropped'],[selectPawPref, '_paw_tattooed_', char(digitColors)]);
        else
            cropped_vidSavePath = fullfile(cropped_vidSaveRootPath,[ratID '_cropped'],[selectPawPref, '_paw_markerless']);
        end 

        if ~exist(cropped_vidSavePath,'dir')
            mkdir(cropped_vidSavePath);
        end

        viewList = {'direct','left','right'};
        viewSavePath = cell(1,3);
        for iView = 1 : length(viewList)
            viewSavePath{iView} = fullfile(cropped_vidSavePath, [viewList{iView} '_view'],[ratID '_' sessionDateString '_' viewList{iView}]);
            if ~isfolder(viewSavePath{iView})
                mkdir(viewSavePath{iView});
            end
        end
    
        % find the videos for this date
        cd(vidRatPath);
        sessionFolders = dir([ratID '_' sessionDateString '*']);
        if isempty(sessionFolders)
            fprintf('no video directory found for %s\n',[ratID '_' sessionDateString]);
            continue;
        end
        if length(sessionFolders) > 1
            fprintf('more than one video directory found for %s\n',[ratID '_' sessionDateString]);
            keyboard
            continue;            
        end
        fullSessionName = sessionFolders.name;
        
        vidSessionFolder = fullfile(vidRootPath,sessionsToExtract(iSess).ratID,fullSessionName);
        sharedX_sessionFolder = fullfile(sharedX_rat_metadata_savePath,fullSessionName);
        local_sessionFolder = fullfile(local_rat_metadata_savePath,fullSessionName);
        cd(vidSessionFolder);

        vidList = dir([sessionsToExtract(iSess).ratID,'*.avi']);
        if isempty(vidList); continue; end

        numVidsExtracted = 0;

        for vid = 1:length(vidList)
            frameTimeLimits = [-1,3.3]; 
            vidName = vidList(vid).name;
            vidNameNumber = vidName(end-6:end-4);
            destVidName = cell(1,length(viewSavePath));
            for iView = 1 : length(viewSavePath)
                destVidName{iView} = fullfile(viewSavePath{iView}, [vidName(1:end-4),'_',viewList{iView}, '.mp4']);
            end

            % check if destination vid already exists. If set to not
            % repeat calculations and cropped vid already exists, skip
            if ~repeatCalculations
                if exist(destVidName{iView},'file')
                    continue;
                end
            end

            fprintf('working on %s\n', vidName);

            video=VideoReader(vidName);

            if video.Duration < frameTimeLimits(2)+ triggerTime
                frameTimeLimits = [-1 video.Duration-1.01];
            else
                frameTimeLimits = frameTimeLimits;
            end             
            frameRate = video.FrameRate;
            frameSize = [video.height,video.width];
            cropVideo(vidName,destVidName,frameTimeLimits,triggerTime,ROI);

            [fp,fn,fext] = fileparts(vidName);

            for iView = 1 : length(viewSavePath)
                metadata_name = [fn '_' viewList{iView} '_metadata.mat'];
                if ~exist(viewSavePath{iView},'dir')
                    mkdir(viewSavePath{iView});
                end
                view_direction = viewList{iView};
                viewROI = ROI(iView,:);

                full_metadata_name{1} = fullfile(viewSavePath{iView},metadata_name);
                sharedX_viewPath = fullfile(sharedX_sessionFolder,[fullSessionName '_' viewList{iView}]);
                local_viewPath = fullfile(local_sessionFolder,[fullSessionName '_' viewList{iView}]);
                full_metadata_name{2} = fullfile(sharedX_viewPath,metadata_name);

                for ii = 1 : 2   % only loop ii = 1 : 1 if not backing up to a remote drive
                    [cur_path,~,~] = fileparts(full_metadata_name{ii});
                    if ~exist(cur_path,'dir')
                        mkdir(cur_path)
                    end
                    save(full_metadata_name{ii},'triggerTime','frameTimeLimits','view_direction','viewROI','frameRate','frameSize');
                end

            end
        end
    end 
        
end