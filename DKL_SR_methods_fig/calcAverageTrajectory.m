function [meanTrajectory, stdTrajectory, numValidTraj] = calcAverageTrajectory(points3d,varargin)

alignmentFrames = 175;
numVirtualFrames = 1500;
alignToFrame = 750;
alignTrajectories = true;
nanInterpolate = false;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'alignmentframes',
            alignmentFrames = varargin{iarg + 1};
        case 'numvirtualframes',
            numVirtualFrames = varargin{iarg + 1};
        case 'aligntrajectories',
            alignTrajectories = varargin{iarg + 1};
        case 'naninterp',
            nanInterpolate = varargin{iarg + 1};
    end
end

if alignTrajectories
    aligned_trajectories = alignTrajectoriesToFrame(points3d,alignmentFrames,...
                                                    'numvirtframes',numVirtualFrames,...
                                                    'aligntoframe',alignToFrame);
else
    aligned_trajectories = points3d;
end

% now align x,y,z to the cross frame for each trajectory. If no cross frame
% identified, skip

aligned_trajectories(aligned_trajectories==0) = NaN;

if nanInterpolate
    for iTraj = 1 : size(aligned_trajectories,3)
        for ii = 1 : 3
            aligned_trajectories(:,ii,iTraj) = naninterp(aligned_trajectories(:,ii,iTraj));
        end
    end
end
% count up how many valid trajectory points there are at each virtual frame
numFrames = size(aligned_trajectories,1);
numValidTraj = zeros(1,numFrames);
for i_frame = 1 : numFrames
    numValidTraj(i_frame) = sum(~isnan(aligned_trajectories(i_frame,1,:)));
end
meanTrajectory = nanmean(aligned_trajectories,3);
stdTrajectory = nanstd(aligned_trajectories, 0, 3);

end