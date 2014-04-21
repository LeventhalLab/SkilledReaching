function runFolder(pixelBounds,hsvBounds)
    workingDirectory = uigetdir;
    
    % crop videos
%     originalVideos = dir(fullfile(workingDirectory,'*.avi'));
%     for i=1:size(originalVideos,1)
%        videoFile = fullfile(workingDirectory,originalVideos(i).name);
%        cropVideo(videoFile,pixelBounds); 
%     end
    
    % get data from all crops
    fields = fieldnames(pixelBounds);
    for i=1:size(fields,1)
        fieldDirectory = fullfile(workingDirectory,fields{i});
        fieldVideos = dir(fullfile(fieldDirectory,'*.avi'));
        for j=1:size(fieldVideos,1)
            videoFile = fullfile(fieldDirectory,fieldVideos(j).name);
            createVideo(videoFile,hsvBounds.(fields{i}));
        end
    end
end