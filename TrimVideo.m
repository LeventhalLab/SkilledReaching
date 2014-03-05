startFrame = 70;
endFrame = 300;

input = VideoReader('R0000compressed.avi');
output = VideoWriter('R0000compressedsnip.avi');
output.Quality = 100;
output.FrameRate = 150;
open(output);

for i = startFrame:endFrame
    writeVideo(output, im2frame(read(input, i)));
end;

close(output);