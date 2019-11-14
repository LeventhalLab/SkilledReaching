function [h_fig,h_axes] = plot3Dendpoints_acrossSessions_singleRat(ratSummary,thisRatInfo,varargin)
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

reachEnd_zlim = [-15 15];
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
    
    % plot digit 2 endpoints
    toPlot = squeeze(ratSummary.mean_dig_endPts(:,1,2,:));
    switch pawPref
        case 'left'
            toPlot(:,1) = -toPlot(:,1);
        case 'right'
    end
    scatter3(toPlot(baseLineSessions,1),toPlot(baseLineSessions,3),toPlot(baseLineSessions,2),...
        'markeredgecolor',baselineColor,'markerfacecolor',baselineColor);
    hold on
    scatter3(toPlot(laserOnSessions,1),toPlot(laserOnSessions,3),toPlot(laserOnSessions,2),...
        'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    scatter3(toPlot(occludeSessions,1),toPlot(occludeSessions,3),toPlot(occludeSessions,2),...
        'markeredgecolor',laserOnColor);
    
    toPlot = squeeze(ratSummary.mean_pd_endPt(:,1,:));
    switch pawPref
        case 'left'
            toPlot(:,1) = -toPlot(:,1);
        case 'right'
    end
    scatter3(toPlot(baseLineSessions,1),toPlot(baseLineSessions,3),toPlot(baseLineSessions,2),...
        'markeredgecolor',baselineColor,'markerfacecolor',baselineColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    scatter3(toPlot(laserOnSessions,1),toPlot(laserOnSessions,3),toPlot(laserOnSessions,2),...
        'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
    scatter3(toPlot(occludeSessions,1),toPlot(occludeSessions,3),toPlot(occludeSessions,2),...
        'markeredgecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);

end

scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');