function createPawVideos(nVideos,saveVideoAs,matchScore)
    disp('Select vidoes folder...');
    videosDirectory = uigetdir;
    disp('Select score file...');
	[f,p] = uigetfile('*.csv');
    scoreData = scoreVideoData(fullfile(p,f),videosDirectory);
    
    videoIndexes = find([scoreData{:,2}]==matchScore);
    maxVideos = min([nVideos,numel(videoIndexes)]);
    % get random sample of videos
    randomVideoTrials = datasample(videoIndexes,maxVideos,'Replace',false)';

    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);
    cropPixels = 100;
    for i=1:maxVideos
        video = VideoReader(scoreData{randomVideoTrials(i),3});
        if(i==1)
            figure;
            imshow(read(video,150));
            disp('Select point of interest...');
            [x,y] = ginput;
            x = round(x);
            y = round(y);
            close;
        end
        disp(['Writing i=',num2str(i),', trial=',num2str(randomVideoTrials(i))]);
        workingDirectoryParts = strsplit(videosDirectory,filesep);
        for j=140:240
            im = read(video,j);
            im = im((y-cropPixels):(y+cropPixels),(x-cropPixels):(x+cropPixels),:);
            trialTitle = [workingDirectoryParts{end},', t',num2str(randomVideoTrials(i))];
            im = insertText(im,[1 1],trialTitle);
            writeVideo(newVideo,im);
        end
    end
    
    close(newVideo);
    winopen(saveVideoAs);
end