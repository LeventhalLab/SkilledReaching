function cropVideo(sourceVid,destVids,timeLimits,triggerTime,ROIs)

% sourceVid - name of the source video
% destVids - names of destination videos for each ROI. cell array
% timeLimits = 1 x 2 array with start and end times to extract with respec
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
    open(writeVid{iROI});
end

newFrame = cell(1,3);
while video.CurrentTime <= triggerTime + timeLimits(2)
    
    curFrame = readFrame(video);
    
    for iROI = 1 : numROIs
        
        newFrame = curFrame(ROIs(iROI,2) : ROIs(iROI,2) + ROIs(iROI,4),...
                            ROIs(iROI,1) : ROIs(iROI,1) + ROIs(iROI,3),:);
                              
        writeVideo(writeVid{iROI},newFrame);
    end
end

for iROI = 1 : numROIs
    close(writeVid{iROI});
end

clear video