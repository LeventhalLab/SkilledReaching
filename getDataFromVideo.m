% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% A wrapper on top of the pawData function, which is at the core of all analysis
function [pawCenters,pawHulls]=getDataFromVideo(videoFile,hsvBounds)
    video = VideoReader(videoFile);

    pawCenters = NaN(video.NumberOfFrames,2);
    pawHulls = cell(1,video.NumberOfFrames);

    for i=2:video.NumberOfFrames
        disp(['Masking... ' num2str(i)])
        image = read(video,i);
        % paw data
        [pawCenters(i,:),pawHulls{i}] = pawData(image,hsvBounds);
    end
end