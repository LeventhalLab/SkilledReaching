function [meanApertures,varApertures] = summarizeApertures(apertureTrajectories)

    
numTrials = length(apertureTrajectories);

maxFrames = 0;
for iTrial = 1 : numTrials
    maxFrames = max(maxFrames,size(apertureTrajectories{iTrial},1));
end

apertures = NaN(numTrials,maxFrames);

for iTrial = 1 : numTrials

    numFrames = size(apertureTrajectories{iTrial},1);
    apertures(iTrial,1:numFrames) = sqrt(sum(apertureTrajectories{iTrial}.^2,2));

end

meanApertures = nanmean(apertures);
varApertures = nanvar(apertures);

end