startFrame = 120;
endFrame = 350;

input = VideoReader('R0016_20140306_13-06-25_013_s.avi');
output = VideoWriter('R0016_20140306_13-06-25_013_s_t.avi');
output.Quality = 100;
output.FrameRate = 150;
open(output);

for i = startFrame:endFrame
    writeVideo(output, im2frame(read(input, i)));
end;

close(output);