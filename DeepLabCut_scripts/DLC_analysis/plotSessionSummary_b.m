function [session_h_fig,session_h_axes,session_h_figAxis] = plotSessionSummary_b(mean_pd_trajectory,normalized_pd_trajectories,trialTypeIdx,curSession,curSessionType,validTypeNames)

x_lim = [-30 10];
y_lim = [-15 10];
z_lim = [-5 50];

numTrialTypes_to_analyze = size(mean_pd_trajectory,3);
numTrials = size(normalized_pd_trajectories,3);

figProps.m = 5;
figProps.n = 4;

figProps.panelWidth = ones(figProps.n,1) * 10;
figProps.panelHeight = ones(figProps.m,1) * 4;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = ones(figProps.m-1,1) * 1;

figProps.width = 20 * 2.54;
figProps.height = 12 * 2.54;

figProps.topMargin = 5;
figProps.leftMargin = 2.54;

[session_h_fig,session_h_axes] = createFigPanels5(figProps);

for iType = 1 : numTrialTypes_to_analyze
    for iDim = 1 : 3
        axes(session_h_axes(iType,iDim))
        
        plot(mean_pd_trajectory(:,iDim,iType),'linewidth',2,'color','k');
        hold on
        for iTrial = 1 : numTrials
            if trialTypeIdx(iTrial,iType)
                plot(normalized_pd_trajectories(:,iDim,iTrial));
            end
        end

        if iType == 1
            switch iDim
                case 1
                    title('x')
                case 2
                    title('y')
                case 3
                    title('z')
            end
        end
        switch iDim
            case 1
                set(gca,'ylim',x_lim)
            case 2
                set(gca,'ylim',y_lim,'ydir','reverse')
            case 3
                set(gca,'ylim',z_lim)
        end
    end
    
    axes(session_h_axes(iType,4))
    plot3(mean_pd_trajectory(:,1,iType),mean_pd_trajectory(:,3,iType),mean_pd_trajectory(:,2,iType),'linewidth',2,'color','k');
    hold on
    for iTrial = 1 : numTrials
        if trialTypeIdx(iTrial,iType)
            plot3(normalized_pd_trajectories(:,1,iTrial),normalized_pd_trajectories(:,3,iTrial),normalized_pd_trajectories(:,2,iTrial))
        end
    end

    scatter3(0,0,0,25,'k','o','markerfacecolor','k')
    set(gca,'zdir','reverse','xlim',x_lim,'ylim',z_lim,'zlim',y_lim,...
        'view',[-70,30])
    xlabel('x');ylabel('z');zlabel('y');
end

session_h_figAxis = createFigAxes(session_h_fig);

textString{1} = sprintf('%s all trial 3D trajectories; %s, day %d, %d days left in block', ...
    curSession, curSessionType.type, curSessionType.sessionsInBlock, curSessionType.sessionsLeftInBlock);
textString{2} = sprintf('trial types: %s', validTypeNames{1});
for ii = 2 : length(validTypeNames)
    textString{2} = sprintf('%s, %s', textString{2}, validTypeNames{ii});
end
axes(session_h_figAxis);
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');