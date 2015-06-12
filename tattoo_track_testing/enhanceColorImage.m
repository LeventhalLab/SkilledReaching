function I_enh = enhanceColorImage(I, decorrmean, decorrsigma, varargin)
%
% usage:
%
% INPUTS:
%
% OUTPUTS:
%

mask = (rgb2gray(I) > 0);

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'mask',
            mask = varargin{iarg + 1};
    end
end

rgbMask = repmat(uint8(mask),1,1,3);

[y,x] = find(mask);
I_enh = decorrstretch(I,'samplesubs',{y,x}, ...
                      'targetmean',decorrmean,...
                      'targetsigma',decorrsigma);

I_enh = rgbMask .* I_enh;
I_enh = rgb2hsv(I_enh);
I_enh(:,:,2) = imadjust(I_enh(:,:,2));
I_enh(:,:,3) = imadjust(I_enh(:,:,3));
I_enh = hsv2rgb(I_enh);