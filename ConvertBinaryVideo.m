hbfr = vision.BinaryFileReader('R0000.bin');
hbfr.FourCharacterCode = '0x';
% hbfr.VideoComponentCount = 3;
% hbfr.VideoComponentBits = 8;
% hbfr.VideoComponentSizes = [2040 1086];
% hbfr.VideoComponentOrder = 1;

hvp = vision.VideoPlayer;
while ~isDone(hbfr)
    y = step(hbfr);
    step(hvp,y);
end

release(hbfr); % close the input file
release(hvp); % close the video display