function plot_aperture_trajectory_for_one_experiment(exptSummary,h_axes)


retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';

occludeRatio = 0.25;

aperture_lim = [5 20];
zlimit = [-10 15];

switch exptSummary.experimentInfo.type
    case 'chr2_during'
        laserOnColor = 'b';
        occludeColor = [0 0 1] * occludeRatio;
    case 'chr2_between'
        laserOnColor = 'c';
        occludeColor = [0 0 1] * occludeRatio;
    case 'arch_during'
        laserOnColor = 'g';
        occludeColor = [0 1 0.0] * occludeRatio;
    case 'eyfp'
        laserOnColor = 'r';
        occludeColor = [1 0.0 0.0] * occludeRatio;
end
    
axes(h_axes)

% mean aperture trajectory
aperture_data = squeeze(nanmean(exptSummary.mean_aperture_traj,1));
z = exptSummary.z_interp_digits;
for i_retrainSession = 1 : length(retrainSessions)
    plot(z,aperture_data(retrainSessions(i_retrainSession),:),'color',retrainColor);
    hold on
end
for i_laserOnSession = 1 : length(laserOnSessions)
    plot(z,aperture_data(laserOnSessions(i_laserOnSession),:),'color',laserOnColor);
    hold on
end
for i_occludeSession = 1 : length(occludeSessions)
    plot(z,aperture_data(occludeSessions(i_occludeSession),:),'color',occludeColor);
    hold on
end
set(gca,'ylim',aperture_lim,'ytick',[10 20],'xdir','reverse',...
    'xlim',zlimit,'fontname','arial','fontsize',11,...
    'xtick',[-10 0 10],'xticklabel',[-10 0 10]);
line([0,0],[aperture_lim(1) aperture_lim(2)],'color','k');