function cropVideo(sourceVid,destVids,timeLimits,triggerTime,ROIs)
% function to crop videos based on ROIs and store in a new folder
%
% sourceVid - name of the source video
% destVids - names of destination videos for each ROI. cell array
% timeLimits = 1 x 2 array with start and end times to extract with respect
%   to the trigger time

video = VideoReader(sourceVid);
numROIs = size(ROIs,1);

if numROIs ~= length(destVids)
    error('rows of ROI matrix and length of destVids must match')
end

fr = video.FrameRate;
video.CurrentTime = timeLimits(1) + triggerTime;

writeVid = cell(1,3);
for iROI = 1 : numROIs
    writeVid{iROI} = VideoWriter(destVids{iROI},'MPEG-4');
    writeVid{iROI}.FrameRate = fr;
    open(writeVid{iROI});
end

while video.CurrentTime <= triggerTime + timeLimits(2)
    
    curFrame = readFrame(video);
    
    for iROI = 1 : numROIs
        
        newFrame = curFrame(ROIs(iROI,2) : ROIs(iROI,2) + ROIs(iROI,4)-1,...
                            ROIs(iROI,1) : ROIs(iROI,1) + ROIs(iROI,3)-1,:);
                              
        writeVideo(writeVid{iROI},newFrame);
    end
end

for iROI = 1 : numROIs
    close(writeVid{iROI});
end

clear video