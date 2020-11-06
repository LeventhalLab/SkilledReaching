function plotApertureEndIntervals(allDigEndSummary,i_grp)

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

allDigEndSummary(i_grp).digEnd(:,:,:) = allDigEndSummary(i_grp).digEnd(:,:,:)*-1;

numRats = size(allDigEndSummary(i_grp).digEnd,3);

aperture = NaN(30,numRats,10,22);
for i_rat = 1:numRats   % collect apertures based on z endpoint each trial
    
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
                aperture(i_row,i_rat,i_int,i_sess) = allDigEndSummary(i_grp).aperture(row(i_trial),i_sess,i_rat);
                i_row = i_row +1;
            end 

        clear row
        clear col

        end 
        
    end
end 

% calculate averages for each session, each endpoint interval
for i_int = 1:10
    for i_sess = 1:22
        avgIndivAper(i_sess,:,i_int) = nanmean(aperture(:,:,i_int,i_sess));
        avgTotalAper(i_sess,i_int) = nanmean(avgIndivAper(i_sess,:,i_int));
    end 
end 

% average across session types
avgLaserSetting(1,:) = nanmean(avgTotalAper(retrainSess ,:));
avgLaserSetting(2,:) = nanmean(avgTotalAper(laserSess ,:));
avgLaserSetting(3,:) = nanmean(avgTotalAper(occludedSess ,:));

% collect data for error bars
rt = [avgIndivAper(retrainSess(1),:,:) avgIndivAper(retrainSess(2),:,:)];
ls = [avgIndivAper(laserSess(1),:,:) avgIndivAper(laserSess(2),:,:) avgIndivAper(laserSess(3),:,:)...
    avgIndivAper(laserSess(4),:,:) avgIndivAper(laserSess(5),:,:) avgIndivAper(laserSess(6),:,:)...
    avgIndivAper(laserSess(7),:,:) avgIndivAper(laserSess(7),:,:) avgIndivAper(laserSess(9),:,:) ...
    avgIndivAper(laserSess(10),:,:)]; 
os = [avgIndivAper(occludedSess(1),:,:) avgIndivAper(occludedSess(2),:,:) avgIndivAper(occludedSess(3),:,:)...
    avgIndivAper(occludedSess(4),:,:) avgIndivAper(occludedSess(5),:,:) avgIndivAper(occludedSess(6),:,:)...
    avgIndivAper(occludedSess(7),:,:) avgIndivAper(occludedSess(7),:,:) avgIndivAper(occludedSess(9),:,:) ...
    avgIndivAper(occludedSess(10),:,:)]; 

for i_int = 1:10    % calculate std devs
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

ylabel('aperture (mm)','FontSize',10)
xlabel('final z_{digit2} (mm)','FontSize',10)
set(gca,'ylim',[12 18],'ytick',[12 15 18]);
set(gca,'xlim',[.5 10.5]);
set(gca,'xtick',[1:10]);
set(gca,'xticklabels',{' ' '1-2' ' ' '3-4' ' ' '5-6' ' ' '7-8' ' ' '9-10'});
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off','Location','northwest') % create legend
legend('boxoff')
    
statsIntervalsAperture(avgIndivAper,avgLaserSetting)

    
    