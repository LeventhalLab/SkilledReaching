function vidStruct = readVid(video,varargin)

startTime = 0;
endTime = video.Duration;

if nargin > 1
    startTime = varargin{1};
end
if nargin > 2
    endTime = varargin{2};
end

h = video.Height;
w = video.Width;

vidStruct = struct('cdata',zeros(h,w,3,'uint8'),'colormap',[]);

video.CurrentTime = startTime;

k = 1;
while hasFrame(video) && video.CurrentTime <= endTime
    vidStruct(k).cdata = readFrame(video);
    k = k + 1;
end