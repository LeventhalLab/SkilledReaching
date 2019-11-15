function [h_fig,h_axes] = plotReachSuccess_acrossSessions_singleRat(ratSummary,successType,varargin)
%
% INPUTS
%   ratSummary
%   thisRatInfo
%
% OUTPUTS
%
occludeRatio=0.5;

% trialTypeColors = {'g','b','r','y','c','m'};

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

switch successType
    case 'first'
        toPlot = ratSummary.outcomePercent(:,2);   % assumes second column is first reach success
        plotTitle = 'first reach success';
    case 'any'
        toPlot = ratSummary.outcomePercent(:,3) + ratSummary.outcomePercent(:,2);   % assumes third row is first reach success
        plotTitle = 'any reach success';
    case 'both'
        toPlot = [ratSummary.outcomePercent(:,2),ratSummary.outcomePercent(:,3) + ratSummary.outcomePercent(:,2)];
        plotTitle = 'first/any reach success';
end
numSessions = size(ratSummary.mean_pd_trajectory,1);
sessions_analyzed = ratSummary.sessions_analyzed;

baseLineSessions = find(sessions_analyzed.trainingStage == 'retraining');
laserOnSessions = find(sessions_analyzed.laserStim == 'on');
occludeSessions = find(sessions_analyzed.laserStim == 'occlude');

for ii = 1 : size(toPlot,2)
    plot(baseLineSessions,toPlot(baseLineSessions,ii),'marker','o','markeredgecolor',baselineColor,'color',laserOnColor);
    hold on
    plot(laserOnSessions,toPlot(laserOnSessions,ii),'marker','o','markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'color',laserOnColor);
    plot(occludeSessions,toPlot(occludeSessions,ii),'marker','o','markeredgecolor',laserOnColor,'color',laserOnColor);
end
ylabel('success rate')
xlabel('session #')
set(gca,'xtick',[1,2,3,12,13,22]);
set(gca,'ylim',[0 1.1],'ytick',[0 0.5 1]);

title(plotTitle)