function [h_fig,h_axes] = plot_generalized_variance_acrossSessions_singleRat(ratSummary,thisRatInfo,varargin)
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

pawPref = thisRatInfo.pawPref;
sessions_analyzed = ratSummary.sessions_analyzed;
numSessions = size(sessions_analyzed,1);

baseLineSessions = find(sessions_analyzed.trainingStage == 'retraining');
laserOnSessions = find(sessions_analyzed.laserStim == 'on');
occludeSessions = find(sessions_analyzed.laserStim == 'occlude');

pd_gv = NaN(22,1);
dig_gv = NaN(22,4);
for iSession = 1 : numSessions
    
    session_pd_cov = squeeze(ratSummary.cov_pd_endPts(iSession,1,:,:));
    pd_gv(iSession) = det(session_pd_cov);
    
    session_dig_cov = squeeze(ratSummary.cov_dig_endPts(iSession,1,:,:,:));
    
end
    
scatter(baseLineSessions,pd_gv(baseLineSessions),'markeredgecolor',baselineColor);
hold on
scatter(laserOnSessions,pd_gv(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,pd_gv(occludeSessions),'markeredgecolor',laserOnColor);

title('generalized variance, paw dorsum')
ylabel('generalized var')
xlabel('session #')
set(gca,'xtick',[1,2,3,12,13,22]);
set(gca,'ylim',[1 500],'ytick',[0 250 500]);