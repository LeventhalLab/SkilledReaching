function tileVideos(nVideos,saveVideoAs)
    videoFrames = {};
    for i=1:nVideos
        [videoName,videoPath] = uigetfile('*.avi');
        disp(videoName);
        videoFile = fullfile(videoPath,videoName);
        video = VideoReader(videoFile);
        
        for j=1:video.NumberOfFrames
            if(i==1)
                videoFrame = zeros(video.Height,video.Width*nVideos,3);
            else
                videoFrame = videoFrames{j};
            end
            im = read(video,j);
            colStart = ((i-1)*video.Width)+1;
            colEnd = (colStart + video.Width)-1;
            videoFrame(:,colStart:colEnd,:) = im(:,:,:);
            videoFrames{j} = uint8(videoFrame);
        end
    end
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);
    for i=1:video.NumberOfFrames
        writeVideo(newVideo,videoFrames{i});
    end
    close(newVideo);
    winopen(saveVideoAs);
end