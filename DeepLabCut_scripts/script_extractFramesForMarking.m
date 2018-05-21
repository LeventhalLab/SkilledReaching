% script to randomly select videos, crop them, and store frames for marking
% paws in Fiji (or whatever else we decide to use)


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
triggerTime = 1;    % seconds
frameTimeLimts = [-1/3,2/3];    % time around trigger to extract frames

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

numFramestoMark = 100;

script_ratInfo_for_deepcut;
numRats = length(ratInfo);

% first row for direct view, second row left view, third row right view
% format [a,b,c,d] where (a,b) is the upper left corner and (c,d) is
% (width,height)

ROI = [800,600,500,350;
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
for iRat = 1 : numValidRats
    numRatSessions = length(validRatInfo(iRat).sessionList);
    
    numValidSessions = 0;
    firstTattooDate = validRatInfo(iRat).firstTattooedSession;
    firstTattooDateNum = datenum(firstTattooDate,'yyyymmdd');
    validSessionList = {};
    for iRatSession = 1 : numRatSessions
        currentSessionDate = validRatInfo(iRat).sessionList{iRatSession}(7:end-1);
        currentSessionDateNum = datenum(currentSessionDate,'yyyymmdd');
        
        switch selectTattoo
            case 'no'
                if currentSessionDateNum < firstTattooDateNum
                    numValidSessions = numValidSessions + 1;
                    validSessionList{numValidSessions} = validRatInfo(iRat).sessionList{iRatSession};
                end
            otherwise
                if currentSessionDateNum >= firstTattooDateNum
                    numValidSessions = numValidSessions + 1;
                    validSessionList{numValidSessions} = validRatInfo(iRat).sessionList{iRatSession};
                end
        end
    end
    
    for iRatSession = 1 : numValidSessions
        ratSessionFolder = fullfile(rootPath,validRatInfo(iRat).IDstring,validSessionList{iRatSession});
        cd(ratSessionFolder);

        vidList = dir([ratInfo(iRat).IDstring ,'*.avi']);
        
        % pick a video at random
        currentVidNumber = ceil(rand(1,1) * ratInfo(iRat).numVids(iSession));
        vidName = vidList(currentVidNumber).name;
        
        video = VideoReader(vidName);
        
        cur_img = readRandomFrame( video, 'triggertime', 1, 'frametimelimits', frameTimeLimits);
        curFrame = round(video.CurrentTime * video.FrameRate) - 1;
        curFrameStr = sprintf('%003d',num2str(curFrame));
        
        close(video);
        
        % crop out bits
        cropped_img = cell(1,3);
        for iView = 1 : 3
        	cropped_img{iView} = cur_img(ROI(iView,2) : ROI(iView,2) + ROI(iView,4), ...
                                         ROI(iView,1) : ROI(iView,1) + ROI(iView,3), :);
            switch iView
                case 1
                    cd(directViewSavePath)
                    vidName = [validSessionList{iRatSession} '_' curFrameStr '_directView.png'];
                case 2
                    cd(leftViewSavePath)
                    vidName = [validSessionList{iRatSession} '_' curFrameStr '_leftView.png'];
                case 3
                    cd(rightViewSavePath)
                    vidName = [validSessionList{iRatSession} '_' curFrameStr '_rightView.png'];
            end
            
            imwrite(vidName,'png');
        end
        
    end
    
end