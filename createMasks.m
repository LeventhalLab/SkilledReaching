function createMasks(videoFile, saveInitMaskAs, saveColorMaskAs)
    obj = VideoReader(videoFile);
    avgImage = read(obj, 1);
    setupInitMask = avgImage;
    setupInitMask(:,:,1) = 0;
    initMask = logical(setupInitMask(:,:,1));

    for i = 1:obj.NumberOfFrames
        image = read(obj, i);
        avgImage = mean([avgImage image]);
        hsv = rgb2hsv(image);

        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        h(h < .25 | h > .45) = 0;
        h(s < .15) = 0;
        h(v < .07) = 0;

        h = imopen(h, strel('disk', 10, 0));
        h = imfill(h, 'holes');
        h = imdilate(h, strel('disk', 17, 0));

        initMask = initMask | logical(h);
        imshow(logical(initMask))
    end

    imwrite(saveInitMaskAs, saveColorMaskAs);
end