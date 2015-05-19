function [triggerFrame] = identifyTriggerFrameViaHSVMask(filepath,filename,side)
videoFilename = fullfile(filepath,filename);
x = VideoReader(videoFilename);
for i = 1:x.numberOfFrames;
    im = read(x,i);    
    [BW,maskedRGBImage] = createMaskR0027051314001(im);
    if side == 'right';
        sum(BW(85:115),
end
