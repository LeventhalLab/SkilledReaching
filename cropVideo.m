function [savedVideoPaths] = cropVideo(videoFile,pixelBounds)
    video = VideoReader(videoFile);
    [videoPath,videoName,videoExt] = fileparts(videoFile);
    
    savedVideoPaths = struct;
    writeVideos = struct;
    % setup video writers
    fields = fieldnames(pixelBounds);
    for i=1:size(fields,1)
        newDir = fullfile(videoPath,char(fields(i)));
        mkdir(newDir);
        saveVideoAs = fullfile(newDir,strcat('cropped_',char(fields(i)),'_',videoName,videoExt));
        savedVideoPaths.(fields{i}) = saveVideoAs;
        writeVideos.(fields{i}) = VideoWriter(saveVideoAs,'Motion JPEG AVI');
        writeVideos.(fields{i}).Quality = 100;
        writeVideos.(fields{i}).FrameRate = 30;
        open(writeVideos.(fields{i}));
    end
    
    for i=1:video.NumberOfFrames
        disp(['Writing... ' num2str(i)])
        image = read(video, i);
        % white balance
        pageSize = size(image,1) * size(image,2);
        avgRgb = mean(reshape(image, [pageSize,3]));
        avgAll = mean(avgRgb);
        scaleArray = max(avgAll, 128)./avgRgb;
        scaleArray = reshape(scaleArray,1,1,3);
        wbImage = uint8(bsxfun(@times,double(image),scaleArray));
        % crop
        for j=1:size(fields,1)
            coords = pixelBounds.(fields{j}); % x1 y1 x2 y2
            croppedImage = wbImage(coords(2):coords(4),...
                coords(1):coords(3),:);
            writeVideo(writeVideos.(fields{j}), croppedImage);
        end
    end
    
    for i=1:size(fields,1)
        close(writeVideos.(fields{i}));
    end
end