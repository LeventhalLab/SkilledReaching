function h_fig = plotOrientTrajHisto(exptSummaryHisto,i,exclRat)

if i == 1 && exclRat == true    % exclude rats in ChR2 during 
    ratsInPlot = [1 2 5 6]; % 2 rats excluded because of short trajectories
else
    ratsInPlot = 1:size(exptSummaryHisto.mean_aperture_traj,1); % includes all rats in ChR2 during group
end 

laserSess = 3:12;   % define sessions to plot
occludedSess = 13:22;

minValue = 0;   % set y axis limits
maxValue = 100;

% define figure colors for each group
ratGrp = exptSummaryHisto.experimentInfo.type;
if strcmpi(ratGrp,'chr2_during') 
    lasColors = {[175/255 235/255 247/255] [175/255 235/255 247/255] [85/255 210/255 235/255] [85/255 210/255 235/255]...
    [24/255 173/255 203/255] [24/255 173/255 203/255] [41/255 103/255 196/255] [41/255 103/255 196/255]...
    [17/255 73/255 156/255] [17/255 73/255 156/255]};
elseif strcmpi(ratGrp,'chr2_between')
    lasColors = {[229/255 204/255 255/255] [229/255 204/255 255/255] [204/255 153/255 255/255] [204/255 153/255 255/255]...
    [178/255 102/255 255/255] [178/255 102/255 255/255] [127/255 0/255 255/255] [127/255 0/255 255/255]...
    [76/255 0/255 153/255] [76/255 0/255 153/255]};
elseif strcmpi(ratGrp,'arch_during')
    lasColors = {[173/255 239/255 201/255] [173/255 239/255 201/255] [116/255 226/255 163/255] [116/255 226/255 163/255]...
    [62/255 215/255 128/255] [62/255 215/255 128/255] [26/255 182/255 94/255] [26/255 182/255 94/255]...
    [11/255 129/255 62/255] [11/255 129/255 62/255]};
elseif strcmpi(ratGrp,'arch_between')
    lasColors = {[255/255 229/255 204/255] [255/255 229/255 204/255] [255/255 204/255 153/255] [255/255 204/255 153/255]...
    [255/255 153/255 51/255] [255/255 153/255 51/255] [255/255 128/255 0/255] [255/255 128/255 0/255]...
    [204/255 102/255 0/255] [204/255 102/255 0/255]};
else strcmpi(ratGrp,'eyfp')
    lasColors = {[255/255 153/255 204/255] [255/255 153/255 204/255] [255/255 102/255 178/255] [255/255 102/255 178/255]...
    [255/255 51/255 153/255] [255/255 51/255 153/255] [255/255 0/255 172/255] [255/255 0/255 172/255]...
    [204/255 0/255 102/255] [204/255 0/255 102/255]};
end

% set occlusion session colors
occColors = {[224/255 224/255 224/255] [224/255 224/255 224/255] [192/255 192/255 192/255] [192/255 192/255 192/255]...
    [160/255 160/255 160/255] [160/255 160/255 160/255] [128/255 128/255 128/255] [128/255 128/255 128/255]...
    [64/255 64/255 64/255] [64/255 64/255 64/255]};

% calculate averages for each session
for i = 1:size(exptSummaryHisto.mean_orientation_traj,3)
    numDataPts = sum(~isnan(exptSummaryHisto.mean_orientation_traj(ratsInPlot,:,i)),1);
    avgData(:,i) = nanmean(exptSummaryHisto.mean_orientation_traj(ratsInPlot,:,i));
    for i_sess = 1:22
        if numDataPts(1,i_sess) < 4 % don't include data point in average if less than 4 rats' trajectories went out to current z coordinate
            avgData(i_sess,i) = NaN;
        end 
    end 
end

avgData = (avgData*180)/pi; % convert data to degrees

loopCt = 1; % plot occlusion sessions
for l = occludedSess
    plot(avgData(l,:),'Color',occColors{loopCt},'LineWidth',1);
    hold on
    loopCt = loopCt + 1;
end

loopCt = 1; % plot laser on sessions
for k = laserSess
    plot(avgData(k,:),'Color',lasColors{loopCt},'LineWidth',1);
    hold on
    loopCt = loopCt + 1;
end 

% figure properties
line([201 201],[minValue maxValue],'Color','k') % add line for pellet

box off
ylabel('\theta (deg)')
xlabel('z_{digit2} (mm)')
set(gca,'ylim',[minValue maxValue]);
set(gca,'xlim',[50 350]);
set(gca,'ytick',[0 50 100]);
set(gca,'xtick',[50 201 350]);
set(gca,'xticklabels',[-15 0 15]);
set(gca,'FontSize',10);