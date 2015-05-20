%%
TestArrayMaskedImages_R0027_051314 = cell(1,21);
TestArrayBWImages_R0027_051314 = cell(1,21);
imR0027_051314 = cell(1,21);
TestArrayMaskedImages_R0027_051314{11} = maskedRGBImageR0027051314001;
TestArrayBWImages_R0027_051314{11} = BWR0027051314001;
imR0027_051314{11} = R0027051314001im;
for i = 1:10;
imR0027_051314{11-i} = read(R0027051314001,252-i);
[TestArrayMaskedImages_R0027_051314{11-i},TestArrayBWImages_R0027_051314{11-i}] = createMaskR0027051314001(imR0027_051314{11-i});
imR0027_051314{11+i} = read(R0027051314001,252+i);
[TestArrayMaskedImages_R0027_051314{11+i},TestArrayBWImages_R0027_051314{11+i}] = createMaskR0027051314001(imR0027_051314{11+i});
end
%%
hsv_imR0027_051314 = cell(1,21);
for i = 1:length(imR0027_051314);
    hsv_imR0027_051314{i} = rgb2hsv(imR0027_051314{i});
end
%%
DKLmask = cell(1,21);
for i = 1:length(hsv_imR0027_051314);
    DKLmask{i} = HSVthreshold(hsv_imR0027_051314{i},[.40,.03,.29,.54,.25,.50]);
end

for i = 1: length(DKLmask)
    figure;
    imshow(DKLmask{i})
end
%% Attempting to make video from masked images
% outputVideo = VideoWriter(fullfile('C:\Users\Administrator\Documents\GitHub\SkilledReaching','R0027_051314_DKLmaskVideo.avi'));
% outputVideo.FrameRate = R0027051314001.FrameRate;
% open(outputVideo)
% for i = 1:length(DKLmask);
%     imwrite(DKLmask{i},fullfile('C:\Users\Administrator\Documents\GitHub\SkilledReaching','R0027_051314_DKLmask',i.jpeg));
% end
%     
% for ii = 1:length(DKLmask)
%    img = DKLmask{ii};
%    writeVideo(outputVideo,img)
% end
% close(outputVideo)
% R0027051314001Avi = VideoReader(fullfile('C:\Users\Administrator\Documents\GitHub\SkilledReaching','R0027_051314_DKLmaskVideo.avi'));
% ii = 1;
% while hasFrame(R0027051314001Avi)
%    mov(ii) = im2frame(readFrame(R0027051314001Avi));
%    ii = ii+1;
% end
% f = figure;
% f.Position = [150 150 R0027051314001Avi.Width R0027051314001Avi.Height];
% 
% ax = gca;
% ax.Units = 'pixels';
% ax.Position = [0 0 R0027051314001Avi.Width R0027051314001Avi.Height];
% 
% image(mov(1).cdata,'Parent',ax)
% axis off
% movie(mov,1,R0027051314001Avi.FrameRate)