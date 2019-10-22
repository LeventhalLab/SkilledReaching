%%

cur_expt = 1;   % chr2_during
% cur_expt = 2;   % chr2_between
% cur_expt = 3;   % arch
% cur_expt = 4;   % eyfp

maxTrials = 100;

reachEnd_zlim = [-15 30];

x_lim = [-30 10];
y_lim = [-20 10];

retrainSessions = 1 : 2;
laserOnSessions = 3 : 12;
occludeSessions = 13 : 22;

retrainColor = 'k';
laserOnColor = exptSummary(cur_expt).experimentInfo.laserWavelength;
if strcmpi(laserOnColor,'any')
    laserOnColor = 'c';
end
occludeColor = 'r';
toPlot = nanmean(exptSummary(cur_expt).num_trials,2);
numValidPts = sum(~isnan(exptSummary(1).num_trials),2);
e_bars = nanstd(exptSummary(cur_expt).num_trials,0,2) ./ sqrt(numValidPts);
hold on
scatter(retrainSessions,toPlot(retrainSessions),'markeredgecolor',retrainColor,'markerfacecolor',retrainColor);
scatter(laserOnSessions,toPlot(laserOnSessions),'markeredgecolor',laserOnColor,'markerfacecolor',laserOnColor);
scatter(occludeSessions,toPlot(occludeSessions),'markeredgecolor',occludeColor,'markerfacecolor',occludeColor);
errorbar(retrainSessions,toPlot(retrainSessions),e_bars(retrainSessions),retrainColor,'linestyle','none');
errorbar(laserOnSessions,toPlot(laserOnSessions),e_bars(laserOnSessions),laserOnColor,'linestyle','none');
errorbar(occludeSessions,toPlot(occludeSessions),e_bars(occludeSessions),occludeColor,'linestyle','none');
set(gca,'ylim',[0 100]);
set(gca,'xtick',[1,22])
title('number of trials')