function plotOutcomeAperture(exptOutcomeSummary)

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

ratGrp = exptOutcomeSummary.experimentInfo.type; % define colors for each group
if strcmpi(ratGrp,'chr2_during')
    figColor = [.12 .16 .67];
elseif strcmpi(ratGrp,'chr2_between')
    figColor = [127/255 0/255 255/255];
elseif strcmpi(ratGrp,'arch_during')
    figColor = [0 .4 0.2];
elseif strcmpi(ratGrp,'arch_between')
    figColor = [255/255 128/255 0/255];
else strcmpi(ratGrp,'eyfp')
    figColor = [.84 .14 .63];
end

outcomeColors = {[0 .37 .02],[.32 .94 .36],'k',[.55 .09 .07],[.99 .41 .39], [.63 .63 .63]};
% calculate averages and standard deviations

for i_outcome = 1:7
    for i_sess = 1:22       
        avgData(i_sess,i_outcome) = nanmean(exptOutcomeSummary.mean_end_aperture(i_sess,i_outcome,:));        
    end 
end 

for i_outcome = 1:7
    for i_sess = 1:22 
        numDataPoints = sum(~isnan(exptOutcomeSummary.mean_end_aperture(i_sess,i_outcome,:)));
        errBars(i_sess,i_outcome) = nanstd(exptOutcomeSummary.mean_end_aperture(i_sess,i_outcome,:),0)./sqrt(numDataPoints);        
    end 
end 

% plot 

% set marker sizes
avgMarkerSize = 45;

for i = [2 5]    
    scatter(retrainSess,avgData(retrainSess,i),avgMarkerSize,'MarkerEdgeColor',outcomeColors{i-1});
    hold on
    scatter(laserSess,avgData(laserSess,i),avgMarkerSize,'MarkerFaceColor',outcomeColors{i-1},...
        'MarkerEdgeColor',outcomeColors{i-1});
    scatter(occludedSess,avgData(occludedSess,i),avgMarkerSize,'MarkerEdgeColor',outcomeColors{i-1});
    
    e = errorbar(1:22,avgData(1:22,i),errBars(1:22,i),'linestyle','none','HandleVisibility','off');
    e.Color = outcomeColors{i-1};
end

%figure properties

minValue = 10;
maxValue = 20;

% set background color opacity
if i == 1 || i == 3
    patchShade = 0.07;
elseif i == 2 || i == 4 || i == 5
    patchShade = 0.11;
end

patchX = [2.5 12.5 12.5 2.5];
patchY = [minValue minValue maxValue maxValue];

patch(patchX,patchY,figColor,'FaceAlpha',patchShade,'LineStyle','none')

box off
set(gca,'xlim',[0 23],'ylim',[minValue maxValue],'ytick',[10 15 20]);
set(gca,'xtick',[1 2 3 12 13 22]);
set(gca,'xticklabels',[9 10 1 10  1 10]);
set(gca,'FontSize',10);

ylabel({'aperture at'; 'reach end (mm)'})
xlabel('session number')

% legend([p1 p2],{'first success','failure'},'AutoUpdate','off') % create legend
% legend('boxoff')