% script to randomly select videos, crop them, and store frames for marking
% paws in Fiji (or whatever else we decide to use)


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
triggerTime = 1;    % seconds
frameTimeLimits = [-1/3,1/2];    % time around trigger to extract frames
numFramesttoExtract = 200;

% which types of videos to extract? left vs right paw, tat vs no tat
selectPawPref = 'left';
selectTattoo = 'no';

savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','deepLabCut_training_frames',[selectPawPref, '_paw_', selectTattoo, '_tattoo']);
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


% hard code coordinates for cropping direct view, left mirror, right mirror
triggerFrame = 300;
frameRange = [200,500];

% ultimately, randomly select videos and times for cropping out images to
% make a stack

% first step will be to make a list of tattooed and non-tattooed sessions

frameStack_tat_left = cell(1,3);
frameStack_tat_right = cell(1,3);
frameStack_notat_left = cell(1,3);
frameStack_notat_right = cell(1,3);

numValidRats = 0;
for iRat = 1 : numRats
    if strcmpi(ratInfo(iRat).pawPref, selectPawPref)
        numValidRats = numValidRats + 1;
        validRatInfo(numValidRats) = ratInfo(iRat);
    end
end

numFramesExtracted = 0;
while numFramesExtracted < numFramesttoExtract

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

    video = VideoReader(vidName);

    cur_img = readRandomFrame( video, 'triggertime', 1, 'frametimelimits', frameTimeLimits);
    curFrame = round(video.CurrentTime * video.FrameRate) - 1;
    curFrameStr = sprintf('%03d',curFrame);

    clear video
        
    % crop out bits
    cropped_img = cell(1,3);
    cropBaseName = [validSessionList{validSessionIdx} '_vid' vidNameNumber '_frame' curFrameStr];
    
    for iView = 1 : 3
        cropped_img{iView} = cur_img(ROI(iView,2) : ROI(iView,2) + ROI(iView,4), ...
                                     ROI(iView,1) : ROI(iView,1) + ROI(iView,3), :);
                                 
        switch iView
            case 1
                cropFrameName = fullfile(directViewSavePath,[cropBaseName '_directView.png']);
            case 2
                cropFrameName = fullfile(leftViewSavePath,[cropBaseName '_leftView.png']);
            case 3
                cropFrameName = fullfile(rightViewSavePath,[cropBaseName '_rightView.png']);
        end

        imwrite(cropped_img{iView},cropFrameName,'png');
    end
    cd(directViewSavePath)
    frameList = dir('*.png');
    numFramesExtracted = length(frameList);
%     numFramesExtracted = numFramesExtracted + 1;

end