function cropVideo(videoFile, saveVideoAs, bounds)
    incomingVideo = VideoReader(videoFile);
    outgoingVideo = VideoWriter(saveVideoAs, 'Motion JPEG AVI');
    outgoingVideo.Quality = 100;
    outgoingVideo.FrameRate = 150;
    open(outgoingVideo);
    
    left = bounds(1);
    top = bounds(2);
    width = bounds(3);
    height = bounds(4);
    
    for i = 1:incomingVideo.NumberOfFrames
        % read
        image = read(incomingVideo, i);
        % white balance
        pageSize = size(image,1) * size(image,2);
        avgRgb = mean(reshape(image, [pageSize,3]));
        avgAll = mean(avgRgb);
        scaleArray = max(avgAll, 128)./avgRgb;
        scaleArray = reshape(scaleArray,1,1,3);
        wbImage = uint8(bsxfun(@times,double(image),scaleArray));
        % crop
        croppedImage = wbImage(top:(top+height), left:(left+width), :);
        % save
        writeVideo(outgoingVideo, croppedImage);
    end
    
    close(outgoingVideo);
end