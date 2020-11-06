function plotNEndIntervals(allDigEndSummary,i_grp)

retrainSess = 1:2; % define test sessions
laserSess = 3:12;
occludedSess = 13:22;

allDigEndSummary(i_grp).digEnd(:,:,:) = allDigEndSummary(i_grp).digEnd(:,:,:)*-1;

numRats = size(allDigEndSummary(i_grp).digEnd,3);

numTrials = NaN(numRats,10,22);
for i_rat = 1:numRats   % collect number of trials in each z endpoint interval 
    
    for i_int = 1:10
        
        lowInt = i_int - 1;
        highInt = i_int;
        
        for i_sess = 1:22
            [row col] = find(allDigEndSummary(i_grp).digEnd(:,i_sess,i_rat) >= lowInt &...
                allDigEndSummary(i_grp).digEnd(:,i_sess,i_rat) < highInt);
%             
%             if isempty(row)
%                 continue;
%             end 

            numTrials(i_rat,i_int,i_sess) = size(row,1);

            clear row
            clear col

        end 
        
    end
end 

for i_sess = 1:22   % get total for each session
    sumSession(i_sess,:) = sum(numTrials(:,:,i_sess));
end

sumByLaser(1,:) = sum(sumSession(retrainSess,:))/2; % average across session types
sumByLaser(2,:) = sum(sumSession(laserSess,:))/10;
sumByLaser(3,:) = sum(sumSession(occludedSess,:))/10;

rt = [numTrials(:,:,retrainSess(1)); numTrials(:,:,retrainSess(2))];    % collect data for error bars
ls = [numTrials(:,:,laserSess(1)); numTrials(:,:,laserSess(2)); numTrials(:,:,laserSess(3));...
    numTrials(:,:,laserSess(4)); numTrials(:,:,laserSess(5)); numTrials(:,:,laserSess(6));...
    numTrials(:,:,laserSess(7)); numTrials(:,:,laserSess(8)); numTrials(:,:,laserSess(9)); ...
    numTrials(:,:,laserSess(10))]; 
os = [numTrials(:,:,occludedSess(1)); numTrials(:,:,occludedSess(2)); numTrials(:,:,occludedSess(3));...
    numTrials(:,:,occludedSess(4)); numTrials(:,:,occludedSess(5)); numTrials(:,:,occludedSess(6));...
    numTrials(:,:,occludedSess(7)); numTrials(:,:,occludedSess(8)); numTrials(:,:,occludedSess(9)); ...
    numTrials(:,:,occludedSess(10))]; 

for i_int = 1:10    % calculate std. dev
    errBars(1,i_int) = nanstd(rt(:,i_int))./sqrt(sum(~isnan(rt(:,i_int))));
    errBars(2,i_int) = nanstd(ls(:,i_int))./sqrt(sum(~isnan(rt(:,i_int))));
    errBars(3,i_int) = nanstd(os(:,i_int))./sqrt(sum(~isnan(rt(:,i_int))));
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

p1 = scatter(1:10,sumByLaser(1,1:10),avgMarkerSize,'MarkerEdgeColor','k');
hold on
p2 = scatter(1:10,sumByLaser(2,1:10),avgMarkerSize,'filled','MarkerEdgeColor',figColor,...
    'MarkerFaceColor',figColor);
p3 = scatter(1:10,sumByLaser(3,1:10),avgMarkerSize,'MarkerEdgeColor',figColor);

e = errorbar(1:10,sumByLaser(1,1:10),errBars(1,1:10),'linestyle','none');
e1 = errorbar(1:10,sumByLaser(2,1:10),errBars(2,1:10),'linestyle','none');
e2 = errorbar(1:10,sumByLaser(3,1:10),errBars(3,1:10),'linestyle','none');

e.Color = 'k';
e1.Color = figColor;
e2.Color = figColor;

ylabel({'trials per session'},'FontSize',10)
xlabel('final z_{digit2} (mm)','FontSize',10)
set(gca,'ylim',[-.05 100],'ytick',[0 50 100]);
set(gca,'xlim',[.5 10.5]);
set(gca,'xtick',[1:10]);
set(gca,'xticklabels',{'0-1' '1-2' '2-3' '3-4' '4-5' '5-6' '6-7' '7-8' '8-9' '9-10'});
set(gca,'FontSize',10);
box off

legend([p1 p2 p3],{'retraining','laser on','occluded'},'AutoUpdate','off','Location','northwest') % create legend
legend('boxoff')

statsIntervalsNumTrials(numTrials,sumByLaser)
    
