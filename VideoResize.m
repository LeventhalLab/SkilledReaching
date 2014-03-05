input = VideoReader('R0016.avi');
output = VideoWriter('R0016compressededge.avi', 'Motion JPEG AVI');
output.Quality = 75;
output.FrameRate = 150;
open(output);

for i = 1:obj.NumberOfFrames
    image = read(input, i); 
    resized_image = imresize(image, 0.5);
    resized_image = rgb2gray(resized_image);
    resized_image = edge(resized_image, 'roberts', .01);
    resized_image = uint8(resized_image)*255;
    resized_frame = im2frame(resized_image, colormap('gray'));
    writeVideo(output, resized_frame);
end;

close(output);