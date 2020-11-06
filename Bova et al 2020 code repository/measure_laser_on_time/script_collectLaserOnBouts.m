% script_collectLaserOnBouts

% Script scans skilled reaching camcorder videos for frames where the laser is on 
% & breaks into "bouts" by finding first and last frames of consecutive
% laser on frames. The functions checkShortLaserOnBlocks and
% checkForOutofFrameLaser try to find bouts where the rat's head with fiber
% may have gone out of frame or other errors where bouts may be identified
% incorrectly. However, this is not always perfect and therefore videos
% should be scanned to check accuracy after.


% folder with labview videos
rawDataFolder = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';

videoFolder = '/Volumes/DLC_data/camcorder videos'; % folder w/ camcorder videos
cd(videoFolder)

ratFolders = dir('R0*'); 
numRats = length(ratFolders);

colVal = 3; % set to 3 for blue, set to 2 for green

for i_rat = 1 : numRats % change if you want to scan specific rats
    
    camRatFolder = fullfile(videoFolder,ratFolders(i_rat).name);
    cd(camRatFolder)    % go to current rat's video folder
    
    videoNames = dir('R0*');
    numVideos = length(videoNames);
    
    ratID = ratFolders(i_rat).name;
    
    ratSummary.ratID = ratID;
    ratSummary.laserOnFrames = NaN(100,2,numVideos);
    ratSummary.laserOnDurations = NaN(100,1,numVideos);

    for iVideo = 1 : numVideos
        
        cd(camRatFolder)

        curVideoName = videoNames(iVideo).name;
        curVideo = VideoReader(curVideoName);   % load in current video
        numFrames = get(curVideo,'NumberOfFrames'); % find number of frames in video
        frameRate = get(curVideo,'FrameRate');  % get frame rate of video

        sessionDate = curVideoName(7:14);   % identify session date
        sessionFolderName = sprintf('%s_%sa',ratID,sessionDate);

        curRatFolder = fullfile(rawDataFolder,ratID);
        curSessFolder = fullfile(curRatFolder,sessionFolderName);

        cd(curSessFolder)   % go to session folder of labview videos to get number of trials in session
        trialVideos = dir('*.avi');
        numTrials = length(trialVideos);

        framesWithLight = NaN(1,numFrames);

        for iFrame = 1301:7500 %numFrames
    
            imagedata = read(curVideo,iFrame);  % read in data for current frame
            imagedata = imagedata./1.3;   % reduce brightness of current frame

            % extract the Blue color from grayscale image
            diff_im = imsubtract(imagedata(:,:,colVal),rgb2gray(imagedata));
            % Filtering the noise
            diff_im = medfilt2(diff_im,[3,3]);
            % Converting grayscale image into binary image
            diff_im = im2bw(diff_im,0.18);
            % Draw rectangular boxes around the blue/green object detected & label image
            bw=bwlabel(diff_im,8);

            stats=regionprops(bw,'BoundingBox','Centroid');

            % uncomment if you want to show the frame image and where the
            % code identified blue or green
%             imshow(imagedata)
%             hold on
%                 
%             for object=1:length(stats) % plots a rectangle around area identified as blue - not necessary but useful for checking code 
%                 %saving data of centroid and boundary in BB & BC 
%                 bb=stats(object).BoundingBox;
%                 bc=stats(object).Centroid;
%                 %Draw the rectangle with data BB & BC
%                 rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
%                 %Plot the rectangle output
%                 plot(bc(1),bc(2),'-m+')
%                 %Output X&Y coordinates
%                 a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
%     
%             end

            if isempty(stats)   % if did not find any blue/green mark frame as 0, if did find blue/green mark frame as 1
                framesWithLight(1,iFrame) = 0;
            else
                framesWithLight(1,iFrame) = 1;
            end 

        end 

        actualLaserOnFrames = findLaserOnBlocks(framesWithLight);  % looks for consecutive frames w/ "laser on" and records start and stop frames
        trueLaserOnFrames = checkShortLaserOnBlocks(actualLaserOnFrames,curVideo,numTrials,frameRate,colVal);  % start to check for errors by identifying very short laser on bouts and checking for frames where rat may have been out of rame

        if length(trueLaserOnFrames) > numTrials    % still more trials? could be long bouts with laser out of frame in middle
            trueLaserOnFrames = checkForOutofFrameLaser(trueLaserOnFrames,curVideo,colVal);
        end

        laserOnDurations = (trueLaserOnFrames(:,2) - trueLaserOnFrames(:,1))/frameRate;	% calculate duration of time (sec) that laser was on for each bout

        ratSummary.laserOnFrames(1:size(laserOnDurations,1),:,iVideo) = trueLaserOnFrames;  % save to summary with all rats
        ratSummary.laserOnDurations(1:size(laserOnDurations,1),:,iVideo) = laserOnDurations;
        
        clear actualLaserOnFrames
        clear trueLaserOnFrames
        clear laserOnDurations

    end 
    
    % save all rat summary
    saveOutputFolder = fullfile(videoFolder,'duration_output');
    cd(saveOutputFolder)   
    
    ratSummaryName = sprintf('%s_duration_summary.mat',ratID);
    
    save(ratSummaryName,'ratSummary')
    
    clear ratSummary

end 

% uncomment if you want a sound to play to indicate code is done
% load handel
% sound(y,Fs)