startFrame = 1;
endFrame = 375;

input = VideoReader('R0000_20140308_11-49-12_008_MIDDLE.avi');
output = VideoWriter('R0016_4color_s.avi');
output.Quality = 60;
output.FrameRate = 150;
open(output);

for i = startFrame:endFrame
    writeVideo(output, im2frame(read(input, i)));
    disp(i)
end;

close(output);