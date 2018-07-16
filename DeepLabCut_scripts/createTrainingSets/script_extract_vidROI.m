% script to crop video with the same ROI as the extracted frames

% script to randomly select videos, crop them, and store frames for marking
% paws in Fiji (or whatever else we decide to use)


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
triggerTime = 1;    % seconds
frameTimeLimits = [-1/2,1];    % time around trigger to extract frames
numVidsttoExtract = 30;

% which types of videos to extract? left vs right paw, tat vs no tat
selectPawPref = 'left';
selectTattoo = 'yes';

savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','deepLabCut_testing_vids',[selectPawPref, '_paw_', selectTattoo, '_tattoo']);
% if ~exist(savePath,'dir')
%     mkdir(savePath);
% end

leftViewSavePath = fullfile(savePath, 'left_view');
directViewSavePath = fullfile(savePath, 'direct_view');
rightViewSavePath = fullfile(savePath, 'right_view');
if ~exist(leftViewSavePath,'dir')
    mkdir(leftViewSavePath);
end
if ~exist(directViewSavePath,'dir')
    mkdir(directViewSavePath);
end
if ~exist(rightViewSavePath,'dir')
    mkdir(rightViewSavePath);
end

script_ratInfo_for_deepcut;
numRats = length(ratInfo);

% first row for direct view, second row left view, third row right view
% format [a,b,c,d] where (a,b) is the upper left corner and (c,d) is
% (width,height)

ROI = [750,500,550,500;
       1,550,450,350;
       1650,550,390,350];

% ultimately, randomly select videos and times for cropping out images to
% make a stack

% first step will be to make a list of tattooed and non-tattooed sessions

numValidRats = 0;
for iRat = 1 : numRats
    if strcmpi(ratInfo(iRat).pawPref, selectPawPref)
        numValidRats = numValidRats + 1;
        validRatInfo(numValidRats) = ratInfo(iRat);
    end
end

numVidsExtracted = 0;
while numVidsExtracted < numVidsttoExtract

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
    
    destVidName{1} = fullfile(directViewSavePath, [vidName(1:end-4),'_direct']);
    destVidName{2} = fullfile(leftViewSavePath, [vidName(1:end-4),'_left']);
    destVidName{3} = fullfile(rightViewSavePath, [vidName(1:end-4),'_right']);

    cropVideo(vidName,destVidName,frameTimeLimits,triggerTime,ROI);
    
    numVidsExtracted = numVidsExtracted + 1;

end