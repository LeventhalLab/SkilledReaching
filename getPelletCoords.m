function pelletCoords=getPelletCoords(boundNames)
    pelletCoords = {};
    for i=1:size(boundNames,2)
        disp(['Navigate to video for "',boundNames{i},'"...']);
        [videoName,videoPath] = uigetfile('*.avi');
        videoFile = fullfile(videoPath,videoName);
        video = VideoReader(videoFile);
        figure;
        imshow(read(video,5));
        disp('Identify pellet, press ENTER when done...');
        [x,y] = ginput;
        close;
        pelletCoords.(boundNames{i}) = [x,y];
    end
end