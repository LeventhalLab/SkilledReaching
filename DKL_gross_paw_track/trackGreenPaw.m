function trackGreenPaw(video, BGimg_ud, sr_ratInfo, session_mp, triggerTime, varargin)

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'cameraparams',
            cameraParams = varargin{iarg + 1};
    end
end