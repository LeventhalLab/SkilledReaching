function [trajDiff,alignFrame] = compareTrajectories(trajectories, alignmentFrames)

trajectoryLength = zeros(2,1);
for ii = 1 : 2
    trajectoryLength(ii) = size(trajectories{ii},1);
end

minTrajLength = min(trajectoryLength);
maxTrajLength = max(trajectoryLength);
minTrajInd = find(trajectoryLength == minTrajLength);
maxTrajInd = find(trajectoryLength == maxTrajLength);

padSize = maxTrajLength - minTrajLength;

traj_to_align = zeros(maxTrajLength,3,2);
traj_to_align(:,:,maxTrajInd) = trajectories{maxTrajInd};
traj_to_align(:,:,minTrajInd) = padarray(trajectories{minTrajInd},padSize,0,'post');

numVirtFrames = 2 * maxTrajLength;
alignFrame = maxTrajLength;
aligned_trajectories = alignTrajectoriesToFrame(traj_to_align,alignmentFrames,...
                                                'numvirtframes',numVirtFrames,...
                                                'aligntoframe',alignFrame);
                                            
trajDiff = diff(aligned_trajectories,1,3);

end