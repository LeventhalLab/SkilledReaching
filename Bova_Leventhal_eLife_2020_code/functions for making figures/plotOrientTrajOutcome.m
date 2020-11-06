function h_fig = plotOrientTrajOutcome(exptOutcomeSummary,i_grp,exclRat)

if i_grp == 1 && exclRat == true % sets rats to include in average for ChR2 During group 
    ratsInPlot = [1 2 5 6]; % 2 excluded because of very short trajectories
else
    ratsInPlot = 1:size(exptOutcomeSummary(i_grp).mean_aperture_traj,4); % include all rats
end 

laserSess = 3:12;   % define sessions

minValue = 0;   % set y axis limits
maxValue = 100;

% define figure colors for each success vs failure

successColors = {[173/255 239/255 201/255] [173/255 239/255 201/255] [116/255 226/255 163/255] [116/255 226/255 163/255]...
[62/255 215/255 128/255] [62/255 215/255 128/255] [26/255 182/255 94/255] [26/255 182/255 94/255]...
[11/255 129/255 62/255] [11/255 129/255 62/255]};

failureColors = {[255/255 153/255 153/255] [255/255 153/255 153/255] [255/255 102/255 102/255] [255/255 102/255 102/255]...
    [255/255 51/255 51/255] [255/255 51/255 51/255] [204/255 0/255 0/255] [204/255 0/255 0/255]...
    [153/255 0/255 0/255] [153/255 0/255 0/255]};

% calculate averages

avgData = NaN(22,351,8);

data = (exptOutcomeSummary(i_grp).mean_orientation_traj*180)/pi;

for i_out = 1:8
    for i_pt = 1:size(data,2)
        numDataPts = sum(~isnan(data(:,i_pt,i_out,ratsInPlot)),4);
        avgData(:,i_pt,i_out) = nanmean(data(:,i_pt,i_out,ratsInPlot),4);
        for i_sess = 1:22
            if numDataPts(i_sess,1) < 4 % does not plot if less than 4 rats' trajectories reach this z coordinate (to avoid sudden jumps in average)
                avgData(i_sess,i_pt,i_out) = NaN;
            end 
        end             
    end
end 

% plot failure sessions
loopCt = 1;
for l = laserSess
    plot(avgData(l,:,5),'Color',failureColors{loopCt},'LineWidth',1);
    hold on
    loopCt = loopCt + 1;
end

loopCt = 1;
for k = laserSess     
    plot(avgData(k,:,2),'Color',successColors{loopCt},'LineWidth',1);
    hold on
    loopCt = loopCt + 1;
end 

% figure properties
line([201 201],[minValue maxValue],'Color','k') % add line at pellet

box off
ylabel('\theta (deg)')
xlabel('z_{digit2} (mm)')
set(gca,'ylim',[minValue maxValue]);
set(gca,'xlim',[50 350]);
set(gca,'ytick',[0 50 100]);
set(gca,'xtick',[50 201 350]);
set(gca,'xticklabels',[15 0 -15]);
set(gca,'FontSize',10);
