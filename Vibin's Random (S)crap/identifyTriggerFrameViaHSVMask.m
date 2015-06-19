function [triggerFrame] = identifyTriggerFrameViaHSVMask(filepath,filename,side)
videoFilename = fullfile(filepath,filename);
x = VideoReader(videoFilename);
for i = 1:x.numberOfFrames;
    im = read(x,i);    
    [BW,maskedRGBImage] = createMaskR0027051314001(im);
    if side == 'right';
        TriggerFramePotential(i) = sum(BW(85:115,524:540));
    elseif side == 'left';
        TriggerFramePotential(i) = sum(BW(1796:1806,527:532))
    end
end
figure;
plot(TriggerFramePotential);

figure;
imshow(maskedRGBImage)