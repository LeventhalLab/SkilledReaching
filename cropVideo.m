function cropVideo(videoFile, pixelBounds)
    video = VideoReader(videoFile);
    [videoPath videoName videoExt] = fileparts(videoFile);
    
    writeVideos = struct;
    % setup video writers
    fields = fieldnames(pixelBounds);
    for i=1:size(fields,1)
        saveVideoAs = fullfile(videoPath,strcat(videoName,'_',fields(i),videoExt));
        writeVideos.(fields{i}) = VideoWriter(saveVideoAs{1}, 'Motion JPEG AVI');
        writeVideos.(fields{i}).Quality = 100;
        writeVideos.(fields{i}).FrameRate = 150;
        open(writeVideos.(fields{i}));
    end
    
    for i = 1:2%video.NumberOfFrames
        disp(i)
        % read
        image = read(video, i);
        % white balance
        pageSize = size(image,1) * size(image,2);
        avgRgb = mean(reshape(image, [pageSize,3]));
        avgAll = mean(avgRgb);
        scaleArray = max(avgAll, 128)./avgRgb;
        scaleArray = reshape(scaleArray,1,1,3);
        wbImage = uint8(bsxfun(@times,double(image),scaleArray));
        % crop
        for i=1:size(fields,1)
            coords = pixelBounds.(fields{i}); % left top width height
            croppedImage = wbImage(coords(2):(coords(2)+coords(4)),...
                coords(1):(coords(1)+coords(3)),:);
            writeVideo(writeVideos.(fields{i}), croppedImage);
        end
    end
    
    for i=1:size(fields,1)
        close(writeVideos.(fields{i}));
    end
end