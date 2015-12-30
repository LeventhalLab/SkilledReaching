function [meanTrajectory, varTrajectory, numValidTraj] = calcAverageTrajectory(x,y,z,varargin)

slot_z = 175;
numVirtualFrames = 1200;
alignToFrame = 600;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'slot_z',
            slot_z = varargin{iarg + 1};
    end
end

slotCrossFrames = DKL_slotCrossFrames(z, 'slot_z', slot_z);
aligned_trajectories = alignTrajectoriesToFrame(x,y,z,slotCrossFrames,...
                                                'numvirtframes',numVirtualFrames,...
                                                'aligntoframe',alignToFrame);
% now align x,y,z to the cross frame for each trajectory. If no cross frame
% identified, skip

aligned_trajectories(aligned_trajectories==0) = NaN;
    
% count up how many valid trajectory points there are at each virtual frame
numFrames = size(aligned_trajectories,1);
numValidTraj = zeros(1,numFrames);
for i_frame = 1 : numFrames
    numValidTraj(i_frame) = sum(~isnan(aligned_trajectories(i_frame,1,:)));
end
meanTrajectory = nanmean(aligned_trajectories,3);
varTrajectory = nanvar(aligned_trajectories, 0, 3);