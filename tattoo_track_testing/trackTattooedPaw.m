function trackTattooedPaw( video,  rat_metadata, varargin )
%
% INPUTS:
%   video - a videoReader object containing the video recorded from 


% ALGORITHM:
%   1) find the trigger frame
%   2)

numBGframes = 50;
ROI_to_find_trigger_frame = [0210         0590         0050         0070
                             1740         0560         0050         0070];
gray_paw_limits = [60 125];
                           
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'trigger_roi',
            ROI_to_find_trigger_frame = varargin{iarg + 1};
    end
end

BGimg = extractBGimg( video, 'numbgframes', numBGframes);

[triggerFrame, peakFrame]= identifyTriggerFrame( video, rat_metadata.pawPref, ...
                                                  'bgimg', BGimg, ...
                                                  'trigger_roi',ROI_to_find_trigger_frame,...
                                                  'grylimits',gray_paw_limits);
triggerFrame = 510;peakFrame = 540;   % hard code to speed up analysis

% find a mask for the paw in the lateral, central, and right mirrors for
% the peak frame

im_trigger = read(video,triggerFrame);
im_peak = read(video,peakFrame);

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