function plotLimbAims(cylData,groups,combineChR)

for i_grp = groups  % get number rats in each group
    grpSz(find(groups == i_grp),:) = size(cylData(i_grp).paw,2);
end 

numCol = max(grpSz);

indivLimb = NaN(size(groups,2),numCol,6);

for i_grp = groups  % multiply amplitude and basic scores to get composite scores
    numRats = size(cylData(i_grp).paw,2);
    indivLimb(find(groups == i_grp),1:numRats,:) = cylData(i_grp).limbAmplitude .* cylData(i_grp).limbBasic;
end 

if combineChR == true   % lump all ChR2 rats into one group (i.e., during + between)
    indivLimb2 = NaN(size(groups,2)-2,numCol*2,6);
    for power = 1:6
        if size(indivLimb,1) == 4
            indivLimb2(1,:,power) = [indivLimb(1,:,power) indivLimb(2,:,power)];
            indivLimb2(2,:,power) = [indivLimb(3,:,power) indivLimb(4,:,power)];
        elseif size(indivLimb,1) > 4
            indivLimb2(1,:,power) = [indivLimb(1,:,power) indivLimb(2,:,power)];
            indivLimb2(2,:,power) = [indivLimb(4,:,power) indivLimb(5,:,power)];
            indivLimb2(3,1:numCol,power) = indivLimb(3,:,power);
            indivLimb2(4,1:numCol,power) = indivLimb(6,:,power);
        end 
    end
end 

avgLimb = nanmean(indivLimb2,2);    % calculate average
erBars = nanstd(indivLimb2,0,2)./sqrt(size(indivLimb2,2));  % calculate s.e.m.

% put data in format for plotting (rows laser power, columns groups ChR2
% day 1, ChR2 day 2, EYFP day 1, EYFP day 2)
avgPlot = [avgLimb(:,:,1)'; avgLimb(:,:,2)'; avgLimb(:,:,3)'; avgLimb(:,:,4)'; avgLimb(:,:,5)'; avgLimb(:,:,6)'];

% plot data
aimFig = bar(avgPlot);
hold on

aimFig(1).FaceColor = [.71 .82 .94];    % set colors of bars
aimFig(2).FaceColor = [.12 .16 .67];
aimFig(3).FaceColor = [.84 .71 .88];
aimFig(4).FaceColor = [.84 .14 .63];

% plot individual data
indivColor = [.65 .65 .65];

for i_pow = 1:6
    xVals = [i_pow-.27 i_pow-.08];
    for i_rat = 1:size(indivLimb2,2)
        plot(xVals,indivLimb2(1:2,i_rat,i_pow),'Color',indivColor,'LineWidth',.5)
    end
end 

% find center of bars to plot error bars
xdata1 = aimFig(1).XData;
xdata2 = aimFig(2).XData;
ydata1 = aimFig(1).YData;
ydata2 = aimFig(2).YData;

lineW = 1;

for r = 1:6 % add error bars
    errorbar(xdata1(r)-.27,ydata1(r),erBars(1,:,r),'k','LineWidth',lineW)
    errorbar(xdata2(r)-.08,ydata2(r),erBars(2,:,r),'k','LineWidth',lineW)
end

% figure properties
ylabel('limb AIMs score')
xlabel('laser power')
set(gca,'ylim',[0 8]);
set(gca,'ytick',[0 4 8]);
set(gca,'xticklabels',[0 5 10 15 20 25]);
set(gca,'FontSize',10);
box off