hbfr = vision.BinaryFileReader('TEST_20140127_13-09-34_001.bin');
hbfr.VideoFormat = 'Custom';
hbfr.VideoComponentCount = 3;
hbfr.VideoComponentBits = 8;
hbfr.VideoComponentSizes = [2040 1088];
hbfr.VideoComponentOrder = 1;

hvp = vision.VideoPlayer;
while ~isDone(hbfr)
    y = step(hbfr);
    step(hvp,y);
end

release(hbfr); % close the input file
release(hvp); % close the video display