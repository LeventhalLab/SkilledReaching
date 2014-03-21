function testColorBlob(videoFile,hsvBounds)
    video = VideoReader(videoFile);
    for i=1:video.NumberOfFrames
        image = read(video,i);
        hsv = rgb2hsv(image);

        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % bound the hue element using all three bounds
        h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
        h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
        h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;

        %h(manualMask==0) = 0;

        mask = bwdist(h) < 5;
        mask = imfill(mask, 'holes');
        %mask = imerode(mask, strel('disk',4));
        imshow(mask)
    end
end