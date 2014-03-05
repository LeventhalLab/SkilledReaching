videoFReader = vision.VideoFileReader('R0016compressed.avi');
videoPlayer = vision.VideoPlayer;

while ~isDone(videoFReader)
   frame = step(videoFReader);
   step(videoPlayer,frame);
end

release(videoFReader);
release(videoPlayer);