function overlayCentroids(videoFile, centroids)
    video = VideoReader(videoFile);

%     combinedVideo = VideoWriter('R0000_20140308_11-49-12_008_MIDDLE_alltracks.avi', 'Motion JPEG AVI');
%     combinedVideo.Quality = 85;
%     combinedVideo.FrameRate = 25;
%     open(combinedVideo);

    for i = 1:video.NumberOfFrames
        disp(i)
        image = read(video, i);
        
        if(~isnan(centroids(i,1)))
            image = annotateImage(image, centroids(i,:), 'o', 'red');
        end
%         writeVideo(combinedVideo, im2frame(image));
        imshow(image)
    end
%     close(combinedVideo);
end

function [annotatedImage] = annotateImage(image, coordinates, label, color)
    annotatedImage = insertObjectAnnotation(image, 'circle', ...
                        [coordinates,2], label, 'Color', color);
end