% script to crop video with the same ROI as the extracted frames

% script to randomly select videos, crop them, and store frames for marking
% paws in Fiji (or whatever else we decide to use)


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not
%%
tic

repeatCalculations = false;   % if cropped video file already exists, don't repeat

ratID = 'R0159';

% rootPath = fullfile('/Volumes/RecordingsLeventhal04/SkilledReaching');
rootPath = fullfile('/Volumes/Tbolt_01/Skilled Reaching');
triggerTime = 1;    % seconds
frameTimeLimits = [-1,3.3];    % time around trigger to extract frames
numVidstoExtract = 2;

% set to true if you want to extract videos at random, or to false if you
% want to specify which sessions to extract videos from (below)
selectRandomVideos = false;
extractFullSession = true;

% which types of videos to extract? left vs right paw, tat vs no tat 
selectPawPref = 'left';
selectTattoo = 'yes';
digitColors = 'gbypr';   % order of colors on the digits (digits 1-4 and dorsum of paw).
                         % g = green, p = purple, b = blue, y = yellow, r = red

if strcmpi(selectTattoo,'yes')
    savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching',[ratID '_cropped'],[selectPawPref, '_paw_tattooed_', digitColors]);
else
    savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching',[ratID '_cropped'],[selectPawPref, '_paw_markerless']);
end 

% if ~exist(savePath,'dir')
%     mkdir(savePath);
% end

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

ROI = [750,450,550,550;
       1,450,450,400;
       1650,435,390,400];

% ultimately, randomly select videos and times for cropping out images to
% make a stack

% first step will be to make a list of tattooed and non-tattooed sessions

% DL modifications for using the ratInfo table
validRatInfo = findSubTable(ratInfo,'pawPref',selectPawPref,'digitColors',digitColors);
numValidRats = size(validRatInfo,1);

% numValidRats = 0;
% for iRat = 1 : numRats
%     if strcmpi(ratInfo(iRat).pawPref, selectPawPref) && ...
%        strcmpi(ratInfo(iRat).digitColors, digitColors)
%         numValidRats = numValidRats + 1;
%         validRatInfo(numValidRats) = ratInfo(iRat);
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% list of videos to extract if selectRandomVideos = false;
% desigante the Rat and the Session Date but will then randomly select the
% number of videos set by numVidsttoExtract (above) 

% you should extract videos of rats w/ same paw pref and tattoos at the
% same time (make sure to change above so that videos save to correct
% folders)
ii = 0;
if ~selectRandomVideos
    
%     ii = ii + 1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170420a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170421a'; 
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170424a'; 
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170425a'; 
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170426a';
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170427c'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170428c'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170430a'; 
%     
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170501a';
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170502a'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170503a'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170504a'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170505a';
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170506a';
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170509b';
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170510a'; 
    
    ii = ii+1;
    sessionsToExtract(ii).ratID = ratID;
    sessionsToExtract(ii).session = '20170511a'; 
    
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170520a'; 
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170521a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170523a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170524a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170525a';
% 
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170527a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170528a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20170605a';
    
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20181128a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20181129a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20181130a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20180626a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20180627a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20180628a';
%     
%     ii = ii+1;
%     sessionsToExtract(ii).ratID = ratID;
%     sessionsToExtract(ii).session = '20180629a';
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

        ratSessionFolder = fullfile(rootPath,validRatInfo(validRatIdx).IDstring,validSessionList{validSessionIdx});
        cd(ratSessionFolder);

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
    
    for iSess = 1:length(sessionsToExtract)
        
%         ratSessionFolder = fullfile(rootPath,sessionsToExtract(iSess).ratID,[sessionsToExtract(iSess).ratID '-rawdata'],[sessionsToExtract(iSess).ratID '_' sessionsToExtract(iSess).session]);
        ratSessionFolder = fullfile(rootPath,sessionsToExtract(iSess).ratID,[sessionsToExtract(iSess).ratID '_' sessionsToExtract(iSess).session]);
        cd(ratSessionFolder);
        
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
                    destVidName{iView} = fullfile(viewSavePath{iView}, [vidName(1:end-4),'_',viewList{iView}]);
                end
                
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

            end
        end 
    end 
    
end 
%%
% save metadata files
if strcmpi(selectTattoo,'yes')
    fname = [selectPawPref, '_paw_tattooed_', digitColors, '_metadata.mat'];
else
    fname = [selectPawPref, '_paw_markerless_metadata.mat'];
end
for i_vidDest = 1 : length(viewSavePath)
    cd(viewSavePath{iView});
    save(fname,'triggerTime','frameTimeLimits','viewList','ROI');
end

timeToCompute = toc;