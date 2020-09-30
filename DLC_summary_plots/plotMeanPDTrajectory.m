function [h_fig,h_axes] = plotMeanPDTrajectory(ratSummary,thisRatInfo,varargin)
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
    
    toPlot = squeeze(ratSummary.mean_pd_trajectory(iSession,:,:));
    switch pawPref
        case 'left'
            toPlot(:,1) = -toPlot(:,1);
        case 'right'
    end
    plot3(toPlot(:,1),toPlot(:,3),toPlot(:,2),'color',plotColor)
    hold on

end

scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',full_traj_z_lim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');