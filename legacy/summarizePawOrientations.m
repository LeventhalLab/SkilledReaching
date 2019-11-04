function [meanOrientations,mean_MRL] = summarizePawOrientations(pawOrientationTrajectories)

    
numTrials = length(pawOrientationTrajectories);

maxFrames = 0;
for iTrial = 1 : numTrials
    maxFrames = max(maxFrames,length(pawOrientationTrajectories{iTrial}));
end

pawOrientations = NaN(numTrials,maxFrames);

for iTrial = 1 : numTrials

    numFrames = length(pawOrientationTrajectories{iTrial});
    pawOrientations(iTrial,1:numFrames) = pawOrientationTrajectories{iTrial};

end

meanOrientations = nancirc_mean(pawOrientations,[],1);
mean_MRL = nancirc_r(pawOrientations,[],[],1);

end