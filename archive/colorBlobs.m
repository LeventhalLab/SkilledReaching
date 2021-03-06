function [colorData] = colorBlobs(videoFile, hsvBounds)
    video = VideoReader(videoFile);
    
    colorData = struct;
    fields = fieldnames(hsvBounds);
    % setup zero matrices as placeholders
    for i=1:size(fields,1)
       colorData.(fields{i}).masks = zeros(video.Height,video.Width,video.NumberOfFrames);
       colorData.(fields{i}).centroids = zeros(video.NumberOfFrames,2);
    end

    for i=200:video.NumberOfFrames
        disp(i)
        image = read(video, i);
        for j=1:size(fields,1)
            [colorData.(fields{j}).masks(:,:,i),colorData.(fields{j}).centroids(i,:)] = ...
                isolatedColorMask(image,hsvBounds.(fields{j}));
        end
    end
end

function [mask, centroid] = isolatedColorMask(image, hsvBounds)
    hsv = rgb2hsv(image);

    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
    h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
    h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;
    
    imshow(h)
    
    mask = bwdist(h) < 10;
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk',7));
    
    % if multiple regions are found and one is larger than the other, this
    % builds a radius mask, essentially to fight off stray noise. It
    % 'follows' the largest blob around if needed.
    
    
%     mask = imopen(mask, strel('disk', 15, 0));
%     mask = imclose(mask, strel('disk', 15, 0));

    CC = bwconncomp(mask);
    L = labelmatrix(CC);
    props = regionprops(L, 'Area', 'Centroid');
    
%     ellipse(props.MajorAxisLength,props.MinorAxisLength,deg2rad(props.Orientation),...
%         props.Centroid(1,1),props.Centroid(1,2));
    
    
    
    
    if(~isempty(props))
        maxArea = max([props.Area]);
        maxIndex = find([props.Area]==maxArea);
        centroids = vec2mat([props.Centroid],2);
        for i=1:size(centroids,1)
            if(pdist([centroids(maxIndex,:);centroids(i,:)])>250)
                % remove centroids
                %centroids = removerows(centroids, i);
                % black out far pixels
                mask(CC.PixelIdxList{i}) = 0;
            end
        end
        centroid = [mean(centroids(:,1)), mean(centroids(:,2))];
    else
        centroid = [NaN NaN];
    end
    
    
    
%     temp = image;
%     r=image(:,:,1);
%     r(mask > 0) = 1;
%     temp(:,:,1)=r;
%     imshow(temp)
end