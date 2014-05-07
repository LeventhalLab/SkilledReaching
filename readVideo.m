function [video,im]=readVideo(frameNumber)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    
    if(exist('frameNumber','var'))
        im = read(video,frameNumber);
        figure;
        imshow(im);
    else
        im = read(video,1);
    end
end