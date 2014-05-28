% pixelBounds is a struct with 3 fields, hsvBounds is an array
function createTrialData(pixelBounds,hsvBounds)
    workingDirectory = uigetdir('\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project');
    
    % crop videos
    originalVideos = dir(fullfile(workingDirectory,'*.avi'));
    for i=1:size(originalVideos,1)
       videoFile = fullfile(workingDirectory,originalVideos(i).name);
       cropVideo(videoFile,pixelBounds); 
    end
    
    % get data from all crops
    fields = fieldnames(pixelBounds);
    for i=1:size(fields,1)
        fieldDirectory = fullfile(workingDirectory,fields{i});
        fieldVideos = dir(fullfile(fieldDirectory,'*.avi'));
        for j=1:size(fieldVideos,1)
            videoFile = fullfile(fieldDirectory,fieldVideos(j).name);
            createVideo(videoFile,hsvBounds);
        end
    end
end