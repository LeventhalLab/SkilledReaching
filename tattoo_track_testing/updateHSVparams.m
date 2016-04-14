function tracks = updateHSVparams(tracks, paw_hsv, HSVupdateRate)
%
% INPUTS:
%   tracks - array of tracks structures
%   paw_hsv - 1 x 2 cell structure containing 4-dimensional arrays of hsv
%       images (4th dimension is digit ID)

newHSVmean = zeros(1,3);
for iTrack = 1 : length(tracks) - 1
    for iView = 1 : 3
        if tracks(iTrack).isvisible(iView)
            current_hsv = squeeze(paw_hsv{iView}(:,:,:,iTrack));
            if iView == 1
                digitMask = tracks(iTrack).digitmask1;
            elseif iView == 2
                digitMask = tracks(iTrack).digitmask2;
            else
                digitMask = tracks(iTrack).digitmask3;
            end
            [meanHSV, stdHSV] = calcHSVstats(current_hsv, digitMask);
            
            hdiff = hueDiff(meanHSV(1), tracks(iTrack).meanHSV(iView,1));
            newHSVmean(1) = hueSum(tracks(iTrack).meanHSV(iView,1), hdiff * HSVupdateRate);
                     
            newHSVmean(2:3) = tracks(iTrack).meanHSV(iView,2:3) + ...
                              (meanHSV(2:3) - tracks(iTrack).meanHSV(iView,2:3)) * HSVupdateRate;
            newHSVstd  = tracks(iTrack).stdHSV(iView,:) + ...
                         (stdHSV - tracks(iTrack).stdHSV(iView,:)) * HSVupdateRate;
                     
            tracks(iTrack).meanHSV(iView,:) = newHSVmean;
            tracks(iTrack).stdHSV(iView,:) = newHSVstd;
        end
    end
end
    
end