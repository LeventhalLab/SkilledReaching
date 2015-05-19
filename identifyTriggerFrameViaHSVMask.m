function [triggerFrame] = identifyTriggerFrameViaHSVMask(filepath,filename,side)
videoFilename = fullfile(filepath,filename);
x = VideoReader(videoFilename);