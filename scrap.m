obj = VideoReader('test.avi');
image = read(obj, 1);
for i = 2:obj.NumberOfFrames
    image = (image + read(obj, i))/2;
end

imwrite(image, 'testavg.jpg');