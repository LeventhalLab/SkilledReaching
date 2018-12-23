function [mean_trajectory, cov_trajectory] = ...
    plotMeanTrajectories(trajectories, varargin)
%
% INPUTS
%
% OUTPUTS
%

% plotting parameters
meanWeight = 2;
meanColor = 'k';

plotAllTrajectories = false;

h_axes = [];
validTrials = 1 : size(trajectories,3);   % use all trials

% totalTrials = size(trajectories,3);


for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'h_axes'
            h_axes = varargin{iarg + 1};
        case 'validtrials'
            validTrials = varargin{iarg + 1};
        case 'plotalltrajectories'
            plotAllTrajectories = varargin{iarg + 1};
        case 'meancolor'
            meanColor = varargin{iarg + 1};
    end
end

if all(validTrials < 2)
    % validTrials is (probably) a vector of booleans
    validTrials = find(validTrials);
end
numValidTrials = length(validTrials);

if isempty(h_axes)
    figure;
    h_axes = gca;
end
mean_trajectory = squeeze(mean(trajectories(:,:,validTrials),3));
cov_trajectory = zeros(3,3,size(trajectories,1));

for i_pt = 1 : size(trajectories,1)
    trial_pts = squeeze(trajectories(i_pt,:,validTrials));
    cov_trajectory(:,:,i_pt) = cov(trial_pts');
end
    
plot3(mean_trajectory(:,1),mean_trajectory(:,2),mean_trajectory(:,3),...
    meanColor,'linewidth',meanWeight);
set(h_axes,'ydir','reverse','zdir','reverse');
xlabel('x');ylabel('y');zlabel('z')

if plotAllTrajectories
    hold on
    for ii = 18 : numValidTrials
        if validTrials(ii)
            plot3(trajectories(:,1,validTrials(ii)),trajectories(:,2,validTrials(ii)),trajectories(:,3,validTrials(ii)))
        end
    end
end
end