function allMasks = colorBlob(videoFile, hsvBounds)
    video = VideoReader(videoFile);
    allMasks = zeros(video.Height, video.Width, video.NumberOfFrames);
    for i = 1:video.NumberOfFrames
        disp(i)
        allMasks(:,:,i) = isolatedColorMask(read(video, i), hsvBounds);
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
    
    mask = bwdist(h) < 10;
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk',7));
    
    % if multiple regions are found and one is larger than the other, this
    % builds a radius mask, essentially to fight off stray noise. It
    % 'follows' the largest blog around if needed.
    L = labelmatrix(bwconncomp(mask));
    props = regionprops(L, 'Area', 'Centroid');
    if(~isempty(props))
        maxArea = max([props.Area]);
        maxIndex = find([props.Area]==maxArea);
        %centroids = reshape([props.Centroid],numel([props.Centroid])/2,2);

        centroids = [props.Centroid];
        noiseMask = mask.*0;
        if(maxArea > 50)
            noiseMask = insertShape(noiseMask, 'FilledCircle',...
                [centroids(maxIndex:maxIndex+1) 40], 'Color', 'white');
        end
        mask = mask & im2bw(noiseMask,0);
    end
    %imshow(mask)
end