function allMasks = colorBlob(videoFile, hsvBounds)
    video = VideoReader(videoFile);
    allMasks = zeros(video.Height, video.Width, 100);%video.NumberOfFrames);
    for i = 100:200%video.NumberOfFrames
        allMasks(:,:,i) = isolatedColorMask(read(video, i), hsvBounds);
        disp(i)
    end
end

function [mask] = isolatedColorMask(image, hsvBounds)
    hsv = rgb2hsv(image);

    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
    h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
    h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;

    % this is an attempt to remove any small color noise using imopen
    % to first close those colors, then open them. Finally, the
    % dilation creates large boundaries for the paw to move within
    blobMask = imopen(h, strel('disk', 1, 0));
    blobMask = imfill(blobMask, 'holes');
    blobMask = imdilate(blobMask, strel('disk', 17, 0));
    blobMask = logical(blobMask);
    %imshow(blobMask);

    % mask used for paw shape
    pawMask = imclose(h, strel('disk', 1, 0));
    pawMask = imfill(pawMask, 'holes');
    pawMask = imdilate(pawMask, strel('disk', 3, 0));
    pawMask = logical(pawMask);

    mask = blobMask & pawMask;
    mask = imfill(mask, 'holes');
end