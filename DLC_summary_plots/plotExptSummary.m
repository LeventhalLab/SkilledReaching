function h_fig = plotExptSummary(exptSummary)

maxTrials = 100;

reachEnd_zlim = [-15 30];

x_lim = [-30 10];
y_lim = [-20 10];

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';
laserOnColor = exptSummary.experimentInfo.laserWavelength;
if strcmpi(laserOnColor,'any')
    laserOnColor = 'c';
end
occludeColor = 'r';

% set up the figures for each type of plot
% kinematics summaries for each experiment type
exptSummary_figProps.m = 5;
exptSummary_figProps.n = 4;

exptSummary_figProps.panelWidth = ones(exptSummary_figProps.n,1) * 10;
exptSummary_figProps.panelHeight = ones(exptSummary_figProps.m,1) * 4;

exptSummary_figProps.colSpacing = ones(exptSummary_figProps.n-1,1) * 0.5;
exptSummary_figProps.rowSpacing = ones(exptSummary_figProps.m-1,1) * 1;

exptSummary_figProps.width = 20 * 2.54;
exptSummary_figProps.height = 12 * 2.54;

exptSummary_figProps.topMargin = 5;
exptSummary_figProps.leftMargin = 2.54;

[h_fig,h_axes] = createFigPanels5(exptSummary_figProps);

% number of trials
axes(h_axes(1,1))
toPlot = nanmean(exptSummary.num_trials,2);
numValidPts = sum(~isnan(exptSummary.num_trials),2);
e_bars = nanstd(exptSummary.num_trials,0,2) ./ sqrt(numValidPts);
hold on
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 maxTrials]);
set(gca,'xtick',[1,22])
title('number of trials')

% first reach success
axes(h_axes(1,2))
toPlot = nanmean(exptSummary.firstReachSuccess,2);
numValidPts = sum(~isnan(exptSummary.firstReachSuccess),2);
e_bars = nanstd(exptSummary.firstReachSuccess,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 1]);
title('first reach success')

% any reach success
axes(h_axes(1,3))
toPlot = nanmean(exptSummary.anyReachSuccess,2);
numValidPts = sum(~isnan(exptSummary.anyReachSuccess),2);
e_bars = nanstd(exptSummary.anyReachSuccess,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 1]);
title('any reach success')

% number of reaches per trial
axes(h_axes(1,4))
toPlot = nanmean(exptSummary.mean_num_reaches,2);
numValidPts = sum(~isnan(exptSummary.mean_num_reaches),2);
e_bars = nanstd(exptSummary.mean_num_reaches,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 6]);
title('reaches per trial')

% max paw velocity
axes(h_axes(2,1))
toPlot = nanmean(exptSummary.mean_pd_v,2);
numValidPts = sum(~isnan(exptSummary.mean_pd_v),2);
e_bars = nanstd(exptSummary.mean_pd_v,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 1000]);
title('max paw velocity')

% mean end aperture
axes(h_axes(3,1))
toPlot = nanmean(exptSummary.mean_end_aperture,2);
numValidPts = sum(~isnan(exptSummary.mean_end_aperture),2);
e_bars = nanstd(exptSummary.mean_end_aperture,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[5 25]);
title('mean end aperture')

% std end aperture
axes(h_axes(3,2))
toPlot = nanmean(exptSummary.std_end_aperture,2);
numValidPts = sum(~isnan(exptSummary.std_end_aperture),2);
e_bars = nanstd(exptSummary.std_end_aperture,0,2) ./ sqrt(numValidPts);
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 10],'xlim',[-10,20]);
title('std end aperture')

% mean aperture trajectory
axes(h_axes(3,3))
aperture_data = squeeze(nanmean(exptSummary.mean_aperture_traj,1));
z = exptSummary.z_interp_digits;
for i_retrainSession = 1 : length(retrainSessions)
    plot(z,aperture_data(retrainSessions(i_retrainSession),:),'color',retrainColor);
    hold on
end
for i_laserOnSession = 1 : length(laserOnSessions)
    plot(z,aperture_data(laserOnSessions(i_laserOnSession),:),'color',laserOnColor);
end
for i_occludeSession = 1 : length(occludeSessions)
    plot(z,aperture_data(occludeSessions(i_occludeSession),:),'color',occludeColor);
end

set(gca,'ylim',[5 25],'xdir','reverse','xlim',[-10,20]);
title('aperture post-slot')

% mean paw orientation at reach end
axes(h_axes(4,1))
final_orientations = nancirc_mean(exptSummary.mean_end_orientations,[],2);
final_MRLs = nanmean(exptSummary.end_MRL,2);
toPlot = final_MRLs .* exp(1i*final_orientations);
h_line = compass(toPlot(retrainSessions));
hold on
for ii = 1 : length(h_line)
    h_line(ii).Color = retrainColor;
end
h_line2 = compass(toPlot(laserOnSessions));
for ii = 1 : length(h_line2)
    h_line2(ii).Color = laserOnColor;
end
h_line3 = compass(toPlot(occludeSessions));
for ii = 1 : length(h_line2)
    h_line3(ii).Color = occludeColor;
end




    
    

% mean MRL trajectory
axes(h_axes(4,3))
MRL_traj = squeeze(nanmean(exptSummary.MRL_traj,1));
z = exptSummary.z_interp_digits;
for i_retrainSession = 1 : length(retrainSessions)
    plot(z,MRL_traj(retrainSessions(i_retrainSession),:),'color',retrainColor);
    hold on
end
for i_laserOnSession = 1 : length(laserOnSessions)
    plot(z,MRL_traj(laserOnSessions(i_laserOnSession),:),'color',laserOnColor);
end
for i_occludeSession = 1 : length(occludeSessions)
    plot(z,MRL_traj(occludeSessions(i_occludeSession),:),'color',occludeColor);
end
set(gca,'ylim',[0 1],'xdir','reverse','xlim',[-10,20]);
title('MRL post-slot')

% mean orientation trajectory
axes(h_axes(4,2))
orientation_data = squeeze(nancirc_mean(exptSummary.mean_orientation_traj,[],1));
z = exptSummary.z_interp_digits;
for i_retrainSession = 1 : length(retrainSessions)
    plot(z,orientation_data(retrainSessions(i_retrainSession),:),'color',retrainColor);
    hold on
end
for i_laserOnSession = 1 : length(laserOnSessions)
    plot(z,orientation_data(laserOnSessions(i_laserOnSession),:),'color',laserOnColor);
    hold on
end
for i_occludeSession = 1 : length(occludeSessions)
    plot(z,orientation_data(occludeSessions(i_occludeSession),:),'color',occludeColor);
    hold on
end
set(gca,'ylim',[0 pi/2],'xdir','reverse','xlim',[-10,20]);
title('paw orientation post-slot')



% 3D pd endpoints
axes(h_axes(5,1))
pd_toPlot = squeeze(nanmean(exptSummary.mean_pd_endPt,1));
scatter3(pd_toPlot(retrainSessions,1),pd_toPlot(retrainSessions,3),pd_toPlot(retrainSessions,2),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter3(pd_toPlot(laserOnSessions,1),pd_toPlot(laserOnSessions,3),pd_toPlot(laserOnSessions,2),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter3(pd_toPlot(occludeSessions,1),pd_toPlot(occludeSessions,3),pd_toPlot(occludeSessions,2),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');
title('mean pd endpoints')

% 3D dig2 endpoints
title('mean 3D endpoints')
axes(h_axes(5,2))
dig2_toPlot = squeeze(nanmean(exptSummary.mean_dig2_endPt,1));
scatter3(dig2_toPlot(retrainSessions,1),dig2_toPlot(retrainSessions,3),dig2_toPlot(retrainSessions,2),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
hold on
scatter3(dig2_toPlot(laserOnSessions,1),dig2_toPlot(laserOnSessions,3),dig2_toPlot(laserOnSessions,2),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter3(dig2_toPlot(occludeSessions,1),dig2_toPlot(occludeSessions,3),dig2_toPlot(occludeSessions,2),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');
title('mean digit 2 endpoints')

% z endpoints
axes(h_axes(5,3))
pd_z = squeeze(exptSummary.mean_pd_endPt(:,:,3))';
pd_z_toPLot = nanmean(pd_z,2);
numValidPts = sum(~isnan(pd_z),2);
pd_e_bars = nanstd(pd_z,0,2) ./ sqrt(numValidPts);

dig2_z = squeeze(exptSummary.mean_dig2_endPt(:,:,3))';
dig2_z_toPlot = nanmean(dig2_z,2);
numValidPts = sum(~isnan(dig2_z),2);
dig2_e_bars = nanstd(dig2_z,0,2) ./ sqrt(numValidPts);

scatter(retrainSessions,pd_z_toPLot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
hold on
scatter(laserOnSessions,pd_z_toPLot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
scatter(occludeSessions,pd_z_toPLot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor,'markeredgealpha',0.5,'markerfacealpha',0.5);
errorbar(retrainSessions,pd_z_toPLot(retrainSessions),pd_e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,pd_z_toPLot(laserOnSessions),pd_e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,pd_z_toPLot(occludeSessions),pd_e_bars(occludeSessions),occludeColor,'linestyle','none');

scatter(retrainSessions,dig2_z_toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
scatter(laserOnSessions,dig2_z_toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,dig2_z_toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,dig2_z_toPlot(retrainSessions),dig2_e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,dig2_z_toPlot(laserOnSessions),dig2_e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,dig2_z_toPlot(occludeSessions),dig2_e_bars(occludeSessions),occludeColor,'linestyle','none');

set(gca,'ylim',reachEnd_zlim);
title('mean z endpoint')

textString{1} = exptSummary.experimentInfo.type;

h_figAxis = createFigAxes(h_fig);
axes(h_figAxis);
text(exptSummary_figProps.leftMargin,exptSummary_figProps.height-0.75,textString,...
    'units','centimeters','interpreter','none');