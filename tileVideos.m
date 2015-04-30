% first, use createPawVideos.m to make individual videos with the same
% width/height, then merge them into tiles with this
function tileVideos(nVideos,saveVideoAs)
    videoFrames = {};
    for ii=1:nVideos
        [videoName,videoPath] = uigetfile('*.avi');
        disp(videoName);
        videoFile = fullfile(videoPath,videoName);
        video = VideoReader(videoFile);
        
        for jj=1:video.NumberOfFrames
            if(ii==1)
                videoFrame = zeros(video.Height,video.Width*nVideos,3);
            else
                videoFrame = videoFrames{jj};
            end
            im = read(video,jj);
            colStart = ((ii-1)*video.Width)+1;
            colEnd = (colStart + video.Width)-1;
            videoFrame(:,colStart:colEnd,:) = im(:,:,:);
            videoFrames{jj} = uint8(videoFrame);
        end
    end
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);
    for ii=1:video.NumberOfFrames
        writeVideo(newVideo,videoFrames{ii});
    end
    close(newVideo);
end