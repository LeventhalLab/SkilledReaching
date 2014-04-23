function coords=getPelletCoords()
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    imshow(read(video,50));
    disp('Identify pellet, press ENTER when done...');
    [x,y] = ginput;
    close;
    coords=[x,y];
end