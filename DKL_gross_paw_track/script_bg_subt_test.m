% script to check background subtraction

fcount = 0;
while video.CurrentTime < video.Duration
    fcount = fcount + 1;
    image = readFrame(video);
    image_ud = undistortImage(image, cameraParams);
    
    BGdiff = imabsdiff(image_ud,BGimg_ud);
    figure(1);

    imshow(BGdiff);
end