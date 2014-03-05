input = VideoReader('R0000compressedsnip.avi');
output = VideoWriter('R0000compressedsnipwb.avi', 'Motion JPEG AVI');
output.Quality = 100;
output.FrameRate = 30;
open(output);

for i = 1:input.NumberOfFrames
    imageData = read(input, i);
    pageSize = size(imageData,1) * size(imageData,2);
    avg_rgb = mean( reshape(imageData, [pageSize,3]) );
    avg_all = mean(avg_rgb);
    scaleArray = max(avg_all, 128)./avg_rgb;
    scaleArray = reshape(scaleArray,1,1,3);
    adjustedImage = uint8(bsxfun(@times,double(imageData),scaleArray));
    writeVideo(output, im2frame(adjustedImage));
end;

close(output);