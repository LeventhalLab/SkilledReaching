function plotOrientationEndIntervals(allDigEndSummary,i_grp)

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

allDigEndSummary(i_grp).digEnd(:,:,:) = allDigEndSummary(i_grp).digEnd(:,:,:)*-1;

numRats = size(allDigEndSummary(i_grp).digEnd,3);

data = (allDigEndSummary(i_grp).orient*180)/pi;

orient = NaN(30,numRats,10,22);
for i_rat = 1:numRats   % collect orientation based on z endpoint intervals
    
    for i_int = 1:10
        
        lowInt = i_int - 1;
        highInt = i_int;
        
        for i_sess = 1:22
            [row col] = find(allDigEndSummary(i_grp).digEnd(:,i_sess,i_rat) >= lowInt &...
                allDigEndSummary(i_grp).digEnd(:,i_sess,i_rat) < highInt);
            
            if isempty(row)
                continue;
            end 

            i_row = 1;
            for i_trial = 1:size(row,1)
                orient(i_row,i_rat,i_int,i_sess) = data(row(i_trial),i_sess,i_rat);
                i_row = i_row +1;
            end 

        clear row
        clear col

        end 
        
    end
end 

for i_int = 1:10    % calculate average per session, per endpoint interval
    for i_sess = 1:22
        avgIndivOrient(i_sess,:,i_int) = nanmean(orient(:,:,i_int,i_sess));
        avgTotalOrient(i_sess,i_int) = nanmean(avgIndivOrient(i_sess,:,i_int));
    end 
end 

% average across session type
avgLaserSetting(1,:) = nanmean(avgTotalOrient(retrainSess ,:));
avgLaserSetting(2,:) = nanmean(avgTotalOrient(laserSess ,:));
avgLaserSetting(3,:) = nanmean(avgTotalOrient(occludedSess ,:));

% collect data for errorbars
rt = [avgIndivOrient(retrainSess(1),:,:) avgIndivOrient(retrainSess(2),:,:)];
ls = [avgIndivOrient(laserSess(1),:,:) avgIndivOrient(laserSess(2),:,:) avgIndivOrient(laserSess(3),:,:)...
    avgIndivOrient(laserSess(4),:,:) avgIndivOrient(laserSess(5),:,:) avgIndivOrient(laserSess(6),:,:)...
    avgIndivOrient(laserSess(7),:,:) avgIndivOrient(laserSess(7),:,:) avgIndivOrient(laserSess(9),:,:) ...
    avgIndivOrient(laserSess(10),:,:)]; 
os = [avgIndivOrient(occludedSess(1),:,:) avgIndivOrient(occludedSess(2),:,:) avgIndivOrient(occludedSess(3),:,:)...
    avgIndivOrient(occludedSess(4),:,:) avgIndivOrient(occludedSess(5),:,:) avgIndivOrient(occludedSess(6),:,:)...
    avgIndivOrient(occludedSess(7),:,:) avgIndivOrient(occludedSess(7),:,:) avgIndivOrient(occludedSess(9),:,:) ...
    avgIndivOrient(occludedSess(10),:,:)]; 

% calculate std dev
for i_int = 1:10
    errBars(1,i_int) = nanstd(rt(:,:,i_int))./sqrt(sum(~isnan(rt(:,:,i_int))));
    errBars(2,i_int) = nanstd(ls(:,:,i_int))./sqrt(sum(~isnan(ls(:,:,i_int))));
    errBars(3,i_int) = nanstd(os(:,:,i_int))./sqrt(sum(~isnan(os(:,:,i_int))));
end 

% plot data
ratGrp = allDigEndSummary(i_grp).experimentInfo.type; % define colors for each group
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

indivColor = [.85 .85 .85];

avgMarkerSize = 45; % set marker sizes
indMarkerSize = 4;

% plot 
p1 = scatter(1:10,avgLaserSetting(1,1:10),avgMarkerSize,'MarkerEdgeColor','k');
hold on
p2 = scatter(1:10,avgLaserSetting(2,1:10),avgMarkerSize,'filled','MarkerEdgeColor',figColor,...
    'MarkerFaceColor',figColor);
p3 = scatter(1:10,avgLaserSetting(3,1:10),avgMarkerSize,'MarkerEdgeColor',figColor);
e = errorbar(1:10,avgLaserSetting(1,1:10),errBars(1,1:10),'linestyle','none');
e1 = errorbar(1:10,avgLaserSetting(2,1:10),errBars(2,1:10),'linestyle','none');
e2 = errorbar(1:10,avgLaserSetting(3,1:10),errBars(3,1:10),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;
e2.Color = figColor;

ylabel({'\theta at reach'; 'end (deg)'},'FontSize',10)
xlabel('final z_{digit2} (mm)','FontSize',10)
set(gca,'ylim',[20 70],'ytick',[20 45 70]);
set(gca,'xlim',[.5 10.5]);
set(gca,'xtick',[1:10]);
set(gca,'xticklabels',{' ' '1-2' ' ' '3-4' ' ' '5-6' ' ' '7-8' ' ' '9-10'});
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off','Location','northwest') % create legend
legend('boxoff')

statsIntervalsOrient(avgIndivOrient,avgLaserSetting)
    