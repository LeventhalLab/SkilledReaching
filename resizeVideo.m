input = VideoReader('R0016_20140306_13-05-30_005.avi');
output = VideoWriter('R0016_20140306_13-05-30_005_s.avi', 'Motion JPEG AVI');
output.Quality = 75;
output.FrameRate = 150;
open(output);

for i = 1:input.NumberOfFrames
    image = read(input, i); 
    % resize
    imageData = imresize(image, 0.5);
    % white balance
    pageSize = size(imageData,1) * size(imageData,2);
    avg_rgb = mean(reshape(imageData, [pageSize,3]));
    avg_all = mean(avg_rgb);
    scaleArray = max(avg_all, 128)./avg_rgb;
    scaleArray = reshape(scaleArray,1,1,3);
    adjustedImage = uint8(bsxfun(@times,double(imageData),scaleArray));
    % write image
    resized_frame = im2frame(adjustedImage);
    writeVideo(output, resized_frame);
end;

close(output);