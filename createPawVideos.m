function createPawVideos(nVideos,saveVideoAs)
    matchScore = 2;
    disp('Select folder...');
    workingDirectory = uigetdir;
    scoreLookup = dir(fullfile(workingDirectory,'*.csv'));
    scoreData = csvread(fullfile(workingDirectory,scoreLookup(1).name));
    successIndexes = find(scoreData(:,2)==matchScore);
    videoIndexes = zeros(nVideos,1);
    maxVideos = min([nVideos,numel(successIndexes)]);
    % get random sample of videos
    for i=1:maxVideos
        videoIndexes(i) = datasample(successIndexes,1);
        % remove so it is not double sampled
        successIndexes = removerows(successIndexes,find(successIndexes==videoIndexes(i)));
    end

    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);
    cropPixels = 100;
    allVideos = dir(fullfile(workingDirectory,'center','*.avi'));
    for i=1:maxVideos
        video = VideoReader(fullfile(workingDirectory,'center',allVideos(videoIndexes(i)).name));
        if(i==1)
            figure;
            imshow(read(video,150));
            disp('Select point of interest...');
            [x,y] = ginput;
            x = round(x);
            y = round(y);
            close;
        end
        disp(['Writing i=',num2str(i),', trial=',num2str(videoIndexes(i))]);
        workingDirectoryParts = strsplit(workingDirectory,filesep);
        for j=140:200
            im = read(video,j);
            im = im((y-cropPixels):(y+cropPixels),(x-cropPixels):(x+cropPixels),:);
            trialTitle = [workingDirectoryParts{end},', v',num2str(videoIndexes(i))];
            im = insertText(im,[1 1],trialTitle);
            writeVideo(newVideo,im);
        end
    end
    
    close(newVideo);
    winopen(saveVideoAs);
end