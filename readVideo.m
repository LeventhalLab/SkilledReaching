% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% simple function to streamline reading a video, and displaying an accompanying frame image
function [video,im]=readVideo(frameNumber)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    
    if(exist('frameNumber','var'))
        im = read(video,frameNumber);
        figure;
        imshow(im);
    else
        im = read(video,1);
    end
end