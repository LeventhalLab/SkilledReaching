function [meanTrajectory, varTrajectory, numValidTraj] = calcAverageTrajectory(points3d,varargin)

alignmentFrames = 175;
numVirtualFrames = 1500;
alignToFrame = 750;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'alignmentframes',
            alignmentFrames = varargin{iarg + 1};
        case 'numvirtualframes',
            numVirtualFrames = varargin{iarg + 1};
    end
end


aligned_trajectories = alignTrajectoriesToFrame(points3d,alignmentFrames,...
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