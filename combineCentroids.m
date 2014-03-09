load('data_centroids_red.mat');
centroids_red = data_centroids;

load('data_centroids_yellow.mat');
centroids_yellow = data_centroids;

load('data_centroids_blue.mat');
centroids_blue = data_centroids;

load('data_centroids_green.mat');
centroids_green = data_centroids;

video = VideoReader('R0000_20140308_11-49-12_008_MIDDLE.avi');

combinedVideo = VideoWriter('R0000_20140308_11-49-12_008_MIDDLE_alltracks.avi', 'Motion JPEG AVI');
combinedVideo.Quality = 85;
combinedVideo.FrameRate = 25;
open(combinedVideo);

for i = 1:video.NumberOfFrames
    image = read(video, i);
    if(~isnan(centroids_red(:,1,i)))
        image = insertObjectAnnotation(image, 'circle', ...
                    [centroids_red(:,:,i),2], 'r', 'Color', 'red');
    end
    if(~isnan(centroids_yellow(:,1,i)))
        image = insertObjectAnnotation(image, 'circle', ...
                    [centroids_yellow(:,:,i),2], 'y', 'Color', 'yellow');
    end
    if(~isnan(centroids_blue(:,1,i)))
        image = insertObjectAnnotation(image, 'circle', ...
                    [centroids_blue(:,:,i),2], 'b', 'Color', 'blue');
    end
    if(~isnan(centroids_green(:,1,i)))
        image = insertObjectAnnotation(image, 'circle', ...
                    [centroids_green(:,:,i),2], 'g', 'Color', 'green');
    end
    writeVideo(combinedVideo, im2frame(image));
    imshow(image)
    disp(i)
end

close(combinedVideo);