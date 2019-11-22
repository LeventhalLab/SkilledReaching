function [h_fig,h_axes] = plot_endOrientation_acrossSessions_singleRat(ratSummary,thisRatInfo,varargin)
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

orientation_lim = [0,pi];

h_axes = [];

for i_arg = 1 : 2 : nargin - 2
    switch lower(varargin{i_arg})
        case 'h_axes'
            h_axes = varargin{i_arg+1};
            axes(h_axes);
            h_fig = gcf;
        case 'orientation_lim'
            orientation_lim = varargin{i_arg+1};
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
    toPlot = squeeze(ratSummary.mean_end_orientations(:,1));
    scatter(baseLineSessions,toPlot(baseLineSessions),'marker','o',...
        'markeredgecolor',baselineColor,'markerfacecolor',baselineColor);
    hold on
    scatter(laserOnSessions,toPlot(laserOnSessions),'marker','o',...
        'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
    scatter(occludeSessions,toPlot(occludeSessions),'marker','o',...
        'markeredgecolor',laserOnColor);
    
%     ebars = squeeze(ratSummary.std_end_aperture(:,1));
%     errorbar(baseLineSessions,toPlot(baseLineSessions),ebars(baseLineSessions),'marker','o',...
%         'markeredgecolor',baselineColor,'markerfacecolor',baselineColor,'linestyle','none');
%     errorbar(laserOnSessions,toPlot(laserOnSessions),ebars(laserOnSessions),'marker','o',...
%         'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'linestyle','none');
%     errorbar(occludeSessions,toPlot(occludeSessions),ebars(occludeSessions),'marker','o',...
%         'markeredgecolor',laserOnColor,'linestyle','none');

end
line([0,22],[0,0],'color','k')
ylabel('orientation at extension')
xlabel('session #')
set(gca,'xtick',[1,2,3,12,13,22]);
set(gca,'ylim',orientation_lim);