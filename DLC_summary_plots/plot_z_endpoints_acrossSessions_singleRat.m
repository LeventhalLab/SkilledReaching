function [h_fig,h_axes] = plot_z_endpoints_acrossSessions_singleRat(ratSummary,thisRatInfo,varargin)
%
% INPUTS
%   ratSummary
%   thisRatInfo
%
% OUTPUTS
%

sessions_analyzed = ratSummary.sessions_analyzed;

baseLineSessions = find(sessions_analyzed.trainingStage == 'retraining');
laserOnSessions = find(sessions_analyzed.laserStim == 'on');
occludeSessions = find(sessions_analyzed.laserStim == 'occlude');

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
    
    sessionStage = sessions_analyzed(iSession,:).trainingStage;
    sessionLaser = sessions_analyzed(iSession,:).laserStim;
    
    if sessionStage == 'retraining'
        plotColor = baselineColor;
    elseif sessionLaser == 'on'
        plotColor = laserOnColor;
    elseif sessionLaser == 'occlude'
        plotColor = occludeColor;
    end
    
    % plot digit 2 endpoints
    toPlot = squeeze(ratSummary.mean_dig_endPts(:,1,2,3));
    switch pawPref
        case 'left'
            toPlot(:,1) = -toPlot(:,1);
        case 'right'
    end
    plot(baseLineSessions,toPlot(baseLineSessions),'marker','o',...
        'markeredgecolor',baselineColor,'markerfacecolor',baselineColor);
    hold on
    plot(laserOnSessions,toPlot(laserOnSessions),'marker','o',...
        'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    plot(occludeSessions,toPlot(occludeSessions),'marker','o',...
        'markeredgecolor',laserOnColor);
    
    toPlot = squeeze(ratSummary.mean_pd_endPt(:,1,3));
    switch pawPref
        case 'left'
            toPlot(:,1) = -toPlot(:,1);
        case 'right'
    end
    plot(baseLineSessions,toPlot(baseLineSessions),'marker','o',...
        'markeredgecolor',baselineColor,'markerfacecolor',baselineColor);
    plot(laserOnSessions,toPlot(laserOnSessions),'marker','o',...
        'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    plot(occludeSessions,toPlot(occludeSessions),'marker','o',...
        'markeredgecolor',laserOnColor);

end
line([0,22],[0,0],'color','k')
ylabel('z-endpoint (mm)')
xlabel('session #')
set(gca,'xtick',[1,2,3,12,13,22]);
set(gca,'ylim',reachEnd_zlim);