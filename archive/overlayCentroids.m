function overlayCentroids(colorData, videoFile, saveVideoFileAs)
    video = VideoReader(videoFile);

    newVideo = VideoWriter(saveVideoFileAs, 'Motion JPEG AVI');
    newVideo.Quality = 85;
    newVideo.FrameRate = 25;
    open(newVideo);

    fields = fieldnames(colorData);
    for i = 1:video.NumberOfFrames
        image = read(video, i);
        for j=1:size(fields,1)
           clean = cleanCentroids(colorData.(fields{j}).centroids);
           image = insertShape(image,'Circle',[clean(i,:),4],'Color',fields{j});
        end
        writeVideo(newVideo,image);
    end
    close(newVideo);
end