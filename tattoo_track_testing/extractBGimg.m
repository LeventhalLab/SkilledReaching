function BGimg  = extractBGimg( video, varargin )
%
% INPUTS:
%   video - a VideoReader object
%
% VARARGS:
%   numbgframes - number of frames to average from the beginning of the
%                 file to create the background
%
% OUTPUT:
%   BGimg - 

numBGframes = 50;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
    end
end

BGframes = uint8(zeros(numBGframes, video.Height, video.Width, 3));
for ii = 1 : numBGframes
    BGframes(ii,:,:,:) = read(video, ii);
end
BGimg = uint8(squeeze(mean(BGframes, 1)));

end    % function BGimg = extractBGimg( video )