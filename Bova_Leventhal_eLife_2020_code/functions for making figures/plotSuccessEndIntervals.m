function plotSuccessEndIntervals(allDigEndSummary,i_grp)

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

allDigEndSummary(i_grp).digEnd(:,:,:) = allDigEndSummary(i_grp).digEnd(:,:,:)*-1;

numRats = size(allDigEndSummary(i_grp).digEnd,3);

outcomes = NaN(30,numRats,10,22);
for i_rat = 1:numRats   % collect trial outcomes for reaches within z endpoint intervals
    
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
                outcomes(i_row,i_rat,i_int,i_sess) = allDigEndSummary(i_grp).outcomes(row(i_trial),i_sess,i_rat);
                i_row = i_row +1;
            end 

        clear row
        clear col

        end 
        
    end
end 


for i_int = 1:10    % calculate first reach success rates for each session for each z endpoint interval
    for i_sess = 1:22
        numOnes = sum(outcomes(:,:,i_int,i_sess) == 1);
        totalReaches = sum(outcomes(:,:,i_int,i_sess) == 1) + sum(outcomes(:,:,i_int,i_sess) == 2) + ...
            sum(outcomes(:,:,i_int,i_sess) == 3) + sum(outcomes(:,:,i_int,i_sess) == 4) + sum(outcomes(:,:,i_int,i_sess) == 7);
        avgIndivSuccess(i_sess,:,i_int) = numOnes./totalReaches;

        avgTotalSuccess(i_sess,i_int) = nanmean(avgIndivSuccess(i_sess,:,i_int));
    end 
end

% calculate averages across session types
avgLaserSetting(1,:) = nanmean(avgTotalSuccess(retrainSess ,:));
avgLaserSetting(2,:) = nanmean(avgTotalSuccess(laserSess ,:));
avgLaserSetting(3,:) = nanmean(avgTotalSuccess(occludedSess ,:));

% collect data for error bars calculation
rt = [avgIndivSuccess(retrainSess(1),:,:) avgIndivSuccess(retrainSess(2),:,:)];
ls = [avgIndivSuccess(laserSess(1),:,:) avgIndivSuccess(laserSess(2),:,:) avgIndivSuccess(laserSess(3),:,:)...
    avgIndivSuccess(laserSess(4),:,:) avgIndivSuccess(laserSess(5),:,:) avgIndivSuccess(laserSess(6),:,:)...
    avgIndivSuccess(laserSess(7),:,:) avgIndivSuccess(laserSess(7),:,:) avgIndivSuccess(laserSess(9),:,:) ...
    avgIndivSuccess(laserSess(10),:,:)]; 
os = [avgIndivSuccess(occludedSess(1),:,:) avgIndivSuccess(occludedSess(2),:,:) avgIndivSuccess(occludedSess(3),:,:)...
    avgIndivSuccess(occludedSess(4),:,:) avgIndivSuccess(occludedSess(5),:,:) avgIndivSuccess(occludedSess(6),:,:)...
    avgIndivSuccess(occludedSess(7),:,:) avgIndivSuccess(occludedSess(7),:,:) avgIndivSuccess(occludedSess(9),:,:) ...
    avgIndivSuccess(occludedSess(10),:,:)]; 

for i_int = 1:10    % calculate std. dev.
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

ylabel({'first reach'; 'success rate'},'FontSize',10)
xlabel('final z_{digit2} (mm)','FontSize',10)
set(gca,'ylim',[-.05 1.05],'ytick',[0 1]);
set(gca,'xlim',[.5 10.5]);
set(gca,'xtick',[1:10]);
set(gca,'xticklabels',{'0-1' '1-2' '2-3' '3-4' '4-5' '5-6' '6-7' '7-8' '8-9' '9-10'});
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off','Location','northwest') % create legend
legend('boxoff')

statsIntervalsSuccess(avgIndivSuccess,avgLaserSetting)
    

    
    