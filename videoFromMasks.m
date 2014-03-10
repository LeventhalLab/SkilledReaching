function videoFromMasks(masks, videoFile, hue, saveVideoAs)
    video = VideoReader(videoFile);
    
    saveVideo = VideoWriter(saveVideoAs);
    saveVideo.Quality = 85;
    saveVideo.FrameRate = 25;
    open(saveVideo);
    
    maskSize = size(masks);
    for i=1:maskSize(3)
        image = read(video, i);
        coloredImage = applyColorMask(image, masks(:,:,i), hue);
        imshow(coloredImage)
        writeVideo(saveVideo, coloredImage);
        disp(i)
    end
    close(saveVideo);
end

function [coloredImage] = applyColorMask(image, mask, hue)
    hsv = rgb2hsv(image);
    edgeMask = edge(mask);
    edgeMask = imdilate(edgeMask, strel('disk', 1, 0));
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    h(edgeMask > 0) = hue;
    s(edgeMask > 0) = .75;
    v(edgeMask > 0) = 1;
    hsv(:,:,1) = h;
    hsv(:,:,2) = s;
    hsv(:,:,3) = v;
    coloredImage = hsv2rgb(hsv);
end