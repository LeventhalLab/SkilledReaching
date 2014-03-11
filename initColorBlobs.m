function initColorBlobs()
    % change defaults: m = matfile('defaults','Writable',true);

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
           clearvars video;
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
    
    % CROP VIDEOS AND EXTRACT COLOR DATA
    % probably just read video files in this new directory, allVideos is
    % not useful
    for i=1:size(allVideos,1)
        [videoPath,videoName,videoExt] = fileparts(allVideos(i).name);
        curVideoDirectory = fullfile(workingDirectory,videoName);
        pixelBoundsFields = fieldnames(S.pixelBounds);

        %crops videos, they are placed into their folder
        savedVideoPaths = cropVideo(S.pixelBounds,fullfile(curVideoDirectory,allVideos(i).name));
        
        savedVideoFields = fieldnames(savedVideoPaths);
        for j=1:size(savedVideoFields,1)
            % get color data
            [colorData] = colorBlobs(savedVideoPaths.(savedVideoFields{j}),S.hsvBounds,...
                S.manualMaskCoords.(pixelBoundsFields{j}));
            [savedVideoPath,savedVideoName,savedVideoExt] = fileparts(savedVideoPaths.(savedVideoFields{j}));
            % save data to matlab file
            save(fullfile(savedVideoPath,...
                strcat('colorData_',char(savedVideoFields{j}),'_',savedVideoName)), 'colorData');
            % plot and save figure
            plotCentroids(colorData,savedVideoPath,...
                strcat(char(savedVideoFields{j}),'_',videoName));
            % create centroid video
            overlayCentroids(colorData,savedVideoPaths.(savedVideoFields{j}),...
                fullfile(savedVideoPath,strcat('centroids_',char(savedVideoFields{j}),savedVideoName)));
            % create masks video
            overlayMasks(colorData,savedVideoPaths.(savedVideoFields{j}),...
                fullfile(savedVideoPath,strcat('masks_',char(savedVideoFields{j}),savedVideoName)));
            
            clearvars colorData;
        end
    end
    
    
end