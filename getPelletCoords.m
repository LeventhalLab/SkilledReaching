% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Gives the user a crosshair to mark the center of the pellet on a given video frame. Using
% boundNames was an attempt at being fully modular, but this can likely be hard-coded for left,
% center, and right views.
function pelletCoords=getPelletCoords(boundNames)
    pelletCoords = {};
    disp('Select the session directory...');
    workingDirectory = uigetdir('\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project');
    for i=1:size(boundNames,2)
        fieldVideos = dir(fullfile(workingDirectory,boundNames{i},'*.avi'));
        videoFile = fullfile(workingDirectory,boundNames{i},fieldVideos(randi(10)+10).name);
        video = VideoReader(videoFile);
        figure;
        imshow(read(video,200)); % changed from 100 for 300 fps videos
        disp('Identify pellet, press ENTER when done...');
        [x,y] = ginput;
        close;
        pelletCoords.(boundNames{i}) = [x,y];
    end
end