function [h_fig,h_axes] = plot_mean_dist_from_traj_acrossSessions_singleRat(ratSummary,varargin)
%
% INPUTS
%   ratSummary
%   thisRatInfo
%
% OUTPUTS
%

baseLineSessions = 1:2;
laserOnSessions = 3:12;
occludeSessions = 13:22;

occludeRatio=0.5;

y_lim = [0,15];

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

h_axes = [];

for i_arg = 1 : 2 : nargin - 1
    switch lower(varargin{i_arg})
        case 'h_axes'
            h_axes = varargin{i_arg+1};
            axes(h_axes);
            h_fig = gcf;
        case 'y_lim'
            y_lim = varargin{i_arg+1};
    end
end
if isempty(h_axes)
    h_fig = figure;
    h_axes = gca;
end

numSessions = size(ratSummary.mean_pd_trajectory,1);

for iSession = 1 : numSessions
    
    sessionStage = ratSummary.sessions_analyzed(iSession,:).trainingStage;
    sessionLaser = ratSummary.sessions_analyzed(iSession,:).laserStim;
    
    if sessionStage == 'retraining'
        plotColor = baselineColor;
    elseif sessionLaser == 'on'
        plotColor = laserOnColor;
    elseif sessionLaser == 'occlude'
        plotColor = occludeColor;
    end
    
    % plot mean distance from mean trajectory
    toPlot = squeeze(ratSummary.mean_dist_from_pd_trajectory(iSession,:));
    hold on

    plot(toPlot,'color',plotColor);

end

ylabel('dist from traj (mm)')
xlabel('dist along trajectory')
title('mean distance from mean trajectory')
set(gca,'ylim',y_lim);