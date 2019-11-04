function [paw_xyz_v,paw_tangential_v] = calculatePawVelocity(pawPositions,frameRate,varargin)

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