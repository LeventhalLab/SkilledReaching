function trackTattooedPaw( video,  rat_metadata, varargin )
%
% INPUTS:
%   video - a videoReader object containing the video recorded from 


% ALGORITHM:
%   1) find the trigger frame
%   2)

numBGframes = 50;
ROI_to_find_trigger_frame = [  0140         0590         0120         0070
                               1740         0560         0120         0070];
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'trigger_roi',
            ROI_to_find_trigger_frame = varargin{iarg + 1};
    end
end

BGimg = extractBGimg( video, 'numbgframes', numBGframes);

triggerFrame = identifyTriggerFrame( video, rat_metadata.pawPref, ...
                                     'bgimg', BGimg, ...
                                     'trigger_roi',ROI_to_find_trigger_frame);

end    % end function trackTattooedPaw( video )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function BGimg = extractBGimg( video, varargin )
%
% INPUTS:
%   video - a VideoReader object
%
% VARARGS:
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