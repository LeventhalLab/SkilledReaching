function newMask = processMask(mask, varargin)

SEsize = 2;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'sesize',
            SEsize = varargin{iarg + 1};
    end
end
    
SE = strel('disk',SEsize);

mask = imopen(mask, SE);
mask = imclose(mask, SE);
newMask = imfill(mask,'holes');

end