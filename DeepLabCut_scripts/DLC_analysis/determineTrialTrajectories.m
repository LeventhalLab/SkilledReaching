function determineTrialTrajectories(allPartsTrajectories, bodyparts, pawPref, varargin)
%
% INPUTS
%
% OUTPUTS
%

windowLength = 10;
smoothMethod = 'gaussian';

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'windowlength'
            windowLength = varargin{iarg+1};
        case 'smoothmethod'
            smoothMethod = varargin{iarg+1};
    end
end

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

% start with paw dorsum
interp_trajectories = NaN(size(allPartsTrajectories));

curTrajectory = squeeze(allPartsTrajectories(:,:,pawDorsumIdx));
[frameRange,cur_interp_trajectory] = smoothSingleTrajectory(curTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);

interp_trajectories(frameRange(1):frameRange(2),:,pawDorsumIdx) = cur_interp_trajectory;


end