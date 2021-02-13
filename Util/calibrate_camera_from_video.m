function cameraParams = calibrate_camera_from_video(video_name)

square_size_mm = 10;    % checkerboard square size in mm

v = VideoReader(video_name);

im_size = [v.Height, v.Width];
num_frames = v.NumFrames;

images = uint8(zeros(im_size(1),im_size(2),1,num_frames));



for i_frame = 1 : num_frames
    
    cur_frame = readFrame(v);
    images(:,:,1,i_frame) = rgb2gray(cur_frame);
    
end
    
[imPoints, cb_size, images_used] = detectCheckerboardPoints(images);
worldPoints = generateCheckerboardPoints(cb_size, square_size_mm);

cameraParams = estimateCameraParameters(imPoints, worldPoints);

end