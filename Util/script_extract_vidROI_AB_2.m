% script to crop video with the same ROI as the extracted frames

% script to randomly select videos, crop them, and store frames for marking
% paws in Fiji (or whatever else we decide to use)


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not
%%
% tic
ratList = {'R0158','R0159','R0160','R0161','R0169','R0170','R0171','R0183',...
           'R0184','R0186','R0187','R0189','R0190',...
           'R0191','R0192','R0193','R0194','R0195','R0196','R0197','R0198',...
           'R0216','R0217','R0218','R0219','R0220','R0223','R0225','R0227',...
           'R0228','R0229'};
       
repeatCalculations = true;   % if cropped video file already exists, don't repeat?

vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';
sharedX_rootSavePath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

% HAVE TO REDO RAT 25 (R0219)
for i_rat = 30 : numRatFolders
    
    ratID = ratFolders(i_rat).name;

    useSessionsFrom_DLCoutput_folder = true;
    ratIDnum = str2double(ratID(2:end));

    
    sharedX_savePath = fullfile(sharedX_rootSavePath,ratID);
    local_savePath = fullfile(labeledBodypartsFolder,ratID);
    triggerTime = 1;    % seconds
    frameTimeLimits = [-1,3.3];    % time around trigger to extract frames
    numVidstoExtract = 2;

    xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
    csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
    ratInfo = readtable(csvfname);
    ratInfo_IDs = [ratInfo.ratID];

    thisRatInfo = ratInfo(ratInfo_IDs == ratIDnum,:);

    % set to true if you want to extract videos at random, or to false if you
    % want to specify which sessions to extract videos from (below)
    selectRandomVideos = false;
    extractFullSession = true;

    % which types of videos to extract? left vs right paw, tat vs no tat 
    if iscell(thisRatInfo.pawPref)
        selectPawPref = thisRatInfo.pawPref{1};
    else
        selectPawPref = thisRatInfo.pawPref;
    end
    selectTattoo = 'yes';
    % digitColors = 'gbypr';   % order of colors on the digits (digits 1-4 and dorsum of paw).
                             % g = green, p = purple, b = blue, y = yellow, r = red
    if iscell(thisRatInfo.digitColors)
        digitColors = thisRatInfo.digitColors{1};
    else
        digitColors = thisRatInfo.digitColors;
    end

    if strcmpi(selectTattoo,'yes')
        savePath = fullfile('/Volumes','LL EXHD #2','Skilled Reaching',[ratID '_cropped'],[selectPawPref, '_paw_tattooed_', digitColors]);
    else
        savePath = fullfile('/Volumes','LL EXHD #2','Skilled Reaching',[ratID '_cropped'],[selectPawPref, '_paw_markerless']);
    end 

    if ~exist(savePath,'dir')
        mkdir(savePath);
    end

    viewList = {'direct','left','right'};
    viewSavePath = cell(1,3);
    for iView = 1 : length(viewList)
        viewSavePath{iView} = fullfile(savePath, [viewList{iView} '_view']);
        if ~isfolder(viewSavePath{iView})
            mkdir(viewSavePath{iView});
        end
    end

    xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
    % xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
    csvfname = fullfile(xlDir,'rat_info_pawtracking_20190708.csv');
    ratInfo = readRatInfoTable(csvfname);

    % script_ratInfo_for_deepcut_AB;

    numRats = size(ratInfo,1);
    % numRats = length(ratInfo);

    % first row for direct view, second row left view, third row right view
    % format [a,b,c,d] where (a,b) is the upper left corner and (c,d) is
    % (width,height)

    % ROI = [750,350,550,600;
    %        1,400,450,450;
    %        1650,400,390,450];

    % old vidROI
%     ROI = [750,450,550,550;
%               1,450,450,400;
%               1650,435,390,400];
    % ultimately, randomly select videos and times for cropping out images to
    % make a stack

    % first step will be to make a list of tattooed and non-tattooed sessions

    % DL modifications for using the ratInfo table
    validRatInfo = findSubTable(ratInfo,'pawPref',selectPawPref,'digitColors',digitColors);
    numValidRats = size(validRatInfo,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% list of videos to extract if selectRandomVideos = false;
    % desigante the Rat and the Session Date but will then randomly select the
    % number of videos set by numVidsttoExtract (above) 

    % you should extract videos of rats w/ same paw pref and tattoos at the
    % same time (make sure to change above so that videos save to correct
    % folders)
    ii = 0;
    if exist('sessionsToExtract','var')
        clear sessionsToExtract
    end
    if ~selectRandomVideos
        if useSessionsFrom_DLCoutput_folder
            DLCout_folder = fullfile(labeledBodypartsFolder,ratID);
            cd(DLCout_folder);

            sessionDirectories = listFolders([ratID '_2*']);
            for ii = 1 : length(sessionDirectories)
                sessionsToExtract(ii).ratID = ratID;
                sessionsToExtract(ii).session = sessionDirectories{ii}(7:end);
            end
        else
    %     ii = ii + 1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180507a';

    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20171201a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180203a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180205a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180206a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180207a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180208a'; 
    %     
    %     ii = ii+1;                                                               
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180209a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180210a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180212a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180213a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180214a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180215a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180216a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180217a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180220a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180221a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180222a'; 
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180223a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180224a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180225a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180227a';
    % 
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180228a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180301a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180302a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180305a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180306a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180307a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180308a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180309a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180313a';
    %     
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180314a';
    % 
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180316a';
    % 
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180320a';
    % 
    %     ii = ii+1;
    %     sessionsToExtract(ii).ratID = ratID;
    %     sessionsToExtract(ii).session = '20180323a';
        end
    end
    %%
    numVidsExtracted = 0;
    if selectRandomVideos
        while numVidsExtracted < numVidstoExtract

            % select a rat at random
            validRatIdx = floor(rand * numValidRats) + 1;
            numRatSessions = length(validRatInfo(validRatIdx).sessionList);

            numValidSessions = 0;
            firstTattooDate = validRatInfo(validRatIdx).firstTattooedSession;
            if isempty(firstTattooDate)
                % rat hasn't been tattooed yet, so all sessions are without
                % tattoooing. pick a date way in the future
                firstTattooDateNum = datenum('20501231','yyyymmdd');
            else
                firstTattooDateNum = datenum(firstTattooDate,'yyyymmdd');
            end

            validSessionList = {};
            for iRatSession = 1 : numRatSessions
                currentSessionDate = validRatInfo(validRatIdx).sessionList{iRatSession}(7:end-1);
                currentSessionDateNum = datenum(currentSessionDate,'yyyymmdd');

                switch selectTattoo
                    case 'no'
                        if currentSessionDateNum < firstTattooDateNum
                            numValidSessions = numValidSessions + 1;
                            validSessionList{numValidSessions} = validRatInfo(validRatIdx).sessionList{iRatSession};
                        end
                    otherwise
                        if currentSessionDateNum >= firstTattooDateNum
                            numValidSessions = numValidSessions + 1;
                            validSessionList{numValidSessions} = validRatInfo(validRatIdx).sessionList{iRatSession};
                        end
                end
            end
            if numValidSessions == 0
                continue;
            end

            % select a session at random
            validSessionIdx = floor(rand * numValidSessions) + 1;

            vidSessionFolder = fullfile(vidRootPath,validRatInfo(validRatIdx).IDstring,validSessionList{validSessionIdx});
            cd(vidSessionFolder);

            vidList = dir([validRatInfo(validRatIdx).IDstring,'*.avi']);
            if isempty(vidList); continue; end
            % every now and then, an empty folder

            % pick a video at random
            currentVidNumber = floor(rand * length(vidList)) + 1;
            vidName = vidList(currentVidNumber).name;
            vidNameNumber = vidName(end-6:end-4);
            destVidName = cell(1,length(viewSavePath));
            for iView = 1 : length(viewSavePath)
                destVidName{iView} = fullfile(viewSavePath{iView}, [vidName(1:end-4),'_',viewList{iView}]);
            end

            % check if destination vid already exists. If set to not
            % repeat calculations and cropped vid already exists, skip
            if ~repeatCalculations
                if exist(destVidName{iView},'file')
                    continue;
                end
            end

            fprintf('working on %s\n', vidName);

            cropVideo(vidName,destVidName,frameTimeLimits,triggerTime,ROI);

            numVidsExtracted = numVidsExtracted + 1;

        end
    else % extracts videos from sessions specified above

        switch ratID
            case 'R0227'
                startSess = 11;
                endSess = length(sessionsToExtract);
                ROI = [750,450,550,550;
                      1,450,450,400;
                      1650,435,390,400];
            case 'R0216'
                ROI = [750,350,550,600;
                       1,400,450,450;
                       1650,400,390,450];
                startSess = 1;
                endSess = length(sessionsToExtract);
            otherwise
                ROI = [750,450,550,550;
                      1,450,450,400;
                      1650,435,390,400];
                startSess = 1;
                endSess = length(sessionsToExtract);
        end
        for iSess = startSess:endSess
            
    %         vidSessionFolder = fullfile(vidRootPath,sessionsToExtract(iSess).ratID,[sessionsToExtract(iSess).ratID '-rawdata'],[sessionsToExtract(iSess).ratID '_' sessionsToExtract(iSess).session]);
            fullSessionName = [sessionsToExtract(iSess).ratID '_' sessionsToExtract(iSess).session];
            vidSessionFolder = fullfile(vidRootPath,sessionsToExtract(iSess).ratID,fullSessionName);
            sharedX_sessionFolder = fullfile(sharedX_savePath,fullSessionName);
            local_sessionFolder = fullfile(local_savePath,fullSessionName);
            cd(vidSessionFolder);

            vidList = dir([sessionsToExtract(iSess).ratID,'*.avi']);
            if isempty(vidList); continue; end

            numVidsExtracted = 0;
            %pick videos at random
            if ~extractFullSession

                while numVidsExtracted < numVidstoExtract
                    frameTimeLimits = [-1,3.3];
                    currentVidNumber = floor(rand * length(vidList)) + 1;
                    vidName = vidList(currentVidNumber).name;
                    vidNameNumber = vidName(end-6:end-4);
                    destVidName = cell(1,length(viewSavePath));
                    for iView = 1 : length(viewSavePath)
                        destVidName{iView} = fullfile(viewSavePath{iView}, [vidName(1:end-4),'_',viewList{iView}]);
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

                    cropVideo(vidName,destVidName,frameTimeLimits,triggerTime,ROI);       

                    numVidsExtracted = numVidsExtracted + 1;
                end   
            else                   
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
    %                 cropVideo(vidName,destVidName,frameTimeLimits,triggerTime,ROI);

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
                        full_metadata_name{3} = fullfile(local_viewPath,metadata_name);
                        for ii = 1 : 3
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

    end 
end
%%
% save metadata files
% if strcmpi(selectTattoo,'yes')
%     fname = [ratID '_' selectPawPref, '_paw_tattooed_', digitColors, '_metadata.mat'];
% else
%     fname = [ratID '_' selectPawPref, '_paw_markerless_metadata.mat'];
% end
% for i_vidDest = 1 : length(viewSavePath)
%     cd(viewSavePath{iView});
%     save(fname,'triggerTime','frameTimeLimits','viewList','ROI');
% end
% 
% timeToCompute = toc;