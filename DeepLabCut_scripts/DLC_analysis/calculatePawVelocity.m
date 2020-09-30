function [paw_xyz_v,paw_tangential_v] = calculatePawVelocity(pawPositions,frameRate,varargin)
%
% calculate paw velocity along each direction and tangential to the
% direction of motion
%
% INPUTS:
%   pawPositions - cell array of paw positions for each trial (probably paw
%       position taken as the paw dorsum)
%   frameRate - frame rate in fps
%
% VARARGINS:
%   smoothwindow - smoothing window for processing velocity data
%
% OUTPUTS:
%   paw_xyz_v - cell array with an entry for each trial containing the
%       velocity along x, y, and z directions
%   paw_tangential_v - cell array with an entry for each trial containing
%       paw velocity tangential to the direction of motion

smoothWidth = 3;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'smoothwindow'
            smoothWidth = varargin{iarg + 1};
    end
end

numTrials = length(pawPositions);
paw_xyz_v = cell(numTrials,1);
paw_tangential_v = cell(numTrials,1);

for iTrial = 1 : numTrials
    
    xyz_diff = diff(pawPositions{iTrial},1,1);
    paw_xyz_v{iTrial} = xyz_diff * frameRate;
    
    for ii = 1 : size(xyz_diff,2)
        paw_xyz_v{iTrial}(:,ii) = smooth(paw_xyz_v{iTrial}(:,ii),smoothWidth);
    end
    paw_tangential_v{iTrial} = sqrt(sum(xyz_diff.^2,2)) * frameRate;
    paw_tangential_v{iTrial} = smooth(paw_tangential_v{iTrial},smoothWidth);
end

end