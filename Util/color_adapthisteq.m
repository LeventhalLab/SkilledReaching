function newImg = color_adapthisteq(rgbImage, varargin)

clipLimit = 0.01;

for iarg = 1 : 2 : nargin -1 
    switch lower(varargin{iarg})
        case 'cliplimit',
            clipLimit = varargin{iarg + 1};
    end
end

hsvImage = rgb2hsv(rgbImage);
hsvImage(:,:,3) = adapthisteq(hsvImage(:,:,3),...
                              'cliplimit',clipLimit);
newImg = hsv2rgb(hsvImage);