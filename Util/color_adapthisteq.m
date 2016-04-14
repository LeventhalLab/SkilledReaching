function newImg = color_adapthisteq(rgbImage, varargin)

clipLimit = 0.01;
numTiles = [8,8];
nbins = 256;
rnge = 'full';
dist = 'uniform';
Alpha = 0.4;

for iarg = 1 : 2 : nargin -1 
    switch lower(varargin{iarg})
        case 'cliplimit',
            clipLimit = varargin{iarg + 1};
        case 'numtiles',
            numTiles = varargin{iarg + 1};
        case 'nbins',
            nbins = varargin{iarg + 1};
        case 'range',
            rnge = varargin{iarg + 1};
        case 'distribution',
            dist = varargin{iarg + 1};
        case 'alpha',
            Alpha = varargin{iarg + 1};
    end
end

hsvImage = rgb2hsv(rgbImage);

if strcmpi(dist,'uniform')
    hsvImage(:,:,3) = adapthisteq(hsvImage(:,:,3),...
                                  'cliplimit',clipLimit,...
                                  'numtiles',numTiles,...
                                  'nbins',nbins,...
                                  'range',rnge,...
                                  'distribution',dist);
else
    hsvImage(:,:,3) = adapthisteq(hsvImage(:,:,3),...
                                  'cliplimit',clipLimit,...
                                  'numtiles',numTiles,...
                                  'nbins',nbins,...
                                  'range',rnge,...
                                  'distribution',dist,...
                                  'alpha',Alpha);
end
newImg = hsv2rgb(hsvImage);