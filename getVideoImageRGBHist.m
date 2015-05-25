%dellens@umich.edu
%combined script for readVideo.m and getColorHist.m

disp('Select .avi video...')
video = uigetfile('*.avi')

prompt = 'Frame Number? ';
frameNumber = input(prompt)

% simple function to streamline reading a video, and displaying an accompanying frame image

readVideo(video,frameNumber)

%end

fname = read(ans,frameNumber);

getColorHist(fname)

%end

