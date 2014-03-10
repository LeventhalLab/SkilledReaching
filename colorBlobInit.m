function colorBlobInit()

    % SETUP FILE STRUCTURE
    workingDirectory = uigetdir;
    copyfile(fullfile(pwd,'defaults.mat'),workingDirectory);
    allVideos = dir(fullfile(workingDirectory,'*.avi'));
    for i=1:size(allVideos,1)
        [videoPath,videoName,videoExt] = fileparts(allVideos(i).name);
        
        % create still frame from first video
        if(i == 1)
           video = VideoReader(fullfile(workingDirectory,allVideos(1).name));
           imwrite(read(video,1),fullfile(workingDirectory,...
               strcat(videoName,'_f1.jpg')));
           clearvars video
        end
        
        % move each video into its own folder
        newVideoFolder = fullfile(workingDirectory,videoName);
        mkdir(newVideoFolder);
        saveVideoAs = fullfile(workingDirectory,videoName,allVideos(1).name);
        movefile(fullfile(workingDirectory,allVideos(1).name),saveVideoAs);
    end
    
    disp('File structure created...');
    
    S = load(fullfile(workingDirectory,'defaults.mat'));
    disp('Defaults loaded...');
    disp(S);
    
    fields = fieldnames(S);
    for i=1:size(fields,1)
       r = input(strcat('Replace "',fields{i},'"?: '));
       if(~isempty(r))
           S.(fields{i}) = r;
       end
    end
    
    save('defaults.mat', '-struct', 'S');
    disp('Defaults saved...');
    disp(S);
    
    % CROP VIDEOS
    % probably just read video files in this new directory, allVideos is
    % not useful
    for i=1:size(allVideos,1)
        [videoPath,videoName,videoExt] = fileparts(allVideos(i).name);
        curVideoDirectory = fullfile(workingDirectory,videoName);
        savedVideoPaths = cropVideo(fullfile(curVideoDirectory,allVideos(i).name), S.pixelBounds);
        
        savedVideoFields = fieldnames(savedVideoPaths);
        for j=1:size(savedVideoFields,1)
            [colorData] = colorBlobs(savedVideoPaths.(savedVideoFields{j}), S.hsvBounds);
            save(fullfile(curVideoDirectory,...
                strcat('colorData_',char(savedVideoFields{j}),'_',videoName)), 'colorData');
        end
    end
    
    % EXTRACT COLOR DATA
    
end