function plotCorrFiberEndPoint(exptSummaryHisto,coor,i_grp,coorType)

minValue = -20; % set ylim values
maxValue = 20;  

syms = {'o','s','d','p','+','*','x','v'};      % symbols for scatter plot

% define figure colors for each group
ratGrp = exptSummaryHisto(i_grp).experimentInfo.type;
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

curRats = find(coor.Virus == i_grp);    % get rats from group

endPts = exptSummaryHisto(i_grp).mean_dig2_endPt(:,12,3)*-1;    % change sign of endpoint

numRats = size(curRats,1);

if coorType == 'ap'     % plot data based on what coordinate measurement is selected
    ap(:,1) = coor.AP(curRats);
    for i_rat = 1:size(ap,1)
        plot(ap(i_rat),endPts(i_rat),'Marker',syms{i_rat},'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor)
        hold on
    end 
    set(gca,'xlim',[-6.2 -4.7])
    [corrVal pval] = corr(ap,endPts);   % fit linear regression
    corrText = sprintf('r = %0.3f',corrVal);    % get r and p values to put in plot
    pText = sprintf('p = %0.3f',pval);
    if i_grp == 1
        if pval <= 0.05     % bold if p < .05
            text(-5.6,maxValue - 5,pText,'FontWeight','bold');
            text(-5.6,maxValue - 1,corrText,'FontWeight','bold');
        else
            text(-5.6,maxValue - 5,pText);
            text(-5.6,maxValue - 1,corrText);     
        end 
    else
        text(-5.6,minValue + 3,pText);
        text(-5.6,minValue + 7,corrText);
    end
    xlabel('A-P coordinate')
    set(gca,'Xdir','reverse')
    set(gca,'ylim',[minValue maxValue]);
    set(gca,'ytick',[minValue 0 maxValue]);
    box off
elseif coorType == 'ml'
    ml(:,1)= coor.ML(curRats);
    ml = abs(ml);
    for i_rat = 1:size(ml,1)
        plot(ml(i_rat),endPts(i_rat),'Marker',syms{i_rat},'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor)
        hold on
    end 
    set(gca,'xlim',[1.3 2.6])
    [corrVal pval] = corr(ml,endPts);
    corrText = sprintf('r = %0.3f',corrVal);
    pText = sprintf('p = %0.3f',pval);
    if i_grp == 1
        if pval <= 0.05
            text(2.1,maxValue - 5,pText,'FontWeight','bold');
            text(2.1,maxValue - 1,corrText,'FontWeight','bold');
        else
            text(2.1,maxValue - 5,pText);
            text(2.1,maxValue - 1,corrText);
        end 
    else
        text(2.1,minValue + 3,pText);
        text(2.1,minValue + 7,corrText);
    end
    xlabel('M-L coordinate')
    set(gca,'ylim',[minValue maxValue]);
    set(gca,'ytick',[minValue 0 maxValue]);
    box off
elseif coorType == 'dv'
    dv(:,1) = coor.DV(curRats);
    for i_rat = 1:size(dv,1)
        plot(dv(i_rat),endPts(i_rat),'Marker',syms{i_rat},'MarkerEdgeColor',figColor,'MarkerFaceColor',figColor)
        hold on
    end 
    set(gca,'xlim',[7 8.5])
    [corrVal pval] = corr(dv,endPts);
    corrText = sprintf('r = %0.3f',corrVal);
    pText = sprintf('p = %0.3f',pval);
    if i_grp == 1
        text(7.8,maxValue - 5,pText);
        text(7.8,maxValue - 1,corrText);
    else
        text(7.8,minValue + 3,pText);
        text(7.8,minValue + 7,corrText);
    end
    xlabel('D-V coordinate')
    set(gca,'ylim',[minValue maxValue]);
    set(gca,'ytick',[minValue 0 maxValue]);
    box off
end 




