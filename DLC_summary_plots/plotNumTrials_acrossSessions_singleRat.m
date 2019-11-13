function [h_fig,h_axes] = plotNumTrials_acrossSessions_singleRat(ratSummary,thisRatInfo,varargin)
%
% INPUTS
%   ratSummary
%   thisRatInfo
%
% OUTPUTS
%
occludeRatio=0.5;

switch ratSummary.exptType
    case 'chr2_during'
        laserOnColor = 'b';
        occludeColor = [0 0 1] * occludeRatio;
    case 'chr2_between'
        laserOnColor = 'c';
        occludeColor = [0 0 1] * occludeRatio;
    case 'arch_during'
        laserOnColor = 'g';
        occludeColor = [0 1 0.0] * occludeRatio;
    case 'eyfp_during'
        laserOnColor = 'r';
        occludeColor = [1 0.0 0.0] * occludeRatio;
end
baselineColor = [0 0 0];

full_traj_z_lim = [-5 50];
x_lim = [-30 10];
y_lim = [-20 10];

h_axes = [];

for i_arg = 1 : 2 : nargin - 2
    switch lower(varargin{i_arg})
        case 'h_axes'
            h_axes = varargin{i_arg+1};
            axes(h_axes);
            h_fig = gcf;
        case 'full_traj_z_lim'
            full_traj_z_lim = varargin{i_arg+1};
        case 'x_lim'
            x_lim = varargin{i_arg+1};
        case 'y_lim'
            y_lim = varargin{i_arg+1};
    end
end
if isempty(h_axes)
    h_fig = figure;
    h_axes = gca;
end

numSessions = size(ratSummary.mean_pd_trajectory,1);
pawPref = thisRatInfo.pawPref;

baseLineSessions = 1:2;
laserOnSessions = 3:12;
occludeSessions = 13:22;

scatter(baseLineSessions,ratSummary.num_trials(baseLineSessions,1),'markeredgecolor',baselineColor);
hold on
scatter(laserOnSessions,ratSummary.num_trials(laserOnSessions,1),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,ratSummary.num_trials(occludeSessions,1),'markeredgecolor',laserOnColor);

ylabel('number of trials')
xlabel('session #')
set(gca,'xtick',[1,2,3,12,13,22]);
set(gca,'ylim',[0 100],'ytick',[0 50 100]);