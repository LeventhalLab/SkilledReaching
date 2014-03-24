function overlayMasks(colorData, videoFile, saveVideoFileAs)
    video = VideoReader(videoFile);

    newVideo = VideoWriter(saveVideoFileAs, 'Motion JPEG AVI');
    newVideo.Quality = 85;
    newVideo.FrameRate = 25;
    open(newVideo);

    fields = fieldnames(colorData);
    for i = 1:video.NumberOfFrames
        image = read(video, i);
        for j=1:size(fields,1)
           temp = zeros(1,1,3);
           temp = insertShape(temp,'Rectangle',[1 1 1 1],'Color',char(fields(j)));
           mask = colorData.(fields{j}).masks(:,:,i);
           image = imoverlay(image,edge(mask),reshape(temp(1,1,:),1,3));
        end
        writeVideo(newVideo,image);
    end
    close(newVideo);
end