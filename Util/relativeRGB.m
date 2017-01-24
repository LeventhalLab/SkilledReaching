function [ im_out ] = relativeRGB( im_in )
% USAGE: [ im_out ] = relativeRGB( im_in )
%   function to compute the relative contribution of each color channel to
%   each pixel. This helps make color values independent of lighting
%   conditions.
%
% INPUTS:
%   im_in - h x w x 3 (height by width) RGB image
%
% OUTPUTS:
%   im_out - h x w x 3 (height by width) RGB image where each pixel is a 
%       (r',g',b') triplet. r' = R / sqrt(R^2 + G^2 + B^2), etc. for each
%       pixel

% note, this could also be done by 
% first, make sure the image is double precision
if isa(im_in,'uint8')
    im_in = double(im_in) / 255;
end

im_out = zeros(size(im_in));
% im_out2 = zeros(size(im_in));
% im_sum = sum(im_in,3);
im_magnitude = sqrt(sum(im_in.^2,3));
im_magnitude(im_magnitude==0) = 10;   % make sure black pixels look black after normalizing

% for ii = 1 : 3
%     im_out(:,:,ii) = im_in(:,:,ii) ./ im_sum;
% end

for ii = 1 : 3
    im_out(:,:,ii) = im_in(:,:,ii) ./ im_magnitude;
end

end

