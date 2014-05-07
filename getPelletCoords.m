function pelletCoords=getPelletCoords(boundNames)
    pelletCoords = {};
    disp('Select the session directory...');
    workingDirectory = uigetdir;
    for i=1:size(boundNames,2)
        fieldVideos = dir(fullfile(workingDirectory,boundNames{i},'*.avi'));
        videoFile = fullfile(workingDirectory,boundNames{i},fieldVideos(randi(10)+10).name);
        video = VideoReader(videoFile);
        figure;
        imshow(read(video,100));
        disp('Identify pellet, press ENTER when done...');
        [x,y] = ginput;
        close;
        pelletCoords.(boundNames{i}) = [x,y];
    end
end